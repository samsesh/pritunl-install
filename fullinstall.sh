#!/bin/bash
#install pritunl
sudo sh pritunlinstall.sh

# install pihole dns server
cd /tmp/pihole-dns/
chmod +x piholeinstall.sh 
sudo bash piholeinstall.sh 

