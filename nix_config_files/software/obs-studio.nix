
{ config, lib, pkgs, ... }:

{
	boot.kernelModules = [ 
		# "kvm-intel"    # for intel gpu support
		"v4l2loopback" # for obs virtual camera
	];

	# for obs-airplay
	networking.firewall = {
	  allowedTCPPorts = [ 7100 7000 7001 49152 49153 49154 ];
	  allowedUDPPorts = [ 7100 7000 7001 5353 49152 49153 49154 ];
	  allowedTCPPortRanges = [ { from = 32768; to = 61000; } ];
	  allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
	};

	services.avahi = {
	  enable = true;
	  nssmdns4 = true;
	  publish = {
	    enable = true;
	    addresses = true;
	    workstation = true;
	  };
	};

    programs.obs-studio = {
        enable = true;

        # optional Nvidia hardware acceleration
        # package = (
        #      pkgs.obs-studio.override {
        #          cudaSupport = true;
        #      }
        # );

        plugins = with pkgs.obs-studio-plugins; [
            obs-backgroundremoval
            obs-pipewire-audio-capture
            # obs-vaapi #optional AMD hardware acceleration
            obs-gstreamer
            obs-vkcapture
            wlrobs
        ];
    };

	environment.systemPackages = with pkgs; [
            # for obs airplay
            clang 
            pkg-config 
            openssl      # Replaces libssl-dev
            ffmpeg       # Replaces libswscale, libavcodec, libavformat, libavutil, libswresample
            avahi        # Replaces libavahi-compat-libdnssd-dev
            libplist     # Replaces libplist-dev
            fdk_aac      # Replaces libfdk-aac-dev
	];
}
