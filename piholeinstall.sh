#!/bin/bash
clear
figlet "installing pihole"
curl -sSL https://install.pi-hole.net | bash
cp external.conf /etc/lighttpd/
cp pihole-FTL.conf /etc/pihole/pihole-FTL.conf
service lighttpd restart