{ config, pkgs, ... }:

let
  avmatrix-driver = config.boot.kernelPackages.callPackage ({ stdenv, fetchFromGitHub, kernel }:
    stdenv.mkDerivation rec {
      pname = "avmatrix-vc12-driver";
      version = "master";

      src = fetchFromGitHub {
        owner = "GloriousEggroll";
        repo = "AVMATRIX-VC12-4K-CAPTURE";
        rev = "master";
        sha256 = "sha256-ZGY1acjeL5544T5RNfCtA87sfL7U6En0KZADhOPNgRg="; 
      };

      hardeningDisable = [ "pic" ];
      nativeBuildInputs = kernel.moduleBuildDependencies;

      buildPhase = ''
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd)/src modules
      '';

      installPhase = ''
        mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
        cp src/HwsUHDX1Capture.ko $out/lib/modules/${kernel.modDirVersion}/extra/
      '';
    }) {};
in
{
  boot.extraModulePackages = [ 
    avmatrix-driver 
    config.boot.kernelPackages.v4l2loopback 
  ];

  boot.kernelModules = [ "HwsUHDX1Capture" "v4l2loopback" "snd-hda-intel" ];

  boot.kernelParams = [ 
    "intel_iommu=on" 
    "iommu=pt" 
    "pcie_aspm=off" 
  ];

  # --- FIXED: SINGLE DEFINITION OF MODPROBE CONFIG ---
# akasis-ac_vs2583.nix
  boot.extraModprobeConfig = ''
    # 1. Video loopback for OBS Virtual Camera
    options v4l2loopback exclusive_caps=1 card_label="OBS Virtual Camera" video_nr=10

    # 2. Audio priority: Forces motherboard/GPU to index 0 and 1
    # preventing the capture card from hijacking system output.
    options snd-hda-intel index=0,1
  '';

  users.users.vulbyte.extraGroups = [ "video" "render" ];
}
