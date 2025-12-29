# !/bin/bash

# PREFIX ALL FUNCTIONS WITH "HELPER_" TO HELP WITH DEBUGGING

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
	#!/bin/bash
	URL=$1

	# Try various commands based on the operating system
	if command -v xdg-open >/dev/null; then
	    xdg-open "$URL" &
	elif command -v open >/dev/null; then
	    open "$URL" &
	elif command -v start >/dev/null; then
	    start "$URL" &
	elif command -v sensible-browser >/dev/null; then
	    sensible-browser "$URL" &
	elif command -v x-www-browser >/dev/null; then
	    x-www-browser "$URL" &
	elif command -v firefox >/dev/null; then
	    firefox "$URL" &
	elif command -v google-chrome >/dev/null; then
	    google-chrome "$URL" &
	else
	    echo "Can't find a command to open the browser"
	fi
}

HELPERS_IS_PROGRAM_INSTALLED(){
	# HELPERS_IS_PROGRAM_INSTALLED ssh-keygen
	command -v "$1" >/dev/null 2>&1
}
