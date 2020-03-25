#!/bin/bash

#================================================================
#% SYNOPSIS
#+    CrappyAV
#%
#% DESCRIPTION
#%    A terrible CLI AV. Grabs MD5 hashes of virus files 
#%    and lets the user scan files to see if 
#%    they match against known virus hashes.
#%
#% USAGE
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#%
#================================================================

# Potential Problems: 
# array with 131072 values. Maybe kenny can help on that
# how to get a goddamn test file

# TODO CHECKLIST:
# status page shit
# fix github screenshots/gifs, spelling mistakes and new updates




# CONFIG VALUES

hashDir=hashes

# for single hash file
hashfile=md5_hash
hashfileFixed=md5_hash_fixed
fullHashFile=hashlist.txt
fileJail=jail

# to have a file we can verify the checking mechanism against
virusTest=testvirus.txt
cleanTest=testclean.txt
# note that both files will really look like md5_hash_204_fixed after dl

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



# Download a metric shit ton of MD5 hashes
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
		n|N|"")  ;;
		*) echo -e "${RED}Error...${NC}" && sleep .5
	esac

}

allHashes(){
    echo "Downloading 374 hash files"
    sleep 1
    # can iterate easily through the links. https://virusshare.com/hashes/VirusShare_00001.md5
    # https://virusshare.com/hashes/VirusShare_00002.md5, etc
    # ends at 374

    #download all 374 hash files
    for i in {1..374}
    do
    # have to adjust url based on file number
        if ((i < 10 ))
        then
            wget -O $hashDir/"$hashfile"_$i https://virusshare.com/hashes/VirusShare_0000$i.md5
        elif ((i >= 10 && i < 100 ))
        then
            wget -O $hashDir/"$hashfile"_$i https://virusshare.com/hashes/VirusShare_000$i.md5
        elif ((i >= 100 ))
        then
            wget -O $hashDir/"$hashfile"_$i https://virusshare.com/hashes/VirusShare_00$i.md5
        fi

    done
 
    sleep 2
    echo -e "${RED}Trimming and combining files...${NC}"
    sleep 2
    # need to remove headers now
    for file in "${hashDir:?}/"*
    do
        sed '/^#/ d' < "$file" > "$file"_fixed
        rm "$file"
        cat "$file"_fixed >> $hashDir/$fullHashFile
        rm "$file"_fixed
        md5sum "$virusTest"  | head -n1 | awk '{print $1;}' >> $hashDir/$fullHashFile
    # hashlist.txt should be 1.1G
    done


}

# would be more work than it's worth allowing one file
# oneHashDL(){
    
#     echo "One hash file will be downloaded."
#     sleep 1

#     if [ ! -f "$hashDir"/"$hashfile" ]; then
#     # hash file doesn't already exist, then download this
#         wget -O "$hashDir"/"$hashfile" https://virusshare.com/hashes/VirusShare_00000.md5
#     fi

#     # Strip hashfile of the top header
#     # thankfully all header lines started with #
#     if [ ! -f "$hashDir"/"$hashfileFixed" ]; then
    
#         sed '/^#/ d' < "$hashDir"/"$hashfile" > "$hashDir"/"$hashfileFixed"
#         rm -f "$hashDir"/"$hashfile"
#         # clear up old hash file to save space
#     fi
    
#     rm -f "$hashDir"/"$hashfile"

# }

hashCheck(){
    echo -e "${BLUE}Hi user. Tell me what file you think is malware:${NC}"
    # example: /home/wbollock/class/CrappyAV/testvirus.txt
    read -r scaryVirus

    # 4. Calculate MD5 hash of user file (hash should match downloaded ones)
    # md5sum program used for this. should be installed on most *nix
    # md5sum output: ed0335c6becd00a2276481bb7561b743  testvirus.txt

    fileHash=$(md5sum "$scaryVirus"  | head -n1 | awk '{print $1;}')

    echo "Thanks for that. Doing some really smart algorithm..."
    sleep 1

    echo "File hash is: $fileHash"
    sleep 1

    # Compare hash of user file to my big list of hashes
    # 48fe63b00f90279979cc4ea85446351f  testclean.txt
    # ed0335c6becd00a2276481bb7561b743  testvirus.txt
    if [ -f "$hashDir"/"$fullHashFile" ]; then
        if grep -q "$fileHash" "$hashDir"/"$fullHashFile"; then
            echo -e "${RED}Match found! If you actually suspect this file is malicious, please .${NC}"
            echo ""
            echo -e "Would you like to quarantine ${RED}$scaryVirus${NC}?"
            echo -e "It will be moved to the folder ${BLUE}jail${NC} and stripped of all permissions. [y/N]"
            read -r quarChoice
            case $quarChoice in
                y|Y) sudo chmod 000 $scaryVirus
                     sudo mv "$scaryVirus" jail/
                     echo ""
                     echo -e "$scaryVirus has been moved to ${BLUE}jail${NC}."
                     sudo ls -l jail;;
                n|N|"") echo "$scaryVirus will not be quarantined."
                sleep 1 ;;
                *) echo -e "${RED}Error...${NC}" && sleep .5
            esac

        else
            echo -e "${BLUE}Yay! Your file is safe. Chmod 777 whatever you want.${NC}"
        fi
    else
        echo -e "${YELLOW} Oh no. Couldn't find any hashes. Did you download virus definitions?${NC}"
    fi

      if [ -f webflag ]; then
      # get file run against hashes
      sed -ri "s@<p(|\s+[^>]*)>Last file checked against hashes:(.*?)<\/p\s*>@<p>Last file checked against hashes: $scaryVirus</p>@g" crappyavweb/index.html
     fi

    sleep 3
    
    # this ate up all my ram
    # for hash in "${hashArray[@]}"
    # do
    # # compare fileHash to my big ass list
    # if [ "$hash" == "$fileHash" ]; then
    #     echo -e "${RED}Match found! This wasn't supposed to happen. Wipe your drive."
    # fi
    # echo "$hash"
    # # TODO: It'd be cool if this made a rainbow
    # done

}

