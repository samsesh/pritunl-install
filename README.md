# pritunl-install
## auto install and carck pritunl on linux server
- just run this code 
``` bash
bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/install.sh)
```
---
- just run this code with tmux.
``` bash
apt update && apt -y install tmux && tmux new -s pritunl-install 'bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/install.sh)' 
```
>  It is better to use tmux so that if the ssh connection with the server is interrupted, the command will not be broken, If the connection is interrupted, you can return to the installation page with the following command after connecting to the server
```bash
tmux a -d -t pritunl
```
## how to uninstall ?
- uninstall pritunl
```bash
sudo apt-get --purge autoremove pritunl*
```
- uninstall mongoDB
```bash
sudo apt-get --purge autoremove mongo*
```
## DNS - pi-hole 
- You can use the pi-hole program to manage DNS requests, just match your server with the gateway address in the servers after installing DNS.
- I wrote a file here to install pihole, which instead of port 80 comes up on port 8000. To run it, just clone the project and execute the bash piholeinstall.sh command, which I have done step by step below.
1. clone project :
``` bash 
git clone https://github.com/samsesh/pritunl-install.git
```
2. Go to the project directory :
``` bash 
cd pritunl-install
```
3. run piholeinstall.sh 
``` bash
bash piholeinstall.sh 
```
> To know more about the pi-hole project, you can check their website from [this link](https://pi-hole.net/), [vpn docs](https://docs.pi-hole.net/guides/vpn/openvpn/overview/), [Github](https://github.com/pi-hole)

## cfwarp
- We use cfwarp so that we are inside the cloudflare network and the IP address of the server is not leaked and remains clean.
- To use it, just do the following
1. clone project :
``` bash 
git clone https://github.com/samsesh/pritunl-install.git
```
2. Go to the project directory :
``` bash 
cd pritunl-install
```
3. run cfwarp.sh 
``` bash
bash cfwarp.sh 
```
> Note: This feature is not recommended for more than 10-20 users and it causes a decrease in speed - [cfwarp repository link](https://gitlab.com/rwkgyg/CFwarp/)

## ToDo
- [X] update installer for multi os
- [X] add uninstaller
- [ ] automate setup key and carck on web 

## Link
- [Pritunl Fake API](https://github.com/samsesh/Pritunl-Fake-API)
- [Pritunl unofficial api and documentation](https://github.com/royalhaze/pritunl-private-api)
- [Pritunl documentation](https://docs.pritunl.com/)
- [Pritunl custom ui](https://github.com/samsesh/pritunl-ui)
- [Pi-Hole web-site](https://pi-hole.net/)
- [Pi-Hole documentation ](https://docs.pi-hole.net/)
- [Pi-Hole on Github](https://github.com/pi-hole)
- [Ubuntu Optimizer](https://github.com/samsesh/Ubuntu-Optimizer)
- [cfwarp repository link](https://gitlab.com/rwkgyg/CFwarp/)
