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

# Potential Problems: 
# array with 131072 values. Maybe kenny can help on that
# how to handle downloading all the files?
# how to get a goddamn test file

# TODO: log file. maybe log filename, hash of file, if file found, hashes tested,etc maybe ask user if they want to log?

# CONFIG VALUES
hashfile=md5_hash
hashfileFixed=md5_hash_fixed

# used for chaning text color

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'
BOLD="\033[1m"
YELLOW='\033[0;33m'

cat << "CrappyAV"
 _______  _______  _______  _______  _______           _______          
(  ____ \(  ____ )(  ___  )(  ____ )(  ____ )|\     /|(  ___  )|\     /|
| (    \/| (    )|| (   ) || (    )|| (    )|( \   / )| (   ) || )   ( |
| |      | (____)|| (___) || (____)|| (____)| \ (_) / | (___) || |   | |
| |      |     __)|  ___  ||  _____)|  _____)  \   /  |  ___  |( (   ) )
| |      | (\ (   | (   ) || (      | (         ) (   | (   ) | \ \_/ / 
| (____/\| ) \ \__| )   ( || )      | )         | |   | )   ( |  \   /  
(_______/|/   \__/|/     \||/       |/          \_/   |/     \|   \_/   
CrappyAV

echo ""
echo -e "${RED}CrappyAV: A Will Bollock Producton${NC}"


# 1. Download a metric shit ton of MD5 hashes
# or, well, one
# TODO: give user chance to download all of them if they want?

if [ ! -f "$hashfile" ]; then
# hash file doesn't already exist, then download this
    wget -O $hashfile https://virusshare.com/hashes/VirusShare_00000.md5
fi


# Strip hashfile of the top header
# thankfully all header lines started with #

if [ ! -f $hashfileFixed ]; then
# same deal, if hash file hasn't already been fixed don't do it again
    sed '/^#/ d' < $hashfile > $hashfileFixed
fi

# 2. Put MD5 hashes into a usable form I can test files against

mapfile -t hashArray < $hashfileFixed


# DEBUG: remember to comment these out
# test number of array elements
#echo ${#hashArray[*]}

# test a random array element
#echo "${hashArray[1337]}"

# damn this worked great
# also worked in bash



# 3. Take user input on what file they want to see if it's malicious

echo ""
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






# 6. Tell user if their file is a virus or not!








# 7. Optional: create a web status page of crappyav
# Include:
# Last time run
# Last file checked
# Amount of hashes downloaded
# Hash of last file checked
# Number of exploits found all time