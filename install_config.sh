#!/bin/bash



# CONFIG



# INIT
TL=0  # Tab level
USER=$(logname);
FOLDER_NAME="stream_rig_config"; 



# AUTH && VERIFY
TL=1 # Set indent level
echo "checking to see if has root perms"
if (( EUID != 0 )); then
    echo "run as sudo!"
    exit 1
else
    echo "user is not root, continuing";
fi



# HELPERS / imports
source "./helpers.sh"
source "./checks.sh"
# HELPERS_FANCY_PRINT "checking the needed auth and verification";



# RUN
HELPERS_FANCY_PRINT "all prechecks verified, installing the config";
TL=1;
HELPERS_FANCY_PRINT "attempting to move main config files into ${CONFIG_LOCATION}";
TL=2

CONFIG_LOCATION="/etc/nixos";
rm -rf "$CONFIG_LOCATION"
rm -rf "$CONFIG_LOCATION"
mkdir -p "$CONFIG_LOCATION"

SOURCE_LOCATION="/home/${USER}/${FOLDER_NAME}";
HELPERS_FANCY_PRINT "Moving main config files..."

# cp "~/stream_config_files/nix_config_files/configuration.nix" ${CONFIG_LOCATION}
# cp "~/stream_config_files/nix_config_files/hardware-configuration.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/configuration.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/hardware-configuration.nix" ${CONFIG_LOCATION}

cp "/home/vulbyte/stream_rig_config/nix_config_files/gpu-config.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/networking-config.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/kernel-config.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/sound-config.nix" ${CONFIG_LOCATION}
cp "/home/vulbyte/stream_rig_config/nix_config_files/smb-secrets.nix" ${CONFIG_LOCATION}

HELPERS_FANCY_PRINT "files in location, all checks passed, attemptnig to build os";
nixos-rebuild switch
