
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Useful for Steam Link/iPhone
      dedicatedServer.openFirewall = true; # Useful for discovery
    };
}
    

