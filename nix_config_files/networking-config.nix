{ config, lib, pkgs, modulesPath, ... }:

{
#   networking = {
#     hostName = "nixos";
#     networkmanager = {
#       enable = true;
#       wifi.backend = "iwd";
#       # Give the 2.5G card priority over Wi-Fi
#       connectionConfig."connection.autoconnect-priority" = 100;
#     };
#     
#     # Use iwd for better MediaTek support
#     wireless.iwd.enable = true;
# 
#     # FIX: Solve "can't visit every website" (DNS & IPv6 issues)
#     nameservers = [ "1.1.1.1" "8.8.8.8" ];
#     enableIPv6 = false;
#   };
# 
# 
#   # Helper tool for hardware negotiation
#   environment.systemPackages = [ pkgs.ethtool ];
# 
#   # Force the 2.5G card to wake up and negotiate properly
#   systemd.services.init-enp6s0 = {
#     description = "Force 2.5G card negotiation";
#     after = [ "network.target" ];
#     wantedBy = [ "multi-user.target" ];
#     script = ''
#       ${pkgs.iproute2}/bin/ip link set enp6s0 up
#       ${pkgs.ethtool}/bin/ethtool -r enp6s0
#     '';
#   }; 
}
