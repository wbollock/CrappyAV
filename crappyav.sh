#!/bin/bash

#================================================================
#% SYNOPSIS
#+    CrappyAV
#%
#% DESCRIPTION
#%    A terrible CLI AV. Grabs MD5 hashes of virus files 
#%    and lets the user scan individual files to see if 
#%    they match against known virus hashes.
#%
#% USAGE
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#%
#================================================================
# Links:
# https://virusshare.com/hashes.4n6
# Okay, each link has 131,072 hashes. Each hash is it's own line

# Prerequisites:
# for zsh: zmodload zsh/mapfile
# for bash: mapfile should work in any version >4.0

# for developer: https://github.com/phw/peek

# Potential Problems: 
# array with 131072 values. Maybe kenny can help on that
# how to handle downloading all the files?
# how to get a goddamn test file

# TODO: log file. maybe log filename, hash of file, if file found, hashes tested,etc maybe ask user if they want to log?
# this will be a status page on a webserver


# CONFIG VALUES

hashDir=hashes

# for single hash file
hashfile=md5_hash
hashfileFixed=md5_hash_fixed

# used for chaning text color

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'
BOLD="\033[1m"
YELLOW='\033[0;33m'

# cat << "CrappyAV"
#  _______  _______  _______  _______  _______           _______          
# (  ____ \(  ____ )(  ___  )(  ____ )(  ____ )|\     /|(  ___  )|\     /|
# | (    \/| (    )|| (   ) || (    )|| (    )|( \   / )| (   ) || )   ( |
# | |      | (____)|| (___) || (____)|| (____)| \ (_) / | (___) || |   | |
# | |      |     __)|  ___  ||  _____)|  _____)  \   /  |  ___  |( (   ) )
# | |      | (\ (   | (   ) || (      | (         ) (   | (   ) | \ \_/ / 
# | (____/\| ) \ \__| )   ( || )      | )         | |   | )   ( |  \   /  
# (_______/|/   \__/|/     \||/       |/          \_/   |/     \|   \_/   
# CrappyAV




# 1. Download a metric shit ton of MD5 hashes
# or, well, one



downloadHashes(){

    echo -e "${RED}Please note downloading all of these hashes requires 1.1GB of disk space and bandwith.${NC}"
    echo "If you choose not to download all hashes, one 4.3MB file will be downloaded."
    echo ""
    sleep 1
    echo -e "${RED}Do you want to download all hashes? [y/N]${NC}"
    read -r hashChoice
    case $hashChoice in
    # N is bigger letter in prompt and therefore default, thats why "" is added to switch statement
		y|Y) allHashes ;;
		n|N|"") oneHash ;;
		*) echo -e "${RED}Error...${NC}" && sleep .5
	esac

}

allHashes(){
    echo "allHashes placeholder"
    sleep 1
    # can iterate easily through the links. https://virusshare.com/hashes/VirusShare_00001.md5
    # https://virusshare.com/hashes/VirusShare_00002.md5, etc
    # ends at 374

    for i in {1..374}
    do
        wget -O "$hashDir"/"$hashfile$i" https://virusshare.com/hashes/VirusShare_0000$i.md5
    done
 
}


oneHash(){
    
    echo "One hash file will be downloaded."
    sleep 1

    if [ ! -f "$hashDir"/"$hashfile" ]; then
    # hash file doesn't already exist, then download this
        wget -O "$hashDir"/"$hashfile" https://virusshare.com/hashes/VirusShare_00000.md5
    fi


    # Strip hashfile of the top header
    # thankfully all header lines started with #

    if [ ! -f "$hashDir"/"$hashfileFixed" ]; then
    # same deal, if hash file hasn't already been fixed don't do it again
        sed '/^#/ d' < "$hashDir"/"$hashfile" > "$hashDir"/"$hashfileFixed"
        rm -f "$hashDir"/"$hashfile"
        # clear up old hash file to save space
    fi
    # rmeove hashfile anyway
    rm -f "$hashDir"/"$hashfile"
    # this should be fine for just the single hash.

}





