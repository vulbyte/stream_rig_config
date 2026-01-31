# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./networking-config.nix
		./sound-config.nix
		./kernel-config.nix
		./gpu-config.nix
		#./flakes/flatpaks.nix	
	];


	# Bootloader.
	# boot.loader.grub.devices.enable = true;
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;


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

	programs.obs-studio = {
		enable = true;

		# optional Nvidia hardware acceleration
		# package = (
		# 	pkgs.obs-studio.override {
		# 		cudaSupport = true;
		# 	}
		# );

		plugins = with pkgs.obs-studio-plugins; [
			wlrobs
			obs-backgroundremoval
			obs-pipewire-audio-capture
			# obs-vaapi #optional AMD hardware acceleration
			obs-gstreamer
			obs-vkcapture
		];
	};



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

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.11"; # Did you read the comment?

}
