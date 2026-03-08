{ config, lib, pkgs, modulesPath, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      # Give the 2.5G card priority over Wi-Fi
      connectionConfig."connection.autoconnect-priority" = 100;
    };
    
    # Use iwd for better MediaTek support
    wireless.iwd.enable = true;

    # --- MOONLIGHT / SUNSHINE FIREWALL PORTS ---
    firewall = {
      enable = true;
      allowedTCPPorts = [ 47984 47989 48010 ];
      allowedUDPPorts = [ 47998 47999 48000 48002 48010 ];
    };

    # FIX: Prioritize 2.5G card (enp6s0) over Motherboard (eno1)
    localCommands = ''
      ${pkgs.iproute2}/bin/ip link set eno1 metric 200
      ${pkgs.iproute2}/bin/ip link set enp6s0 metric 10
    '';

    # FIX: Solve "can't visit every website" (DNS & IPv6 issues)
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    enableIPv6 = false;
  };

  # Services for Networking & SMB
  services.gvfs.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Helper tool for hardware negotiation
  environment.systemPackages = [ pkgs.ethtool ];

  # Force the 2.5G card to wake up and negotiate properly
  systemd.services.init-enp6s0 = {
    description = "Force 2.5G card negotiation";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.iproute2}/bin/ip link set enp6s0 up
      ${pkgs.ethtool}/bin/ethtool -r enp6s0
    '';
  };

  # Permanent Mount (SMB)
  fileSystems."/mnt/my_share" = {
    device = "//192.168.1.178/vulbytesShare";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets.nix,uid=1000,gid=100,vers=3.0"];
  };
}
