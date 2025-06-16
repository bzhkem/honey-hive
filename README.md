# Argus

## Table of Contents
- **[Presentation](#presentation)**
  - [OpenCanary](#opencanary)
  - [Features](#features)
- **[Prerequisites](#prerequisites)**
  - [Required Materials](#required-materials)
  - [Install Pi4](#install-pi4)
  - [Configuration on Pi4](#configuration-on-pi4)
- **[Installation](#installation)**
  - [Docker Installation](#docker-installation)
  - [Opencanary Installation](#opencanary-installation)
    - [Git Clone](#git-clone)
    - [Executable](#executable)
- **[Customizations](#customizations)**
  - [Samba Share](#samba-share)
  - [Account Configuration](#account-configuration)
  - [MAC Spoofing](#mac-spoofing)
  - [Other](#other)
- **[Useful Commands](#useful-commands)**

## Presentation

**Argus** is developed by **Biznet.io** and is based on OpenCanary, which is a honeypot solution.

### OpenCanary

If you want to learn more about ([OpenCanary](https://github.com/thinkst/opencanary)), I recommend visiting the official GitHub repository:



### Features

**Argus** is primarily focused on **Samba** integration for honeypot and deception purposes.  
It features integrated MAC spoofing, a static IP system, and Samba file sharing linked to a logging system.
it uses Scapy to catch any port scan atempt

## Prerequisites

To ensure everything works as intended, you will need a Raspberry Pi 4 (for maximum compatibility, although you can try on other hardware).

### Required Materials

- A Raspberry Pi 4 with its original OS ([Download](https://www.raspberrypi.com/software/operating-systems/))
- Internet connection (RJ45 or WiFi)
- Keyboard, mouse, and monitor (during installation)
- Micro SD Card 32GB Minimum

### Install Pi4

if the Pi4 you are using does not have an image [download it here](https://www.raspberrypi.com/software/operating-systems/) and plug the Micro SD card in your computer

when on the website click download + curent os you are using 

then click choose model 

after that click on Raspberry Pi OS (64-bit) 

select in model Raspberry Pi 4

you will now have to select you micro SD card you previously inserted

you will land on a page where you can fill up afew informations such as name and password , configurate wifi connexion

whe you are done you can click on save and it will write on  the micro SD card 

### Configuration on Pi4

it is srongly recomanded to set the ip address by hand

To configure accounts and enable SSH access:

To create an account, run (make sure to customize the account name):

(you can skip the first step you did [Install Pi4](#install-pi4))

```sh
useradd <username>
```


access the file `/etc/ssh/sshd_config` and change or add the line 

AllowUsers user

To enable SSH:

```sh
sudo apt update
sudo apt install ssh -y
sudo systemctl enable ssh
```

Be sure to disable the root account in `/etc/ssh/sshd_config`. Open the file with:

```sh
sudo nano /etc/ssh/sshd_config
```

Then add or edit the following line:

```
PermitRootLogin no
```

and 

```
AllowsUsers syswhoz
```
## Installation

### Docker Installation

To install Docker, simply run:

```sh
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
strongly recomanded
```
sudo usermod -aG docker syswhoz
```

### Git Installation

To clone this repository, you will need git installed:

```sh
sudo apt update
sudo apt install git -y
```

> [!WARNING]
> Configuration is not finished yet. You will still need to obtain repository access keys.

### OpenCanary Installation

Due to compatibility issues, it is strongly recommended to clone into `/opt` for the default setup.

#### Git Clone

Before running the command below, make sure you have access to the repository or are authenticated.

generate a ssh key 

```
ssh-keygen -t ed25519 -C "votre.email@example.com"
```

now you can see the key you just generated 

```
cat .ssh/id_ed25519.pub
```

now add this key in your account settings in github
```
ssh -T git@github.com
```
i will copy the git broject at the curent emplacement where you are located
```sh
git clone git@github.com:biznet-io/argus.git 
```
```
sudo mkdir /opt/argus
sudo cp -r /home/syswhoz/argus /opt
```

#### Executable

The script is not yet executable at this stage. Run the following:

```sh
sudo chmod +x /opt/argus/install_startup.sh
```

## Customizations

If something becomes obsolete or requires a change/fix, here you can find customizable settings:

### Samba Share

The shared folder is located at `/opt/argus/opencanary_docker/share`.  
If you want to change the shared file path, edit `/opt/argus/install_startup.sh`.

At line 65, you'll find:

```
-v $DOCKER_CONF_DIR/share:/samba/share \
```

Replace `$DOCKER_CONF_DIR/share` with your desired file path (make sure the path is correct).

### Account Configuration

If you think the default password or username is not realistic, or is not suitable for your setup,  
edit `/opt/argus/opencanary_docker/smb.conf`.

For example, change or add the line:

```
valid users = admin
```

You will then also need to update corresponding commands in `/opt/argus/opencanary_docker/`, such as:

- `useradd -m admin` (replace admin)
- `smbpasswd -s -a admin` (replace admin)
- `smbpasswd -e admin` (replace admin)
- `(echo "admin"; echo "admin")` (replace 'admin' with the new password)

For multiple users, follow the same logic.

### MAC Spoofing

To change your Raspberry Pi's MAC address, open `/opt/argus/install_startup.sh` and edit:

```sh
MACADDR="00:11:32:12:34:56"
```

Replace the value with the desired MAC address (e.g., `00:11:32` prefix is for Synology devices).

### Other

there is a lot of small customisations in `install_startup`
```
NETIF="eth0"
MACADDR="00:11:32:12:34:56"
STATIC_IP="10.12.4.170/24"
ROUTER="10.12.4.254"
LOGS_LOCATION="/var/log/docker/opencanary.log"
DOCKER_CONF_DIR="/opt/argus/opencanary_docker"
CONTAINER_NAME="opencanary"
IMAGE_NAME="opencanary"
```
all these values can be changed


## Useful Commands

To start Argus, simply run:

```sh
sudo /opt/argus/install_start.sh
```


**delete the generated keys at the end**


