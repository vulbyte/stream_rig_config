{ config, pkgs, lib, ... }:

{
    environment.systemPackages = with pkgs; [
          #onscreen kbd testing
        onboard
          # For Mobile/Touch Interfaces (Phosh, Plasma Mobile)
        kdePackages.qtvirtualkeyboard  # This is the critical one for SDDM
        maliit-keyboard
        maliit-framework
    ];

    # KEYBOARD 
    # This enables the input method framework for the system
    i18n.inputMethod = {
      type = "maliit";
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
}
