{ pkgs, ... }:

let
  vtsSrc = "/home/vulbyte/Games/VTubeStudio"; 
  osfSrc = "/home/vulbyte/Games/OpenSeeFace";

  # Use buildFHSEnv instead of buildFHSUserEnv
  vtsEnv = pkgs.buildFHSEnv {
    name = "vts-fhs-env";
    targetPkgs = pkgs: with pkgs; [
      wineWowPackages.stable
      winetricks
      mesa
      libGL
      xorg.libX11
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXrandr
      vulkan-loader
      (python311.withPackages (ps: with ps; [ 
        opencv4 
        numpy 
        pillow 
        onnxruntime 
      ]))
      udev
      dbus
      libusb1
      pkg-config
    ];
  };

  launcherScript = pkgs.writeShellScriptBin "vtube-launcher" ''
    echo "Starting OpenSeeFace tracker..."
    # Execute the tracker inside the FHS env
    ${vtsEnv}/bin/vts-fhs-env -c "cd ${osfSrc} && python facetracker.py -c 0 --port 20202" &
    TRACKER_PID=$!

    echo "Starting VTube Studio..."
    # Execute VTS inside the FHS env
    ${vtsEnv}/bin/vts-fhs-env -c "cd ${vtsSrc} && wine 'VTube Studio.exe'"

    kill $TRACKER_PID
  '';

in
{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "vtube-studio-wrapped";
      paths = [ launcherScript ];
      postBuild = ''
        mkdir -p $out/share/applications
        ln -s ${pkgs.makeDesktopItem {
          name = "vtube-studio";
          desktopName = "VTube Studio";
          exec = "vtube-launcher";
          icon = "video-display";
          categories = [ "Video" "Utility" ];
        }}/share/applications/* $out/share/applications/
      '';
    })
  ];
}
