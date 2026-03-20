{ config, lib, pkgs, modulesPath, ... }:

{
  # 1. ADD THIS BACK: Essential for CIFS/SMB
  environment.systemPackages = [ pkgs.ethtool pkgs.cifs-utils ];

  # ... (networking and services blocks remain the same) ...

  # Permanent Mount (SMB)
  fileSystems."/mnt/vulbytesShare" = {
    device = "//192.168.1.178/vulbytesShare";
    fsType = "cifs";
    options = let
      # Re-added x-systemd.requires=network.target
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,x-systemd.requires=network.target";
      
      # Ensure this path matches the actual file on your disk!
      # Usually, it's better to keep it as 'smb-secrets' (no .nix) 
      # so Nix doesn't try to evaluate it as code.
      creds = "/etc/nixos/smb-secrets.nix"; 
    in ["${automount_opts},credentials=${creds},uid=1000,gid=100,vers=3.11"];
  };
}
