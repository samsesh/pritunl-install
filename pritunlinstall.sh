#!/bin/bash

check_if_running_as_root() {
    # If you want to run as another user, please modify $EUID to be owned by this user
    if [[ "$EUID" -ne '0' ]]; then
        echo "$(tput setaf 1)Error: You must run this script as root!$(tput sgr0)"
        exit 1
    else
        echo $(tput setaf 2)pritunl installing starting ...$(tput sgr0)
    fi
}

check_os() {
    # Get the operating system name and version
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)

    # Check if the OS is Ubuntu 20.04
    if [ "$OS" != "Ubuntu" ] || [ "$VERSION" != "20.04" ]; then
        echo "$(tput setaf 1)This script only works on Ubuntu 20.04$(tput sgr0)"
        exit 1
    fi
}

sysup() {
    bash <(curl -s https://raw.githubusercontent.com/samsesh/Ubuntu-Optimizer/main/ubuntu-optimizer.sh)
}

req() {
    sudo apt-get -qq install dialog figlet python3 -y >>/dev/null
    sleep 2
    clear
}

monogodaddsources() {
    sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list <<EOF
deb https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse
EOF
    sleep 2
    clear
}

pritunladdsources() {
    sudo tee /etc/apt/sources.list.d/pritunl.list <<EOF
deb http://repo.pritunl.com/stable/apt focal main
EOF
}

pritunladdgnupgkey() {
    sudo apt --assume-yes install gnupg
    gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
    gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | sudo tee /etc/apt/trusted.gpg.d/pritunl.asc
    sudo apt update
    sleep 2
    clear
}

mongodaddgnupgkey() {
    sudo apt-get --assume-yes install gnupg >>/dev/null
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    sleep 2
    clear
}

ubuntukeyadd() {
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
    sleep 2
    clear
}

updaterepo() {
    figlet "update repository"
    sudo apt-get -qq update >>/dev/null
    sleep 2
    clear
}

pritunlinstall() {
    figlet "install pritunl"
    sudo apt-get --assume-yes -qq install pritunl mongodb-org >>/dev/null
    sleep 2
    clear
}

mongodinstall() {
    figlet "install database "
    sudo apt-get --assume-yes -qq install mongodb-org >>/dev/null
    sleep 2
    clear
}

pritunlservice() {
    echo "run pritunl"
    sudo systemctl start pritunl mongod
    sleep 2
    clear
}

mongodservice() {
    echo "run database"
    sudo systemctl start mongod
    sleep 2
    clear
}

pritunlstartup() {
    sudo systemctl enable pritunl
    sleep 2
    clear
}

mongodstartup() {
    sudo systemctl enable mongod
    sleep 2
    clear
}

pritunlui() {
    #change ui

    figlet "update web interface"
    cd /tmp/pritunlinstall
    git clone https://github.com/samsesh/pritunl-ui.git ui
    cd ui
    chmod +x update.sh
    sudo bash update.sh
}

pritunlcrack() {
    #carck pritunl

    cd /tmp/pritunlinstall
    apt-get -qq install dialog -y >>/dev/null
    mkdir pritunlfakeapi
    cd pritunlfakeapi
    wget https://raw.githubusercontent.com/samsesh/Pritunl-Fake-API/master/server/setup.py
    chmod +x setup.py
    sudo python3 setup.py --install
}

pritunluse() {
    figlet "your pritunl setup key"
    pritunl setup-key
    echo "you can active your pritunl"
    echo "licens key : active ultimate"
    echo "Press any key to exit..."
    read -n 1 -s
    echo "Exiting..."
}

#run

startinstall() {
    sysup
    req
    mkdir -p /tmp/pritunlinstall
}
pritunlI() {
    pritunladdsources
    pritunladdgnupgkey
    ubuntukeyadd
    updaterepo
    pritunlinstall
    pritunlui
    pritunlcrack
    pritunlservice
    pritunlstartup
    pritunluse
}
mongodI() {
    monogodaddsources
    mongodaddgnupgkey
    updaterepo
    mongodinstall
    mongodservice
    mongodstartup
}

check_instaled_pritunl() {
    if command -v pritunl &>/dev/null; then
        echo $(tput setaf 2)pritunl is already installed on this system.$(tput sgr0)
        echo $(tput setaf 2)start crack and install new ui.$(tput sgr0)
        sysup
        pritunlui
        pritunlcrack
        exit 1
    else
        startinstall
        pritunlI
    fi
}

check_instaled_mongod() {
    if command -v mongo &>/dev/null; then
        echo $(tput setaf 2)MongoDB is already installed on this system.$(tput sgr0)
    else
        startinstall
        mongodI
    fi
}
check_os
check_if_running_as_root
check_instaled_mongod
check_instaled_pritunl
