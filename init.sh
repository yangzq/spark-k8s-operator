#!/bin/bash

#nohup /opt/mr3-run/run-all.sh > /opt/mr3-run/run.log 2>&1 &
#exec /usr/sbin/init
/usr/sbin/init
systemctl start mysqld
# run the command given as arguments from CMD
exec "$@"
#exec /opt/mr3-run/run-all.sh

