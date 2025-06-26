# Honey-Hive

## Table of Contents
- **[Presentation](#presentation)**
  - [Features](#features)
- **[Installation](#installation)**
  - [Opencanary Installation](#opencanary-installation)
    - [Git Clone](#git-clone)
    - [Executable](#executable)
    - [Auto Start](#auto-start)
- **[Customizations](#customizations)**
  - [Samba Share](#samba-share)
  - [Account Configuration](#account-configuration)
  - [MAC Spoofing](#mac-spoofing)
  - [Rotate Logs](#rotate-logs)
  - [Other](#other)
- **[Useful Commands](#useful-commands)**

## Presentation

**Honey-Hive** is developed by **Bzhkem** and is based on [OpenCanary](https://github.com/thinkst/opencanary), which is a honeypot solution.

### Features

**Honey-Hive** pretends to be a Synology NAS for honeypot and deception purposes.  
It features MAC spoofing to look like a Synology NAS, and exposes a fake SMB share and administrator web GUI.
it uses Scapy to catch any port scan atempt

## Installation

### OpenCanary Installation

Due to compatibility issues, it is strongly recommended to clone into `/opt` for the default setup.

#### Git Clone

Before running the command below, make sure you have access to the repository or are authenticated.



```sh
git clone https://github.com/bzhkem/honey-hive.git
```
```
sudo mkdir /opt/honey-hive
sudo cp -r /home/user/honey-hive /opt
```

#### Executable

The script is not yet executable at this stage. Run the following:

```sh
sudo chmod +x /opt/honey-hive/install_startup.sh
```

#### Auto Start

if you want the MAC spoofer to work on boot you will need to create a service

```
sudo nano /etc/systemd/system/opencanary-bootstrap.service
```
fill this in the file
```
[Unit]
Description=Automated install/start Opencanary Docker container at boot
After=network.target docker.service

[Service]
Type=oneshot
ExecStart=/opt/honey-hive/install_startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```
enable the service you just created
```
sudo systemctl daemon-reload
sudo systemctl enable opencanary-bootstrap.service
```

## Customizations

If something becomes obsolete or requires a change/fix, here you can find customizable settings:

### Samba Share

The shared folder is located at `/opt/honey-hive/opencanary_docker/share`.  
If you want to change the shared file path, edit `/opt/honey-hive/install_startup.sh`.

At line 65, you'll find:

```
-v $DOCKER_CONF_DIR/share:/samba/share \
```

Replace `$DOCKER_CONF_DIR/share` with your desired file path (make sure the path is correct).

### Account Configuration

If you think the default password or username is not realistic, or is not suitable for your setup,  
edit `/opt/honey-hive/opencanary_docker/smb.conf`.

For example, change or add the line:

```
valid users = admin
```

You will then also need to update corresponding commands in `/opt/honey-hive/opencanary_docker/Dockerfile`, such as:

- `useradd -m admin` (replace admin)
- `smbpasswd -s -a admin` (replace admin)
- `smbpasswd -e admin` (replace admin)
- `(echo "admin"; echo "admin")` (replace 'admin' with the new password)

For multiple users, follow the same logic.

### MAC Spoofing

To change your Raspberry Pi's MAC address, open `/opt/honey-hive/install_startup.sh` and edit:

```sh
MACADDR="00:11:32:XX:XX:XX"
```

Replace the value with the desired MAC address (e.g., `00:11:32` prefix is for Synology devices).

### Rotate Logs

you can change the settings for the automated logs rotations in 

```
/etc/logrotate.d/opencanary
```

> [!WARNING]
> Python logs for `scanport.py` are automatically deleted. If you want to keep them, remove line 76 in `install_startup.sh`
> Please note: if you start the script twice or incorrectly, the log file may continuously write error messages while working well
### Other

there is a lot of small customisations in `install_startup`
```
NETIF="eth0"
MACADDR="00:11:32:12:34:56"
STATIC_IP="10.12.4.170/24"
ROUTER="10.12.4.254"
LOGS_LOCATION="/var/log/docker/opencanary.log"
DOCKER_CONF_DIR="/opt/honey-hive/opencanary_docker"
CONTAINER_NAME="opencanary"
IMAGE_NAME="opencanary"
```
all these values can be changed


## Useful Commands

To start Honey-Hive, simply run:

```sh
sudo /opt/honey-hive/install_start.sh
```
