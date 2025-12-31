#!/bin/bash



# CONFIG



# INIT
TL=0  # Tab level
USER=$(logname);
FOLDER_NAME="stream_rig_config"; 
SOURCE_LOCATION="/home/${USER}/${FOLDER_NAME}";
CONFIG_LOCATION="/etc/nixos";



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
source "${SOURCE_LOCATION}/helpers.sh"
source "${SOURCE_LOCATION}/checks.sh"
HELPERS_FANCY_PRINT "checking the needed auth and verification";



# RUN
HELPERS_FANCY_PRINT "all prechecks verified, installing the config";
TL=1;
HELPERS_FANCY_PRINT "attempting to move main config files into ${CONFIG_LOCATION}";
TL=2
rm -rf /etc/nixos/ 	# clear the dir
# 1. Clear and RECREATE the base directory
rm -rf "$CONFIG_LOCATION"
mkdir -p "$CONFIG_LOCATION"

HELPERS_FANCY_PRINT "Moving main config files..."
for file in "${SOURCE_LOCATION}/nix_config"/*; do
    sudo cp -r "$file" "$CONFIG_LOCATION/"
done

HELPERS_FANCY_PRINT "files in location, all checks passed, attemptnig to build os";
nixos-rebuild switch
