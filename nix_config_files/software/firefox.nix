# firefox 


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
    programs.firefox = {
        enable = true;
        policies = {
            ExtensionSettings = {
                # Bitwarden
                "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
                    installation_mode = "force_installed";
                };
                # Sponser Block
                "sponsorBlocker@ajay.app" = {
                    install_url = "https://addons.mozilla.org/en-CA/firefox/addon/sponsorblock/";
                    installation_mode = "force_installed";
                };
                # uBlock Origin
                "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                };
                # Add more extensions here using the same format
            };
        };
    };
}
