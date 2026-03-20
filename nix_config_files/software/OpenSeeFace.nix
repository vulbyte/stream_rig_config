# vseeface.nix
# NixOS configuration for running VSeeFace on Linux via Wine (64-bit).
#
# VSeeFace is a Windows-only app. On Linux it runs under Wine, but Wine cannot
# read webcams or USB devices (like Kinect) directly. The recommended solution
# is to run OpenSeeFace natively as a standalone tracker and have VSeeFace
# connect to it over the local network using the VMC/OpenSeeFace protocol.
#
# Import this in your configuration.nix:
#   imports = [ ./vseeface.nix ];

{ config, pkgs, lib, ... }:

{
  # ── System packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Wine (64-bit) — required to run VSeeFace.exe
    wineWowPackages.stable   # Includes both 32- and 64-bit Wine

    # winetricks — installs fonts and VC++ runtimes inside the Wine prefix
    winetricks

    # Lutris (optional but recommended GUI launcher for Wine games/apps)
    lutris

    # OpenSeeFace — native Linux face tracker for VSeeFace
    # All dependencies bundled into a single python3 environment so that
    # `python3` on PATH already has numpy, onnxruntime, opencv, etc.
    (python3.withPackages (ps: with ps; [
      numpy
      pillow
      onnxruntime
      opencv4
    ]))

    # Git — needed to clone OpenSeeFace
    git
  ];

  # ── OpenGL & GPU (required for VSeeFace rendering under Wine) ─────────────
  # NixOS 24.11+ replaced hardware.opengl with hardware.graphics.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Wine is often 32-bit internally; keep this on
  };
}
