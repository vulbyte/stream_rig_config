{ config, pkgs, ... }:

let
  fhsBuilder = if pkgs ? buildFHSUserEnv then pkgs.buildFHSUserEnv else pkgs.buildFHSEnv;

  openSeeFaceEnv = fhsBuilder {
    name = "openseeface-run";
    targetPkgs = pkgs: with pkgs; [
      python312
      python312Packages.pip
      python312Packages.virtualenv
      # Graphics and Windowing (The missing pieces)
      libGL
      glib
      xorg.libX11
      xorg.libxcb      # Fixes libxcb.so.1
      xorg.libXext
      xorg.libXrender
      xorg.libXi
      dbus
      fontconfig
      freetype
      stdenv.cc.cc.lib
      git
    ];
    runScript = "bash";
  };

  vtube-tracker = pkgs.writeScriptBin "vtube-tracker" ''
    #!/usr/bin/env bash
    TRACKER_DIR="$HOME/OpenSeeFace"
    
    if [ ! -d "$TRACKER_DIR" ]; then
      echo "OpenSeeFace not found. Cloning repository..."
      ${pkgs.git}/bin/git clone https://github.com/emilianavt/OpenSeeFace "$TRACKER_DIR"
    fi

    cd "$TRACKER_DIR"

    if [ ! -d "env" ]; then
      echo "Setting up Python 3.12 virtual environment..."
      ${openSeeFaceEnv}/bin/openseeface-run -c "python3.12 -m venv env && source env/bin/activate && pip install onnxruntime opencv-python pillow numpy"
    fi

    echo "Starting OpenSeeFace Tracker..."
    # Using 'openseeface-run' ensures the libraries above are visible to the process
    ${openSeeFaceEnv}/bin/openseeface-run -c "source env/bin/activate && python facetracker.py -W 1280 -H 720 --discard-after 0 --scan-every 0 --no-3d-adapt 1 --max-feature-updates 900 -c 0"
  '';
in
{
  environment.systemPackages = [
    vtube-tracker
  ];
}
