{ config, pkgs, lib, ... }:

{
    environment.systemPackages = with pkgs; [
        steam-run # used to launch some applications like veado
        (makeDesktopItem {
            name = "veadotube-mini";
            desktopName = "veadotube mini";
            exec = "steam-run /home/vulbyte/Downloads/veadotube-mini-linux-x64/veadotube-mini";
            icon = "veado-display"; #can be a png path
            categories = ["AudioVideo"];
            terminal = false;
        })
    ];
}