# DEBUG: remember to comment these out
# test number of array elements
#echo ${#hashArray[*]}

# test a random array element
#echo "${hashArray[1337]}"

# damn this worked great
# also worked in bash



# 3. Take user input on what file they want to see if it's malicious
hashCheck(){

# TODO:will need to check on amount on hash files downloaded...
# that will help know what file/files to compare against. maybe check to see amount of file in hashDir?

mapfile -t hashArray < "$hashDir"/"$hashfileFixed"
# above only works for 


echo -e "${BLUE}Hi user. Tell me what file you think is malware:${NC}"
# example: /home/wbollock/class/CrappyAV/testvirus.txt
read -r scaryVirus


# 4. Calculate MD5 hash of user file (hash should match downloaded ones)
# md5sum program used for this. should be installed on most *nix
# md5sum output: ed0335c6becd00a2276481bb7561b743  testvirus.txt
# I wish it would only print the hash.. man page wasn't helpful
# https://unix.stackexchange.com/questions/65932/how-to-get-the-first-word-of-a-string
fileHash=$(md5sum "$scaryVirus"  | head -n1 | awk '{print $1;}')

echo "Thanks for that. Doing some really smart algorithm..."
sleep 1

echo "File hash is: $fileHash"
# damn this works too. on a roll. hash is 32 characters






# 5. Compare hash of user file to my big list of hashes

for hash in "${hashArray[@]}"
do
 # compare fileHash to my big ass list
 if [ "$hash" == "$fileHash" ]; then
    echo -e "${RED}Match found! This wasn't supposed to happen. Wipe your drive."
 fi
 echo "$hash"
 # TODO: It'd be cool if this made a rainbow
done

echo -e "${RED}Our advanced blockchain neural-network AI didn't find anything wrong with the file. Proceed as normal!${NC}"

}

updateStatusPage(){
# 6. Optional: create a web status page of crappyav
# Include:
# Last time run
# Last file checked
# Amount of hashes downloaded
# Hash of last file checked
# Number of exploits found all time
echo "updateStatusPage Placeholder"
sleep 2
}

# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
deleteHashes(){

    echo -e "${RED}Alright, we will clear your hashes.${NC}"
    echo ""
    echo  -e "The hash directory has a size of ${BLUE}$(du -h $hashDir | head -n1 | awk '{print $1;}')${NC} and ${BLUE}$(ls -1 $hashDir | wc -l)${NC} file(s)."
    echo ""
    sleep 1
    echo -e "${RED}Really delete?${NC} [Y/n]"
    read -r delChoice
    case $delChoice in
    # N is bigger letter in prompt and therefore default, thats why "" is added to switch statement
		y|Y|"") rm -rf "${hashDir:?}/"* ;;
        # avoid deleting entire filesystem with question mark
        # https://github.com/koalaman/shellcheck/wiki/SC2115
        # if null it won't rm -rf /*
		n|N) echo "No files will be deleted."
        sleep 1 ;;
		*) echo -e "${RED}Error...${NC}" && sleep .5
	esac
        
}

# Menu Function
# Display list of options, start at top of decision tree
# Inspiration from https://bash.cyberciti.biz/guide/Menu_driven_scripts

show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
	echo -e "${RED}CrappyAV${NC}"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "Please select an option below:"
    echo ""
	echo "1) Download virus definitions"
	echo "2) Run hash list on a specific file"
	echo "3) Update the CrappyAV web status page"
    echo "4) Delete all hashe files from system"
    echo "5) Exit"
}
# Read options. Call another function from 1 or 2.
read_options(){
	local choice
    echo ""
	read -p "Please select a CrappyAV option: " choice
	case $choice in
		1) downloadHashes ;;
		2) hashCheck ;;
        3) updateStatusPage ;;
        4) deleteHashes ;;
		5) clear
           exit 0 ;;
		*) echo -e "${RED}Error...${NC}" && sleep .5
	esac
}

while true
do
	show_menus
	read_options
done
