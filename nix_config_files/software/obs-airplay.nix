{ config, lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      obs-airplay = prev.stdenv.mkDerivation rec {
        pname = "obs-airplay";
        version = "unstable-2024";

src = prev.fetchgit {
          url = "https://github.com/mika314/obs-airplay.git";
          rev = "1197817f670c4dabea073f991331fb3af38feb2c";
          hash = "sha256-aJtwpzzaeRNpJjN47tY1+mmr8YLt1UcRAmn3CMInQr0=";
          fetchSubmodules = true;
        };

        # Fetch the missing log library
log_src = prev.fetchgit {
          url = "https://github.com/mika314/log.git";
          rev = "HEAD";
          hash = "sha256-XGCq6fTSfearMAbcGDJY9vcbvDIGlsPFIv6kBYKKztg=";
        };

        nativeBuildInputs = with prev; [
          cmake
          pkg-config
          clang
        ];

buildInputs = with prev; [
          obs-studio
          openssl
          ffmpeg
          (avahi.override { withLibdnssdCompat = true; })
          libplist
          libplist.dev
          fdk_aac
          libGL
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
        ];

	dontUseCmakeConfigure = true;


buildPhase = ''
          # Build UxPlay submodule first
          mkdir -p $PWD/UxPlay/build
          pushd $PWD/UxPlay/build
          cmake .. -DCMAKE_BUILD_TYPE=Release \
                   -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
                   -DNO_MARCH_NATIVE=ON
          make -j$NIX_BUILD_CORES
          popd

          echo "=== UxPlay static libs ==="
          find $PWD/UxPlay/build -name "*.a" | sort

          # Copy log library into place
          cp -r $log_src log

          # Compile plugin
# Compile plugin
          c++ -shared -fPIC -std=c++20 -O2 \
            $(pkg-config --cflags libavcodec libavformat libavutil libswresample libswscale openssl avahi-compat-libdns_sd) \
            -I${prev.libplist.dev}/include \
            -I${prev.obs-studio}/include \
            -I${prev.obs-studio}/include/obs \
            -I$PWD/UxPlay/lib \
            -I$PWD \
            airplay.cpp audio-decoder.cpp h264-decoder.cpp plugin.cpp \
            -Wl,--whole-archive $PWD/UxPlay/build/lib/libairplay.a $PWD/UxPlay/build/lib/playfair/libplayfair.a $PWD/UxPlay/build/lib/llhttp/libllhttp.a -Wl,--no-whole-archive \
            $(pkg-config --libs libavcodec libavformat libavutil libswresample libswscale openssl avahi-compat-libdns_sd) \
            -L${prev.avahi.override { withLibdnssdCompat = true; }}/lib \
            -L${prev.libplist}/lib \
            -lfdk-aac -lGL -ldns_sd -lplist-2.0 \
            -o obs-airplay.so

        '';



        installPhase = ''
          mkdir -p $out/lib/obs-plugins
          cp obs-airplay.so $out/lib/obs-plugins/
        '';
      };
    })
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
      pkgs.obs-airplay
    ];
  };
}

