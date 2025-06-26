FROM thinkst/opencanary

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y samba rsyslog samba-common-bin nano && \
    useradd -m admin && \
    mkdir -p /run/samba && \
    echo -e "[global]\nmap to guest = Bad User" > /etc/samba/smb.conf && \
    (echo "admin"; echo "admin") | smbpasswd -s -a admin && \
    smbpasswd -e admin && \
    echo 'local7.*    /var/log/samba-audit.log' > /etc/rsyslog.d/samba-audit.conf && \
    mkdir /samba && \
    echo "" > /samba/README && \
    pip install scapy

COPY start.sh /start.sh
COPY scanport.py /scanport.py

ENTRYPOINT []
CMD ["/start.sh"]
