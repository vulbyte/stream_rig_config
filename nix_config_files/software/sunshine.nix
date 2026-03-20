# file for sunshine
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, lib, ... }:

{
  # 1. Disable the automatic 'catch-all' firewall rule
	services.sunshine = {
	  enable = true;
	  autoStart = true;
	  capSysAdmin = true; # Critical for encoder access
	  openFirewall = false;
	  # This ensures it runs in your user context
	  settings = {
	    # You can add sunshine.conf settings here if needed
	  };
	};
  ## 2. Open ONLY the mandatory ports for Moonlight to connect and stream
  #   # --- MOONLIGHT / SUNSHINE FIREWALL PORTS ---
  #networking.firewall = {
  #  enable = true;
  #  
  #  # TCP: Control stream, handshake, and web UI (if needed)
  #  # 47984, 47989: HTTPS/HTTP Control
  #  # 48010: RTSP (Stream Control)
  #  allowedTCPPorts = [ 47984 47989 48010 ];

  #  # UDP: The actual video/audio/input data
  #  # 47998-48000: Video & Audio bitstreams
  #  # 48002: Input (Keyboard/Mouse/Controller)
  #  # 48010: Control
  #  allowedUDPPorts = [ 47998 47999 48000 48002 48010 ];
  #};

  ## 3. Security wrapper for screen capture (Essential for Wayland/Intel Arc)
  #security.wrappers.sunshine = {
  #  owner = "root";
  #  group = "root";
  #  capabilities = "cap_sys_admin+ep";
  #  source = "${pkgs.sunshine}/bin/sunshine";
  #};

  # 4. Input rules for Moonlight controllers/mouse
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  # Ensure your GPU drivers are actually available to the service
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