updateStatusPage(){

    echo "Would you like to enable the web status page? [y/N]"
    echo -e "The page will exist at ${BLUE}crappyavweb/index.html${NC}"
    read -r webChoice
    # if yes, touch file that will act as a flag
    case $webChoice in
    # if webflag exists, other functions throw their data in index.html
		y|Y) touch webflag ;;
		n|N|"") rm -rf webflag  ;;
		*) echo -e "${RED}Error...${NC}" && sleep .5
	esac
# idea: have JS call bash script with different parameters
# if bash $1 = "lastrun", then script gets firstrun from webstats
# script echos only text from 

# terrible idea, JS and bash dont mix
# just have a second 



    # if webflag exists, then other functions will contribute to it?
    # Thoughts:
    # make a base template for webpage that then gets moved when flag added/"y" enabled
    # mv back the page to . when "n" is selected
    # if webflag exists, then when specific function is run, it somehow adds to the webpage

    
    # Include:
    # Last time run
    # Last file checked
    # Amount of hashes downloaded
    # Hash of last file checked
    # Number of exploits found all time

    # leave user choice to disable or enable server status page
    # probably with a flag file?

    # probably best to call a second script with parameters
    
    sleep 2
}


deleteHashes(){
    # don't be a dummy and parse ls. find is much bette
    echo  -e "The hash directory has a size of ${BLUE}$(du -h $hashDir | head -n1 | awk '{print $1;}')${NC} and ${BLUE}$(find $hashDir -type f | wc -l)${NC} file(s)."
    echo ""
    sleep 1
    echo -e "${RED}Really delete?${NC} [y/N]"
    read -r delChoice
    case $delChoice in
    # N is bigger letter in prompt and therefore default, thats why "" is added to switch statement
		y|Y) rm -rf "${hashDir:?}/"* ;;
        # avoid deleting entire filesystem with question mark
        # https://github.com/koalaman/shellcheck/wiki/SC2115
        # if null it won't rm -rf /*
		n|N|"") echo "No files will be deleted."
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
	echo "1) Download virus definitions (Recommended)"
	echo -e "2) Run hash list on a suspected ${RED}malware${NC}"
	echo -e "3) ${GREEN}Enable/Disable${NC} the CrappyAV web status page"
    echo "4) Delete all hash files from system"
    echo "5) Exit"

    # if web enabled, throw current date into index.html
     if [ -f webflag ]; then
    # on program run, get as many stats as I can from main page
     
     # uses @ as delimiter
     # <p(|\s+[^>]*)>Last time program ran:(.*?)<\/p\s*>
     # will match:
     # <p>Last time program ran:</p>
	#  <p>Last time program ran: Wed 25 Mar 2020 04:54:07 PM EDT</p>

        sed -ri "s@<p(|\s+[^>]*)>Last time program ran:(.*?)<\/p\s*>@<p>Last time program ran: $(date)</p>@g" crappyavweb/index.html
        
        sed -ri "s@<p(|\s+[^>]*)>Amount of hashes downloaded:(.*?)<\/p\s*>@<p>Amount of hashes downloaded: $(wc -l hashes/hashlist.txt | head -n1 | cut -d " " -f1)</p>@g" crappyavweb/index.html
        

        # get current files in jail    ls -1 jail | wc -l
        sed -ri "s@<p(|\s+[^>]*)>Number of files in jail:(.*?)<\/p\s*>@<p>Number of files in jail: $(ls -1 jail | wc -l)</p>@g" crappyavweb/index.html
        
     fi


}

# Read options. Call another function from choices
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

# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do
	show_menus
	read_options
done
