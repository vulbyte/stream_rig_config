
{ config, lib, pkgs, ... }:

{
    programs.obs-studio = {
        enable = true;

        # optional Nvidia hardware acceleration
        # package = (
        #      pkgs.obs-studio.override {
        #          cudaSupport = true;
        #      }
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
