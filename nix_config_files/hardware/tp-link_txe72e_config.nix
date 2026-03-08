{ config, lib, pkgs, ... }:

{
  # 1. Enable WiFi and Bluetooth support
  networking.wireless.iwd.enable = true; # IWD is faster/more modern than wpa_supplicant for WiFi 6E
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true; # Enables better battery reporting and LE Audio
    };
  };

  # 2. Intel AX210 Specific Tweaks
  boot.kernelModules = [ "iwlwifi" ];
  
  # 3. Kernel Parameters for Stability
  # High-speed cards sometimes struggle with power management "hiccups"
  boot.kernelParams = [
    "iwlwifi.uapsd_disable=1"    # Disable power saving that can cause lag spikes
    "iwlwifi.power_save=0"      # Maximum performance
  ];

  # 4. Critical: Firmware and Regulatory Domain
  # WiFi 6E (6GHz) is often disabled if the kernel doesn't know your country's laws
  hardware.enableAllFirmware = true;
  
  # Set this to your ISO country code (e.g., "US", "CA", "GB")
  # This "unlocks" the 6GHz bands for your region
  networking.timeServers = [ "0.nixos.pool.ntp.org" ]; # Just a placeholder
  
  # Use this to set your country for the WiFi card
  # services.udev.extraRules = ''
  #   ENV{MODALIAS}=="v00008086d00002725*", RUN+="${pkgs.iw}/bin/iw reg set US"
  # '';
}
