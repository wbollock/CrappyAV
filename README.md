# CrappyAV

A terrible CLI AV. Grabs MD5 hashes of virus files and lets the user scan individual files to see if they match against known virus hashes.

![](img/crappyavheader.gif)

## Quarantine Malware

Take your suspected malware and shove it in a place where the son doesn't shine. CrappyAV will strip all permissions and put the file in virtual timeout.

![](img/hashcheck.gif)

## Usage

Run the script with:

```
./crappyav.sh
```

If you're using ZSH, you'll need to mapfile module.

```
zmodload zsh/mapfile
```

## Credits

Gifs made with [peek](https://github.com/phw/peek)

MD5 Hashes from [VirusShare](https://virusshare.com/hashes.4n6)

John Marks for allowing an open-ended final project!