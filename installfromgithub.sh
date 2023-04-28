#!/bin/bash

# Define function to print a loading message

ipcheck() {
    # Get the local IP address
    local_ip=$(hostname -I | awk '{print $1}')

    # Get the public IP addresses
    public_ipv4=$(curl -s https://api.ipify.org)
    public_ipv6=$(curl -6s https://api6.ipify.org)

    # Get the IPv6 address
    ipv6=$(ip -6 addr show dev eth0 | awk '/inet6/ {print $2}')

    # Check if the IPv6 address is assigned
    if [ -z "$ipv6" ]; then
        ipv6="$(tput setaf 2)Not assigned$(tput sgr0)" # Set the text to tput setaf 1 if not assigned
    fi

    # Display the IP addresses
    echo "IP Information:"
    echo "------------------------------------"
    echo "Local IP Address: $local_ip"
    echo "Public IPv4 Address: $public_ipv4"
    echo "Public IPv6 Address: $public_ipv6"
    echo "IPv6 Address: $ipv6"
    echo ""

}
check_root() {
    # If you want to run as another user, please modify $EUID to be owned by this user
    if [[ "$EUID" -ne '0' ]]; then
        echo "$(tput setaf 1)Error: You must run this script as root!$(tput sgr0)"
        exit 1
    else
        echo $(tput setaf 2)pritunl installing starting ...$(tput sgr0)
    fi
}
check_instaled() {
    # Check if Pritunl is installed
    pritunl_installed=$(which pritunl)

    if [[ -z $pritunl_installed ]]; then
        echo "Checking Pritunl installation"
        echo -e "\n$(tput setaf 1)✗ Pritunl is not installed.$(tput sgr0)"
    else
        echo "Checking Pritunl installation"
        echo -e "\n$(tput setaf 2)✔ Pritunl is already installed.$(tput sgr0)"
        exit
    fi

    # Check if MongoDB is installed
    mongodb_installed=$(which mongo)

    if [[ -z $mongodb_installed ]]; then
        echo "Checking MongoDB installation"
        echo -e "\n$(tput setaf 1)✗ MongoDB is not installed.$(tput sgr0)"
    else
        echo "Checking MongoDB installation"
        echo -e "\n$(tput setaf 2)✔ MongoDB is already installed.$(tput sgr0)"
    fi
    # Check if MongoDB is installed
    python3_installed=$(which python3)

    if [[ -z $mongodb_installed ]]; then
        echo "Checking python3 installation"
        echo -e "\n$(tput setaf 1)✗ python3 is not installed.$(tput sgr0)"
    else
        echo "Checking python3 installation"
        echo -e "\n$(tput setaf 2)✔ python3 is already installed.$(tput sgr0)"
    fi

}
installmongodb() {
    # Install MongoDB
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        echo "Unsupported operating system."
        exit 1
    fi

    if [[ $OS == "Ubuntu" && $VER == "20.04" ]] || [[ $OS == "Ubuntu" && $VER == "22.04" ]]; then
        # Install MongoDB for Ubuntu 20.04 and 22.04
        sudo apt update
        sudo apt install -y gnupg wget
        wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        sudo apt update
        sudo apt install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
    elif [[ $OS == "Ubuntu" && $VER == "18.04" ]] || [[ $OS == "Ubuntu" && $VER == "16.04" ]]; then
        # Install MongoDB for Ubuntu 18.04 and 16.04
        sudo apt update
        sudo apt install -y gnupg wget
        wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
        sudo apt update
        sudo apt install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
    elif [[ $OS == "CentOS Linux" && $VER == "7" ]] || [[ $OS == "CentOS Linux" && $VER == "8" ]] || [[ $OS == "Oracle Linux Server" && $VER == "7" ]] || [[ $OS == "Oracle Linux Server" && $VER == "8" ]] || [[ $OS == "Amazon Linux" && $VER == "2" ]]; then
        # Install MongoDB for CentOS 7 and 8, Oracle Linux 7 and 8, and Amazon Linux 2
        sudo yum install -y wget
        sudo wget -qO /etc/yum.repos.d/mongodb-org-5.0.repo https://repo.mongodb.org/yum/redhat/8/mongodb-org/5.0/x86_64/RPMS/mongodb-org-5.0.repo
        sudo yum install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
    elif [[ $OS == "Debian GNU/Linux" && $VER == "10" ]]; then
        # Install MongoDB for Debian 10
        sudo apt update
        sudo apt install -y gnupg wget
        wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
        sudo apt update
        sudo apt install -y mongodb-org
        sudo systemctl start mongod
        sudo systemctl enable mongod
    else
        echo "Unsupported operating system."
        exit 1
    fi
}

installpritunl() {
    mkdir -p /tmp/pritunlinstall

    # Determine the operating system
    os=""
    if [ -f /etc/redhat-release ]; then
        os=$(awk '{print $1}' /etc/redhat-release | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        os=$(awk -F'=' '/^DISTRIB_ID/{print tolower($2)}' /etc/lsb-release)
    elif [ -f /etc/os-release ]; then
        os=$(awk -F'=' '/^NAME/{print tolower($2)}' /etc/os-release | tr -d '"')
    elif [ -f /etc/alpine-release ]; then
        os="alpine"
    fi

    # Download and install Pritunl
    case "$os" in
    "centos")
        if [[ $(cat /etc/redhat-release) == *"release 7"* || $(cat /etc/redhat-release) == *"release 8"* ]]; then
            echo "Detected CentOS $os version $(cat /etc/redhat-release)"
            url="https://github.com/pritunl/pritunl/releases/download/1.30.3414.50/pritunl-1.30.3414.50-0.el7.x86_64.rpm"
            yum -y localinstall $url
        else
            echo "Unsupported CentOS version $(cat /etc/redhat-release)"
            exit 1
        fi
        ;;
    "ubuntu")
        if [[ $(lsb_release -r | awk '{print $2}') == "16.04" || $(lsb_release -r | awk '{print $2}') == "18.04" || $(lsb_release -r | awk '{print $2}') == "20.04" || $(lsb_release -r | awk '{print $2}') == "22.04" ]]; then
            echo "Detected Ubuntu $os version $(lsb_release -r | awk '{print $2}')"
            url="https://github.com/pritunl/pritunl/releases/download/1.30.3414.50/pritunl_1.30.3414.50-0_amd64.deb"
            wget $url -O pritunl.deb
            dpkg -i pritunl.deb
        else
            echo "Unsupported Ubuntu version $(lsb_release -r | awk '{print $2}')"
            exit 1
        fi
        ;;
    "oracle")
        if [[ $(cat /etc/oracle-release) == *"release 7"* || $(cat /etc/oracle-release) == *"release 8"* ]]; then
            echo "Detected Oracle Linux $os version $(cat /etc/oracle-release)"
            url="https://github.com/pritunl/pritunl/releases/download/1.30.3414.50/pritunl-1.30.3414.50-0.el7.x86_64.rpm"
            yum -y localinstall $url
        else
            echo "Unsupported Oracle Linux version $(cat /etc/oracle-release)"
            exit 1
        fi
        ;;
    "alpine")
        echo "Detected Alpine Linux $os version $(cat /etc/alpine-release)"
        apk add --no-cache curl
        url="https://github.com/pritunl/pritunl/releases/download/1.30.3414.50/pritunl_1.30.3414.50-0_alpine3.12.apk"
        curl -LO $url
        apk add --no-cache libstdc++ libcrypto1.1 libssl1.1
        apk add --allow-untrusted pritunl_1.30.3414.50-0_alpine3.12.apk
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
    esac

}
crack() {
    #carck pritunl
    echo "carcking"
    cd /tmp/pritunlinstall
    mkdir pritunlfakeapi
    cd pritunlfakeapi
    wget https://raw.githubusercontent.com/samsesh/Pritunl-Fake-API/master/server/setup.up.py
    chmod +x setup.up.py
    python3 setup.up.py --tput sgr0
    systemctl restart pritunl
    python3 setup.up.py --install
    systemctl restart pritunl
}

pritunlui() {
    #change ui
    echo "update web interface"
    cd /tmp/pritunlinstall
    git clone https://github.com/samsesh/pritunl-ui.git ui
    cd ui
    chmod +x update.sh
    bash update.sh
}

serivceup() {
    systemctl restart pritunl mongod
    systemctl enable pritunl mongod
}

pritunluse() {
    echo "your pritunl setup key"
    pritunl setup-key
    echo "you can active your pritunl"
    echo "licens key : active ultimate"
    ipcheck
    echo "Press any key to exit..."
    read -n 1 -s
    echo "Exiting..."
}
check_root
check_instaled
installmongodb
installpritunl
crack
pritunlui
serivceup
pritunluse
