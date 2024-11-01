#!/bin/bash

SERVERS_LOGS_DIR="/home/daniel/Documents/logs"
SERVERS_LOGS_NAME=$(date +'%Y%m%d_%H%M%S')_servers.log
SERVERS_LOGS_FULL_PATH=$SERVERS_LOGS_DIR/$SERVERS_LOGS_NAME
GREP_FIRST_CMD="$(date +'%b %d')' /var/log/apache2/"
GREP_SECOND_CMD="grep 'php:error' | grep -v 'not found'"
FAIL2BAN_CMD="fail2ban-client status apache-deny-sensitive"

echo -e "ServerName"
echo -e "ServerName\n********************" >> $SERVERS_LOGS_FULL_PATH
ssh -i /path/to/key user@host "grep '${GREP_FIRST_CMD}site-error.log | $GREP_SECOND_CMD ; sudo $FAIL2BAN_CMD" >> $SERVERS_LOGS_NAME

# Print location
echo $SERVERS_LOGS_FULL_PATH

