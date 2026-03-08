# file for sunshine

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
      # 4. Sunshine Configuration
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true; # Necessary for Wayland screen capture
        openFirewall = true; # Automatically opens the required TCP/UDP ports
      };

}
