#!/bin/bash



# CONFIG



# INIT
TL=0  # Tab level

# HELPERS / imports
source "./helpers.sh";
source "./checks.sh";



# AUTH && VERIFY
HELPERS_FANCY_PRINT "checking the needed auth and verification";
TL=1 # Set indent level
HELPERS_FANCY_PRINT "checking to see if has root perms"
if (( EUID != 0 )); then
    TL=2 # Set indent level
    HELPERS_FANCY_PRINT "This script must be run as root or with sudo!"
    exit 1
else
    TL=2 # Set indent level
    HELPERS_FANCY_PRINT "correct perms detected"
fi
TL=0;



# RUN
HELPERS_FANCY_PRINT "all prechecks verified, installing the config";
TL=1;
HELPRS_FANCY_PRINT "attempting to move main config files into ${CONFIG_LOCATION}";
TL=2
CONFIG_LOCATION="/etc/nixos"
HELPERS_FANCY_PRINT ""
for file in "./nix_config_files"/*; do
	rm -rf /etc/nixos/ 	# clear the dir
	# GET FILES AND PUT IN RIGHT SPOT
	cp file ${CONFIG_LOCATION}/
done
TL=1

HELPRS_FANCY_PRINT "attempting to move flakes into ${CONFIG_LOCATION}";
TL=2
FLAKE_LOCATION="/etc/nixos/flakes"
HELPERS_FANCY_PRINT ""
for file in "./nix_config_files/flakes"/*; do
	rm -rf /etc/nixos/ 	# clear the dir
	# GET FILES AND PUT IN RIGHT SPOT
	cp file ${FLAKE_LOCATION}/
done
TL=1

HELPERS_FANCY_PRINT "files in location, all checks passed, attemptnig to build os";
#nixos-switch build
