#!/bin/bash
# ==========
# CONFIGURATION
# ==========
NETIF="eth0"
MACADDR="00:11:32:12:34:56"
STATIC_IP="10.12.4.170/24"
ROUTER="10.12.4.254"
LOGS_LOCATION="/var/log/docker/opencanary.log"
DOCKER_CONF_DIR="/opt/honey-hive/opencanary_docker"
CONTAINER_NAME="opencanary"
IMAGE_NAME="opencanary"

# --------
# SPOOF MAC ADRESSE (temporaire, dure jusqu'au reboot)
# --------
echo "Changement MAC sur $NETIF..."
echo "Si tu es en SSH, ta connexion risque d'être coupée ! Reconnecte-toi sur $STATIC_IP."
sudo ip link set dev $NETIF down
sudo ip link set dev $NETIF address $MACADDR
sudo ip link set dev $NETIF up

# --------
# CONF RÉSEAU STATIC (dhcpcd.conf, standard Raspberry Pi)
# --------
echo "Configuration IP statique et gateway dans /etc/dhcpcd.conf"
sudo sed -i "/^interface $NETIF/,+10d" /etc/dhcpcd.conf
cat <<EOF | sudo tee -a /etc/dhcpcd.conf
interface $NETIF
static ip_address=$STATIC_IP
static routers=$ROUTER
static domain_name_servers=8.8.8.8 1.1.1.1
EOF
echo "checking $DOCKER_CONF_DIR/share ....."
sleep 2

# --------
# Vérifie/crée les dossiers et fichiers nécessaires
# --------
[ -d "$DOCKER_CONF_DIR/share" ] || sudo mkdir -p "$DOCKER_CONF_DIR/share"
sudo chmod 777 "$DOCKER_CONF_DIR/share"
echo "successful"

echo "checking $DOCKER_CONF_DIR/opencanary.conf ....."
[ -f "$DOCKER_CONF_DIR/opencanary.conf" ] || (echo "Fichier $DOCKER_CONF_DIR/opencanary.conf manquant !"; exit 1)
echo "successful"

echo "checking $DOCKER_CONF_DIR/smb.conf ....."
[ -f "$DOCKER_CONF_DIR/smb.conf" ] || (echo "Fichier $DOCKER_CONF_DIR/smb.conf manquant !"; exit 1)
echo "successful $DOCKER_CONF_DIR/smb.conf"

# --------
# LOG FILE: automatic directory replacement if needed
# --------
echo "checking $LOGS_LOCATION ..."
sudo mkdir -p "$(dirname "$LOGS_LOCATION")"
if [ -d "$LOGS_LOCATION" ]; then
  echo "$LOGS_LOCATION exists and is a directory. Removing it and creating a file instead."
  sudo rm -rf "$LOGS_LOCATION"
fi

[ -f "$LOGS_LOCATION" ] || sudo touch "$LOGS_LOCATION"
sudo chmod 666 "$LOGS_LOCATION"
echo "successful"

echo "checking $DOCKER_CONF_DIR/syslog ....."
[ -f "$DOCKER_CONF_DIR/syslog" ] || sudo touch "$DOCKER_CONF_DIR/syslog"
echo "successful $DOCKER_CONF_DIR/syslog"
sudo chmod 666 "$DOCKER_CONF_DIR/syslog"

# --------
# LANCE DOCKER AVEC MONTAGE DES LOGS
# --------
echo "Installation Opencanary..."
sudo docker rm -f "$CONTAINER_NAME" 2>/dev/null
echo "sudo docker build -t $IMAGE_NAME $DOCKER_CONF_DIR"
sudo docker build -t $IMAGE_NAME $DOCKER_CONF_DIR/
sudo docker run -d \
 --network host \
 --restart unless-stopped \
 -v $LOGS_LOCATION:/app/opencanary.log \
 -v $DOCKER_CONF_DIR/share:/samba/share \
 -v $DOCKER_CONF_DIR/opencanary.conf:/root/.opencanary.conf \
 -v $DOCKER_CONF_DIR/smb.conf:/etc/samba/smb.conf \
 --name $CONTAINER_NAME \
 $IMAGE_NAME
echo "---------------------------------------------"
echo "file path for Opencanary logs set on $LOGS_LOCATION"
echo "---------------------------------------------"
echo
echo "Le conteneur Docker Opencanary est lancé et s'autodémarrera dorénavant."
echo "Les modifications IP/MAC prennent effet tout de suite."

# ===== AJOUT pour scanport.py =====

# On laisse le conteneur démarrer (4 sec c'est safe)
sleep 4

# Copie scanport.py dans le conteneur Docker
sudo docker cp $DOCKER_CONF_DIR/scanport.py $CONTAINER_NAME:/scanport.py

# Installe scapy si besoin
sudo docker exec $CONTAINER_NAME pip install scapy

# Lance le sniffer en tâche de fond
sudo docker exec -d $CONTAINER_NAME python /scanport.py

echo "Le sniffer scanport.py tourne dans $CONTAINER_NAME"
