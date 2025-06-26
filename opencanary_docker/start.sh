#!/bin/bash

rm -f /tmp/twistd.pid

smbd -F &
nmbd -F &
rsyslogd &

(
  while true; do
    echo "[scanport] Starting scanport.py ..."
    python /scanport.py ...
    echo "opencanary: {\"dst_host\": \"\", \"dst_port\": -1, \"logtype\": 9999, \"node_id\": \"$(hostname)\", \"src_host\": \"\", \"logdata\": {\"msg\": \"[scanport] scanport.py a crashé ou terminé, tentative de restart dans 10min at $(date +'%F %T')\"}}" >> /app/opencanary.log
    sleep 600
  done
) &

opencanaryd --dev
