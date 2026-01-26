# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
		#./flakes/flatpaks.nix	
	];

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

	# users.users.vulbyte.extraGroups = [ "networkmanager" "wheel" "video" "render" ]; # NEW
  	#boot.kernelParams = [ "i915.enable_guc=3" ];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Use latest kernel.
	boot.kernelPackages = pkgs.linuxPackages_latest;

	networking.hostName = "nixos"; # Define your hostname.
	#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	boot.kernelModules = [
	# get wifi drivers to work for Realtek Wifi RTL8852CE
	"rtw89_8852ce"
	];

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	# Set your time zone.
	time.timeZone = "America/Vancouver";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_CA.UTF-8";

	# Enable the X11 windowing system.
	# You can disable this if you're only using the Wayland session.
	services.xserver.enable = true;

	# Enable the KDE Plasma Desktop Environment.
	services.desktopManager.plasma6.enable = true;


# KEYBOARD 
# This enables the input method framework for the system
i18n.inputMethod = {
  type = "maliit";
};
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true; # Recommended for Plasma 6
  settings = {
    General = {
      InputMethod = "qtvirtualkeyboard";
    };
  };
};
# This helps if SDDM is defaulting to a theme that doesn't support the keyboard toggle
services.displayManager.sddm.theme = "breeze";

	# Configure keymap in X11
	services.xserver.xkb = {
		layout = "us";
		variant = "";
	};

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound with pipewire.
	# services.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		jack.enable = true;

		# use the example session manager (no others are packaged yet so this is enabled by default,
		# no need to redefine it in your config for now)
		#media-session.enable = true;
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

	# Enable touchpad support (enabled default in most desktopManager).
	# services.xserver.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.vulbyte = {
		isNormalUser = true;
		description = "vulbyte";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
	};

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

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
	  	#onscreen kbd testing
		onboard
		  # For Mobile/Touch Interfaces (Phosh, Plasma Mobile)
		kdePackages.qtvirtualkeyboard  # This is the critical one for SDDM
		maliit-keyboard
		maliit-framework

		    # for obs airplay
		    clang 
		    pkg-config 
		    openssl      # Replaces libssl-dev
		    ffmpeg       # Replaces libswscale, libavcodec, libavformat, libavutil, libswresample
		    avahi        # Replaces libavahi-compat-libdnssd-dev
		    libplist     # Replaces libplist-dev
		    fdk_aac      # Replaces libfdk-aac-dev



		cifs-utils 
		discord # for collabs and stuff
		fastfetch
		freetype
		git
		glibc
		harfbuzz
		hyfetch # depends on fastfetch
		lact
		kdePackages.kate
		kdePackages.qtvirtualkeyboard
		maliit-keyboard
		maliit-framework
		mpv
		neovim
		obs-studio
		pciutils 
		qpwgraph
		stow # used to propigate config files
		steam-run # used to launch some applications like veado
		(makeDesktopItem {
			name = "veadotube-mini";
			desktopName = "veadotube mini";
			exec = "steam-run /home/vulbyte/Downloads/veadotube-mini-linux-x64/veadotube-mini";
			icon = "veado-display"; #can be a png path
			categories = ["AudioVideo"];
			terminal = false;
		})
		vim     
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
		v4l-utils # querying capture card exposed ports
		xvkbd #x11 onscrean keyboard
	];


	programs.nix-ld.enable = true;
		programs.nix-ld.libraries = with pkgs; [
		# Add any missing dynamic libraries for unpackaged programs
		# here, NOT in environment.systemPackages
		glibc
	];

	systemd.services.lact = {
		description = "intelGPU Control Daemon";
		after = ["multi-user.target"];
		wantedBy = ["multi-user.target"];
		serviceConfig = {
			ExecStart = "${pkgs.lact}/bin/lact daemon";
		};
		enable = true;
	};

	programs.obs-studio = {
		enable = true;

		# optional Nvidia hardware acceleration
		package = (
			pkgs.obs-studio.override {
				cudaSupport = true;
			}
		);

		plugins = with pkgs.obs-studio-plugins; [
			wlrobs
			obs-backgroundremoval
			obs-pipewire-audio-capture
			# obs-vaapi #optional AMD hardware acceleration
			obs-gstreamer
			obs-vkcapture
		];
	};
	# FOR VIRTUAL CAMERA SUPPORT
	# boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
	# boot.kernelModules = [ "v4l2loopback" ];



	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.11"; # Did you read the comment?

}
