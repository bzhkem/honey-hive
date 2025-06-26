#!/bin/bash
NETIF="eth0"
MACADDR="00:11:32:12:34:56"
STATIC_IP="10.12.4.170/24"
ROUTER="10.12.4.254"
LOGS_LOCATION="/var/log/docker/opencanary.log"
DOCKER_CONF_DIR="/opt/honey-hive/opencanary_docker"
CONTAINER_NAME="opencanary"
IMAGE_NAME="opencanary"

echo "Changement MAC sur $NETIF..."
echo "Si tu es en SSH, ta connexion risque d'être coupée ! Reconnecte-toi sur $STATIC_IP."
sudo ip link set dev $NETIF down
sudo ip link set dev $NETIF address $MACADDR
sudo ip link set dev $NETIF up

echo "Configuration IP statique et gateway dans /etc/dhcpcd.conf"
sudo sed -i "/^interface $NETIF/,+10d" /etc/dhcpcd.conf
cat <<EOF | sudo tee -a /etc/dhcpcd.conf
interface $NETIF
static ip_address=$STATIC_IP
static routers=$ROUTER
static domain_name_servers=8.8.8.8 1.1.1.1
EOF
sleep 2

[ -d "$DOCKER_CONF_DIR/share" ] || sudo mkdir -p "$DOCKER_CONF_DIR/share"
sudo chmod 777 "$DOCKER_CONF_DIR/share"
[ -f "$DOCKER_CONF_DIR/opencanary.conf" ] || (echo -e "\033[31mFichier $DOCKER_CONF_DIR/opencanary.conf manquant\033[0m"; exit 1)
[ -f "$DOCKER_CONF_DIR/smb.conf" ] || (echo -e "\033[31mFichier $DOCKER_CONF_DIR/smb.conf manquant\033[0m"; exit 1)
sudo mkdir -p "$(dirname "$LOGS_LOCATION")"
if [ -d "$LOGS_LOCATION" ]; then
  echo -e "\033[31m $LOGS_LOCATION exists and is a directory. Removing it and creating a file instead\033[0m"
  sudo rm -rf "$LOGS_LOCATION"
fi
[ -f "$LOGS_LOCATION" ] || sudo touch "$LOGS_LOCATION"
sudo chmod 666 "$LOGS_LOCATION"
[ -f "$DOCKER_CONF_DIR/syslog" ] || sudo touch "$DOCKER_CONF_DIR/syslog"
sudo chmod 666 "$DOCKER_CONF_DIR/syslog"
sudo docker rm -f "$CONTAINER_NAME" 2>/dev/null
echo "sudo docker build -t $IMAGE_NAME $DOCKER_CONF_DIR"
sudo docker build -t $IMAGE_NAME $DOCKER_CONF_DIR/
sudo docker run -d \
 --network host \
 --restart unless-stopped \
 --cap-add=NET_ADMIN \
 -v $LOGS_LOCATION:/app/opencanary.log \
 -v $DOCKER_CONF_DIR/share:/samba/share \
 -v $DOCKER_CONF_DIR/opencanary.conf:/root/.opencanary.conf \
 -v $DOCKER_CONF_DIR/smb.conf:/etc/samba/smb.conf \
 --name $CONTAINER_NAME \
 $IMAGE_NAME
echo
echo "---------------------------------------------"
echo -e "\033[34mfile path for Opencanary logs set on $LOGS_LOCATION\033[0m"
echo "---------------------------------------------"
echo
echo "Le conteneur Docker Opencanary est lancé et s'autodémarrera dorénavant."
echo "Les modifications IP/MAC prennent effet tout de suite."

sudo truncate -s 0 /var/log/docker/scanport.log
LOGROTATE_CONFIG_FILE="/etc/logrotate.d/opencanary"
if [ ! -f "$LOGROTATE_CONFIG_FILE" ]; then
    echo "Setting up log rotation for $LOGS_LOCATION with logrotate..."
    sudo tee "$LOGROTATE_CONFIG_FILE" > /dev/null <<EOF
$LOGS_LOCATION {
    weekly
    rotate 4
    compress
    copytruncate
    missingok
    notifempty
    dateext
    create 0640 root root
    su root root
}
EOF
    echo "Log rotation configured for $LOGS_LOCATION."
else
    echo "Log rotation for $LOGS_LOCATION already configured."
fi
