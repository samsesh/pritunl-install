#!/bin/bash

# Define function to print a loading message
function print_loading {
    echo -n "$(tput setaf 6)$1$(tput sgr0)"
    while true; do
        echo -n "$(tput setaf 7).$(tput sgr0)"
        sleep 0.5
    done
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
    # Define list of supported OSes
    supported_os=("arch" "AmazonLinux2" "CentOS7" "CentOS8" "DebianBuster" "OracleLinux7" "OracleLinux8" "Ubuntu16" "Ubuntu18" "Ubuntu20" "Ubuntu22")

    # Check if current OS is supported
    current_os=$(grep -oP '(?<=^ID=)[^"\047]+|^ID_LIKE=\K\S+' /etc/os-release | tr -d '"\047')
    if [[ "${supported_os[@]}" =~ "${current_os}" ]]; then
        print_loading "Checking OS support"
        echo -e "\n$(tput setaf 2)✔ Your OS is supported.$(tput sgr0)"
    else
        print_loading "Checking OS support"
        echo -e "\n$(tput setaf 1)✗ Your OS is not supported.$(tput sgr0)"
        exit
    fi

    # Check if Pritunl is installed
    pritunl_installed=$(which pritunl)

    if [[ -z $pritunl_installed ]]; then
        print_loading "Checking Pritunl installation"
        echo -e "\n$(tput setaf 1)✗ Pritunl is not installed.$(tput sgr0)"
    else
        print_loading "Checking Pritunl installation"
        echo -e "\n$(tput setaf 2)✔ Pritunl is already installed.$(tput sgr0)"
        exit
    fi

    # Check if MongoDB is installed
    mongodb_installed=$(which mongo)

    if [[ -z $mongodb_installed ]]; then
        print_loading "Checking MongoDB installation"
        echo -e "\n$(tput setaf 1)✗ MongoDB is not installed.$(tput sgr0)"
    else
        print_loading "Checking MongoDB installation"
        echo -e "\n$(tput setaf 2)✔ MongoDB is already installed.$(tput sgr0)"
    fi

}

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
        ipv6="$(tput setaf 2)Not assigned$(tput sgr0)" # Set the text to red if not assigned
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

UbuntuOptimizer() {
    bash <(curl -s https://raw.githubusercontent.com/samsesh/Ubuntu-Optimizer/main/ubuntu-optimizer.sh)
}

install() {
    # Define functions for each supported operating system
    arch() {
        tee -a /etc/pacman.conf <<EOF
[pritunl]
Server = https://repo.pritunl.com/stable/pacman
EOF

        pacman-key --keyserver hkp://keyserver.ubuntu.com -r 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        pacman-key --lsign-key 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        pacman -Sy
        pacman -S --noconfirm pritunl dialog python3
    }

    AmazonLinux2() {
        tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        tee /etc/yum.repos.d/pritunl.repo <<EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2/
gpgcheck=1
enabled=1
EOF

        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A >key.tmp
        rpm --import key.tmp
        rm -f key.tmp
        yum -y install pritunl mongodb-org dialog python3
    }

    CentOS7() {
        tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        tee /etc/yum.repos.d/pritunl.repo <<EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/7/
gpgcheck=1
enabled=1
EOF

        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A >key.tmp
        rpm --import key.tmp
        rm -f key.tmp
        yum -y install pritunl mongodb-org dialog python3
    }

    CentOS8() {
        tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        tee /etc/yum.repos.d/pritunl.repo <<EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/8/
gpgcheck=1
enabled=1
EOF

        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A >key.tmp
        rpm --import key.tmp
        rm -f key.tmp
        yum -y install pritunl mongodb-org dialog python3
    }

    DebianBuster() {
        tee /etc/apt/sources.list.d/mongodb-org-6.0.list <<EOF
deb https://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main
EOF

        tee /etc/apt/sources.list.d/pritunl.list <<EOF
deb https://repo.pritunl.com/stable/apt buster main
EOF

        apt --assume-yes install gnupg
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
        apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        apt update
        apt --assume-yes install pritunl mongodb-org dialog python3
    }

    OracleLinux7() {
        tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        tee /etc/yum.repos.d/pritunl.repo <<EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/7/
gpgcheck=1
enabled=1
EOF

        yum -y install oracle-epel-release-el7
        yum-config-manager --enable ol7_developer_epel
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A >key.tmp
        rpm --import key.tmp
        rm -f key.tmp
        yum -y install pritunl mongodb-org dialog python3
    }

    OracleLinux8() {
        tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

        tee /etc/yum.repos.d/pritunl.repo <<EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/8/
gpgcheck=1
enabled=1
EOF

        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A >key.tmp
        rpm --import key.tmp
        rm -f key.tmp
        yum -y install pritunl mongodb-org dialog python3
    }

    Ubuntu18() {
        UbuntuOptimizer
        tee /etc/apt/sources.list.d/mongodb-org-4.4.list <<EOF
deb https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse
EOF

        tee /etc/apt/sources.list.d/pritunl.list <<EOF
deb https://repo.pritunl.com/stable/apt bionic main
EOF

        apt-get --assume-yes install gnupg
        wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
        apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        apt-get update
        apt-get --assume-yes install pritunl mongodb-org dialog
    }

    Ubuntu20() {
        UbuntuOptimizer
        tee /etc/apt/sources.list.d/mongodb-org-6.0.list <<EOF
deb https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse
EOF

        tee /etc/apt/sources.list.d/pritunl.list <<EOF
deb https://repo.pritunl.com/stable/apt focal main
EOF

        apt --assume-yes install gnupg
        wget -qO- https://www.mongodb.org/static/pgp/server-6.0.asc | tee /etc/apt/trusted.gpg.d/mongodb-org-6.0.asc
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | tee /etc/apt/trusted.gpg.d/pritunl.asc
        apt update
        apt --assume-yes install pritunl mongodb-org dialog python3
    }

    Ubuntu22() {
        UbuntuOptimizer
        tee /etc/apt/sources.list.d/mongodb-org-6.0.list <<EOF
deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse
EOF

        tee /etc/apt/sources.list.d/pritunl.list <<EOF
deb https://repo.pritunl.com/stable/apt jammy main
EOF

        apt --assume-yes install gnupg
        wget -qO- https://www.mongodb.org/static/pgp/server-6.0.asc | tee /etc/apt/trusted.gpg.d/mongodb-org-6.0.asc
        gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
        gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | tee /etc/apt/trusted.gpg.d/pritunl.asc
        apt update
        apt --assume-yes install pritunl mongodb-org dialog python3
    }

    # Get the name of the operating system
    os_name=$(lsb_release -si | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

    # Check if the operating system is supported and call the corresponding function
    if declare -f "$os_name" >/dev/null; then
        $os_name
    else
        echo "Your operating system (${os_name}) is not supported."
    fi
}
