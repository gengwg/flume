#!/bin/bash

USER=mydb
HIVEDB=$USER
TARGET_TABLE=company_email_sends
DATA_DIR=/home/$USER/email_sends/logs
export JAVA_HOME=/usr/lib/jvm/java-1.7.0

set -e 
(
	# Wait for lock on /var/lock/.myscript.exclusivelock (fd 200) for 0.001 seconds
	flock -x -w 0.001 200
	tomorrows_date=`date -d "+1 day" +%Y-%m-%d`
	start_epoch=`date --date="$tomorrows_date" +%s`
	start_epoch_hourtenth=`expr $start_epoch / 360`
	end_epoch_hourtenth=`expr $start_epoch_hourtenth + 240`
	echo "Adding partitions $start_epoch_hourtenth to $end_epoch_hourtenth" 

	for (( current_epoch_hourtenth=$start_epoch_hourtenth; current_epoch_hourtenth<=$end_epoch_hourtenth; current_epoch_hourtenth++ ))
	do
		echo "Adding partition: $current_epoch_hourtenth"
		/usr/local/bin/hive -e "USE $HIVEDB; ALTER TABLE ${TARGET_TABLE} ADD IF NOT EXISTS PARTITION (epoch=$current_epoch_hourtenth);"
	done
) 200>$DATA_DIR/.flume.company_email_sends.exclusivelock
