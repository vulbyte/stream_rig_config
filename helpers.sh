# !/bin/bash

# PREFIX ALL FUNCTIONS WITH "HELPER_" TO HELP WITH DEBUGGING



HELPER_GET_INPUT_AND_VERIFY(){ # prompt $1
	# HOW TO CALL IT:
	# user_name=$(HELPER_GET_INPUT_AND_VERIFY "Enter your username")
	# echo "Welcome, $user_name"
	local can_continue=false
	local input=""
	local verify=""

	while [[ "$can_continue" != "true" ]]; do
	# Get input
	# Use -p with read to show the prompt on the same line
	read -p "$1: " input

	# Validate
	read -p "You entered '${input}', is this right? (y/n): " verify

	# Check verification
	if [[ "$verify" == "y" ]]; then
		can_continue=true
		else
		echo -e "Information incorrect, please try again or Ctrl+C to cancel\n"
	fi
	done

	# "Return" the value by echoing it
	echo "$input"
}



HELPERS_FANCY_PRINT(){
    local tabs_to_insert=""
    if (( TL <= 0 )); then 
	echo -e "$1"
	return 0
    fi
    for ((i=0; i < TL; i++)); do
	tabs_to_insert+="\t"
    done 
    # Use -e to interpret the \t escape sequence
    echo -e "${tabs_to_insert}${1}"
}

HELPERS_OPEN_URL(){
	xdg-open $1;
} 


HELPERS_IS_PROGRAM_INSTALLED(){
	# HELPERS_IS_PROGRAM_INSTALLED ssh-keygen
	command -v "$1" >/dev/null 2>&1
}
