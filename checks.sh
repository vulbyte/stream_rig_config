# !/bin/bash

# PREFIX ALL FUNCTIONS WITH "CHECKS_" TO HELP WITH DEBUGGING

CHECKS_IS_SUDO(){
	TL=1 # Set indent level
	{
		HELPERS_FANCY_PRINT "checking to see if has root perms"
		if (( EUID != 0 )); then
		    TL=2 # Set indent level
		    HELPERS_FANCY_PRINT "This script must be run as root or with sudo!"
		    exit 1
		else
		    TL=2 # Set indent level
		    HELPERS_FANCY_PRINT "correct perms detected"
		fi
	}
	{
		# other code 
	}
	TL=0;
}

CHECK_PROGRAM_IS_INSTALLED(){
  # 'command -v' is POSIX compatible and efficient
  command -v "$1" >/dev/null 2>&1
}
