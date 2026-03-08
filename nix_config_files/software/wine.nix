# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
    environment.systemPackages = with pkgs; [
        #  wget wineWowPackages.stable
        # support 32-bit only
        wine
        # support 64-bit only
        (wine.override { wineBuild = "wine64"; })
        # support 64-bit only
        wine64
        # wine-staging (version with experimental features)
        wineWowPackages.staging
        # winetricks (all versions)
        winetricks
        # native wayland support (unstable)
        wineWowPackages.waylandFull
    ];
}
