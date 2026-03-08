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
	#hardware
	./tp-link_tx201_config.nix
	./tp-link_txe72e_config.nix
	./intel_b580-12gb_config.nix
	#software
	./firefox.nix
	./obs-studio.nix
	./sunshine.nix
	#./steam.nix
	./wine.nix
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
    services.xserver.enable = true;
    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;


    # KEYBOARD 
    # This enables the input method framework for the system
    i18n.inputMethod = {
      type = "maliit";
    };

    # This helps if SDDM is defaulting to a theme that doesn't support the keyboard toggle
    services.displayManager = {
        autoLogin = {
            enable = true;
            user = "vulbyte";
        }; # FIXED: Added semicolon
        sddm = { # FIXED: Typo was 'ssdm'
          theme = "breeze";
          enable = true;
          wayland.enable = true; # Recommended for Plasma 6
          # user = "vulbyte"; # Removed as it's redundant/invalid here
          settings = {
            General = {
              InputMethod = "qtvirtualkeyboard";
            };
          };
        };
    };

    # 3. The "Lock on Startup" Script
      # This runs as soon as your KDE session starts
      systemd.user.services.lock-on-startup = {
        description = "Lock the screen immediately after auto-login";
        wantedBy = [ "plasma-workspace-wayland.target" ];
        after = [ "plasma-workspace-wayland.target" ];
        serviceConfig = {
          Type = "oneshot";
          # This command tells KDE to lock the session
          ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/loginctl lock-session";
        };
      };




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
        v4l-utils # querying capture card exposed ports
        xvkbd #x11 onscrean keyboard
    ];

    # Important: Ensure you have 3D graphics enabled
    # hardware.graphics.enable = true;
    # hardware.graphics.enable32Bit = true;


    programs.nix-ld.enable = true;
        programs.nix-ld.libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
        glibc
    ];

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
