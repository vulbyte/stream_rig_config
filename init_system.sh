#!/bin/bash

# CONFIG



# VARS
TL=0;


# HELPERS/IMPORTS
source "./helpers.sh";


# FUNCTIONS


# GENERATE SSH KEY FOR GITHUB:
CREATE_SSH_KEY(){
    # 1. Define variables FIRST
    local ssh_file="$HOME/.ssh/id_ed25519"
    local pub_file="$HOME/.ssh/id_ed25519.pub"
    
    local un=$(HELPER_GET_INPUT_AND_VERIFY "What is your GitHub username?")
    local em=$(HELPER_GET_INPUT_AND_VERIFY "What is your GitHub email?")

    # 2. Check for existing keys
    if [ -f "$pub_file" ]; then
        local delete_choice=$(HELPER_GET_INPUT_AND_VERIFY "SSH key exists. Delete and create new? (y/n)")
        if [[ "$delete_choice" == "y" ]]; then
            rm "$ssh_file" "$pub_file"
            echo "Old keys removed."
        else
            echo "Keeping existing keys."
            # We don't return 0 here because we still want to cat the existing key below
        fi
    fi

    # 3. Create the key ONLY IF it doesn't exist now
    if [ ! -f "$pub_file" ]; then
        echo "Creating new SSH key..."
        ssh-keygen -t ed25519 -C "$em" -f "$ssh_file" -N ""
    fi

    # 4. Now cat will work because the path is correct and the file exists
    echo -e "\nCopy the following and paste it into your GitHub SSH config:\n"
    cat "$pub_file"
    echo -e "\n"

    HELPERS_OPEN_URL "https://github.com/settings/keys"

    local cont=""
    while [[ "$cont" != "continue" && "$cont" != "c" ]]; do
        cont=$(HELPER_GET_INPUT_AND_VERIFY "Add the key to GitHub, then type 'continue' or 'c' to finish")
    done
}
CREATE_SSH_KEY;



# update after install
#bash ./install_config.sh
