#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705 - Deiteq
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
source /opt/pgblitz/menu/functions/functions.sh
source /opt/pgpress/pgvault/pgvault.func

file="/opt/var/restore.id"
if [ ! -e "$file" ]; then
  echo "[NOT-SET]" > /opt/var/restore.id
fi

initial
apprecall
primaryinterface
