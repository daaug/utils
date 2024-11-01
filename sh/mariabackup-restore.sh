#!/bin/bash                                                                                                                           
#####                                                                                                                                 
# ARGUMENTS:                                                                                                                          
# $1 == server_nick == vpc01                                                                                                          
# $2 == bkp_name == 20241008_163022                                                                                                   
# example:                                                                                                                            
# bash mariabackup-restore.sh vpc01 20241008_163022.gz                                                                      
#####                                                                                                                                 
if [ -n "$1" ] && [ -n "$2" ]; then                                                                                                   
        BKP_PATH="/data/backups/mysql"                                                                                                
        SRV_NAME="$1"                                                                                                                 
        BKP_NAME="$2"                                                                                                                 
        DATA_DIR="/var/lib/mysql/"                                                                                                    
        DATETIME=$(date +"%Y%m%d_%H%M%S")                                                                                             
                                                                                                                                      
        # Decompress it (but the gz file disapears)                                                                                   
        echo "**********"                                                                                                             
        echo "Decompress gz"                                                                                                          
        echo "**********"                                                                                                             
        gzip -d $BKP_PATH/$SRV_NAME/$BKP_NAME                                                                                         
        BKP_NAME=${BKP_NAME%.gz}                                                                                                      
                                                                                                                                      
        ## Create the folder to place it and then Unpack it
        echo "**********"
        echo "Unpack stream"
        echo "**********"
        mkdir -p $BKP_PATH/$SRV_NAME/${BKP_NAME}_bkp
        mbstream -x < $BKP_PATH/$SRV_NAME/$BKP_NAME -C $BKP_PATH/$SRV_NAME/${BKP_NAME}_bkp

        # Remove the .gz from the given name to match the decompressing
        BKP_NAME=${BKP_NAME%.gz}

        # Prepare the database
        echo "**********"
        echo "Prepare the database"
        echo "**********"
        mariabackup --prepare --target-dir=$BKP_PATH/$SRV_NAME/${BKP_NAME}_bkp

        # DATABASE
        # Stop it first
        echo "**********"
        echo "Stop Mysql/Mariadb" 
        echo "**********"
        service mysql stop

        # Clean/Save mysql lib dir
        #rm -r /var/lib/mysql/*
        echo "**********"
        echo "Create backup from /var/lib/mysql"
        echo "**********"
        mv /var/lib/mysql /var/lib/mysql_$DATETIME
        mkdir -p /var/lib/mysql

        # Any trouble with 'mysqld', do before starting mysql again:
        #mkdir -p /var/run/mysqld 
        #chown mysql:mysql /var/run/mysqld
        #chmod 755 /var/run/mysqld

        # /var/lib/mysql/ must be empty
        echo "**********"
        echo "Put the new database on /var/lib/mysql"
        echo "**********"
        mariabackup --copy-back \ 
        --datadir=$DATA_DIR \
        --target-dir=$BKP_PATH/$SRV_NAME/${BKP_NAME}_bkp

        # Fix the user:group
        echo "**********"
        echo "Fix /var/lib/mysql user:group to mysql"
        echo "**********"
        chown -R mysql:mysql /var/lib/mysql

        # Start it again
        echo "**********"
        echo "Start Mysql/Mariadb"
        echo "**********"
        service mysql start

        # Compress the file again (for space sake)
        #echo "**********"
        #echo "Compress again the backup and rename it removing the gz"
        #echo "**********"
        #gzip $BKP_PATH/$SRV_NAME/$BKP_NAME
        #mv $BKP_PATH/$SRV_NAME/bkp${BKP_NAME}.gz $BKP_PATH/$SRV_NAME/${BKP_NAME}.gz
        #rm -rf $BKP_PATH/$SRV_NAME/$BKP_NAME
else
        echo "Error: Missing parameters!"
fi
