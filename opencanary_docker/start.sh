#!/bin/bash
set -e

rm -f /tmp/twistd.pid

smbd -F &
nmbd -F &
rsyslogd
opencanaryd --dev
