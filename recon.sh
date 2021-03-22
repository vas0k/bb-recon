#!/bin/bash

## This script requires Docker to be pre-installed.
## CRT.sh taken from https://github.com/tdubs/crt.sh

domain="$1"

reconDir=$domain'/recon/'

if [[ "$domain" == "" ]]
then
echo "Please enter the domain."
echo "Usage: ./recon.sh <domain>"
exit
fi

if [[ -d $domain ]]
then
rm -rf $domain
fi

mkdir $domain
mkdir $reconDir

if [[ ! -d crt/ ]]
then
git clone https://github.com/tdubs/crt.sh
mv crt.sh/ crt/
mv crt/crt.sh .
else
echo "crt.sh already exists. Using this script."
fi

domain="$1"
allDomains=$reconDir"allDomains.txt"
activeDomainsFile=$reconDir"active.txt"
activeDomainsWithHttp=$reconDir"activeHttp.txt"

echo "[+] Gathering subdomains from crt.sh"
./crt.sh $domain
mv crt/domains.txt $allDomains

echo "[+] Gathering subdomains from assetfinder"
assetfinder $domain >> $allDomains

echo "[+] Gathering subdomains from sublist3r"
sublist3r -d $domain -o $reconDir"sublister.txt"
cat $reconDir"sublister.txt" >> $allDomains

cat $allDomains | sed 's/<BR>/\n/g' > $reconDir"enum.txt"
cat $reconDir"enum.txt" | sort -u > $allDomains

echo "[+] All the domains.."
cat $allDomains
