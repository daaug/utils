#!/bin/bash                                                                                                                           
#DB_NAME=""                                                                                                                           
DB_USER=""
DB_PASS=""

SSH_USER=""
SSH_SRV=""
SSH_KEY=""

BKPS_LOCATION=""
BKP_DIR=""
STREAM_FILE_NAME=$(date +"%Y%m%d_%H%M%S")

# Make sure the dir exist
mkdir -p $BKPS_LOCATION/$BKP_DIR

# --databases removed because we want all databases
# Full backup from all databases
ssh -i $SSH_KEY $SSH_USER@$SSH_SRV \
        "mariabackup --backup \
        --user=$DB_USER \
        --password='$DB_PASS' \
        --stream=mbstream \
        --target-dir=./" > $BKPS_LOCATION/$BKP_DIR/$STREAM_FILE_NAME

# Compress
gzip $BKPS_LOCATION/$BKP_DIR/$STREAM_FILE_NAME

