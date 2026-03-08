{ config, lib, pkgs, ... }:

{
  # 1. Provide the r8125 driver (better than the default r8169 for 2.5G)
  boot.extraModulePackages = [ 
    config.boot.kernelPackages.r8125 
  ];

  # 2. Blacklist the default driver so they don't fight
  boot.blacklistedKernelModules = [ "r8169" ];
  
  # 3. Load the correct driver at boot
  boot.kernelModules = [ "r8125" ];

  # 4. Networking performance tweaks for 2.5Gbps
  boot.kernel.sysctl = {
    # Increase TCP window sizes for higher bandwidth
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    # Help with packet processing at high speeds
    "net.core.netdev_max_backlog" = 5000;
  };

  # 5. Ensure firmware is available
  hardware.enableAllFirmware = true; 
}
