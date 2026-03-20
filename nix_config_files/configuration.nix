# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

#needed for vtubestudio to allow the launch
# let
#   # Import the file and immediately give it the current pkgs
#   vtsLauncher = import ./vts-launcher.nix { inherit pkgs; };
# in
{
    imports = [ # Include the results of the hardware scan.
	#hardware
			./akasis-ac_vs2583.nix
			./tp-link_tx201_config.nix
			./tp-link_txe72e_config.nix
			./intel_b580-12gb_config.nix
			# ./kinect_v2.nix
	#software
			./firefox.nix
			./godot.nix
			./mediapipe_tracker.nix
			./obs-airplay.nix
			./obs-studio.nix
			./OpenSeeFace.nix
			#./steam.nix
			./sunshine.nix
			#./vTubeStudio.nix
			./veadotubemini.nix
			./virtual_keyboard.nix
			./wine.nix
	# misc
			# ./apfs.nix 
			# ./configuration.nix
			# ./gpu-config.nix DEPRECIATED
			./hardware-configuration.nix
			./kernel-config.nix
			# ./networking-config.nix DEPRECIATED
			# ./smb-secrets.nix DO NOT RUN THIS
			./sound-config.nix
			./unraidServerA.nix
    ];

    # This allows 'vulbyte' services to start on boot without a login
    systemd.tmpfiles.rules = [
      "L /var/lib/systemd/linger/vulbyte - - - - /dev/null"
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
    # services.xserver.enable = true;
    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;


    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.vulbyte = {
	isNormalUser = true;
	description = "vulbyte";
	extraGroups = [ "networkmanager" "wheel" "video" "render" "audio" ]; # Added render and audio
	packages = with pkgs; [];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        cifs-utils 
        # discord # discord audio keeps microresetting disconnecting audio, meaning we should use the web version instead
	fastfetch
        freetype
        git
        glibc
        harfbuzz
        hyfetch # depends on fastfetch
        lact
	usbutils
        kdePackages.kate
        kdePackages.qtvirtualkeyboard
        mpv
	nodejs
        neovim
        pciutils 
	#python3
        qpwgraph
        stow # used to propigate config files
        vim     
        v4l-utils # querying capture card exposed ports
	#vtsLauncher # for vTubeStudio
        xvkbd #x11 onscrean keyboard
    ];

	# environment.systemPackages = with pkgs; [
	#   # ... other system packages
	#   (python3.withPackages (python-pkgs: with python-pkgs; [
	#     pandas
	#     # Add other packages here
	#   ]))
	# ];

    # Important: Ensure you have 3D graphics enabled
    # hardware.graphics.enable = true;
    # hardware.graphics.enable32Bit = true;
    #programs.nix-ld.enable = true;
    #    programs.nix-ld.libraries = with pkgs; [
    #    # Add any missing dynamic libraries for unpackaged programs
    #    # here, NOT in environment.systemPackages
    #    glibc
    #];

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
