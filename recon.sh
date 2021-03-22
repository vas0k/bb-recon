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
domainsWithoutHttp=$reconDir"noHttp.txt"

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

# Remove those domains that may not belong in scope. Comment out if taking acquisitions into consideration.
cat $allDomains | grep $domain > $allDomains

echo "[+] All the domains.."
cat $allDomains

echo "[+] Gathering list of domains with HTTP servers"
cat $allDomains | httprobe > $activeDomainsWithHttp

echo "[+] Making a note of the domains running HTTP servers."
cat $activeDomainsWithHttp | while read line; do echo "$line" | cut -d "/" -f 3; done > $activeDomainsFile
cat $activeDomainsFile | sort -u > $reconDir"active.txt"

echo "[+] Gathering list of domains, that do not have HTTP servers running. This can be used for running nmap scans."
comm --check-order -23 $allDomains $activeDomainsFile > $domainsWithoutHttp

