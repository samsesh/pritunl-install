#!/bin/bash
clear
figlet "installing pihole"
curl -sSL https://install.pi-hole.net | bash
cd /tmp/pihole-dns/
cp /tmp/pihole-dns/pihole-dns/external.conf /etc/lighttpd/external.conf
cp /tmp/pihole-dns/pihole-dns/pihole-FTL.conf /etc/pihole/pihole-FTL.conf
service lighttpd restart
