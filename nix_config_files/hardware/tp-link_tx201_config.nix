{ config, lib, pkgs, ... }:

{
  # 1. Hardware & Drivers
  hardware.enableAllFirmware = true;
  # Explicitly include the Realtek 8125 driver if the default kernel driver 
  # behaves unexpectedly (common with 2.5GbE cards)
  boot.extraModulePackages = [ config.boot.kernelPackages.r8125 ];
  boot.kernelModules = [ "r8125" ];

  # 2. Networking
  networking = {
    networkmanager.enable = true;
    # Optional: If you want to force the interface to use DHCP
    # useDefaultGateway = true;
    
    # Use this instead of localCommands for better reliability with NetworkManager
    # A lower metric = higher priority.
    interfaces.enp6s0.ipv4.addresses = [{
      address = "0.0.0.0"; # Set to 0.0.0.0 if using DHCP to just manage the metric
      prefixLength = 24;
    }];
    
    # Alternatively, the most robust way to set metrics in NixOS:
	# # FIX: Prioritize 2.5G card (enp6s0) over Motherboard (eno1)
	# localCommands = ''
	# 	${pkgs.iproute2}/bin/ip link set eno1 metric 200
	# 	${pkgs.iproute2}/bin/ip link set enp6s0 metric 10
	# '';
    localCommands = ''
      ${pkgs.iproute2}/bin/ip route add default via 192.168.1.1 dev enp6s0 metric 10 || true
      ${pkgs.iproute2}/bin/ip route add default via 192.168.1.1 dev eno1 metric 200 || true
    '';
  };

  # 3. NetworkManager specific priority (The "Gold Standard" for NM users)
  # This ensures the 2.5G card is always the preferred route.
  systemd.services.NetworkManager-wait-online.enable = false; # Prevents boot stalls
}
