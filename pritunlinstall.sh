#!/bin/bash

#update repo silent
echo "update repository"
sudo apt -qq update >> /dev/null
sleep 2
clear
#install figlet
install font
sudo apt -qq install figlet -y >> /dev/null
sleep 2
clear
#install pritunl
figlet "install Pritunl on ubuntu 20.04"
sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list << EOF
deb https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse
EOF
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb https://repo.pritunl.com/stable/apt focal main
EOF
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
sudo apt-get --assume-yes install gnupg >> /dev/null
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
figlet "update repository"
sudo apt -qq update >> /dev/null
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
figlet "install database and pritunl"
sudo apt-get --assume-yes -qq install pritunl mongodb-org >> /dev/null
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
figlet "run database and pritunl"
sudo systemctl start pritunl mongod 
sleep 2
clear

figlet "install Pritunl on ubuntu 20.04"
figlet "add to startup"
sudo systemctl enable pritunl mongod
sleep 2
clear

#mkdir on temp
cd /tmp
mkdir pritunlinstall

#change ui
figlet "update web interface"
cd /tmp/pritunlinstall
git clone https://github.com/samsesh/pritunl-ui.git ui
cd ui
chmod +x update.sh
sudo bash update.sh 

#carck pritunl
figlet "carck pritunl"
cd /tmp/pritunlinstall
apt -qq install dialog -y >> /dev/null
mkdir pritunlfakeapi
cd pritunlfakeapi
wget https://github.com/Simonmicro/Pritunl-Fake-API/raw/master/server/setup.sh 
chmod +x setup.sh
sudo bash setup.sh 
