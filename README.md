# pritunl-install
## auto install and carck pritunl 
> just run this code 
``` bash
bash <(curl -sSL https://github.com/samsesh/pritunl-install/raw/Localhost/pritunlinstall.sh)
```
> just run this code with tmux
``` bash
git clone https://github.com/samsesh/pritunl-install.git && cd pritunl-install && tmux new -s pritunl-install 'sudo bash pritunlinstall.sh' 
```
> [pritunl api](https://github.com/royalhaze/pritunl-private-api)
---
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
---
## warp
- We use warp so that we are inside the cloudflare network and the IP address of the server is not leaked and remains clean.
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
> Note: This feature is not recommended for more than 10-20 users and it causes a decrease in speed
---
