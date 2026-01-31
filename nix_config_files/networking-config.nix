{ config, lib, pkgs, modulesPath, ... }:

{
	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# users.users.vulbyte.extraGroups = [ "networkmanager" "wheel" "video" "render" ]; # NEW

	networking.hostName = "nixos"; # Define your hostname.
	#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;
	
	# SMB SERVER STUFF
	services.gvfs.enable = true;
	services.avahi = { # for airplay capture and smb
	  enable = true;
	  nssmdns4 = true; # Allows software to find .local devices
	  publish = {
	    enable = true;
	    userServices = true;
	  };
	};
	# Define the permanent mount
	fileSystems."/mnt/my_share" = {
		device = "//192.168.1.178/vulbytesShare";
		fsType = "cifs";
		options = let
		# These flags prevent the system from hanging if the server is offline
		automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
		in ["${automount_opts},credentials=/etc/nixos/smb-secrets.nix,uid=1000,gid=100,vers=3.0"];
	};
}
