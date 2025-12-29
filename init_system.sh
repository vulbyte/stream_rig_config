#!/bin/bash

# CONFIG



# VARS
TL=0;


# HELPERS/IMPORTS
source "./helpers.sh";

# file sued to create an ssh key and any other auth things needed

# GENERATE SSH KEY FOR GITHUB:
{
	TL=1;
	HELPERS_OPEN_URL "https://github.com/settings/keys";
	TL=0;
}
