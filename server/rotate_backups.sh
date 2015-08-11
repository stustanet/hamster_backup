#!/bin/bash

# Wird täglich um 12:00 Uhr ausgeführt, ATM per cron.d

# Wenn noch ein rsync aktiv ist, warten
while pidof rsync > /dev/null; do
	sleep 10
done

# Login für die Clients deaktivieren, während wir rotieren

mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.disabled

ROTATION_INDICATOR=etc/hamster_backups/do_rotate
BACKUP_HOME=/srv/backups/
CUR_DATE=$(/bin/date +%F)

for dir in ${BACKUP_HOME}/*/current; do
	# hardlinks von "current" erstellen, um sinnvoll mehrere Versionen zu speichern
	if [ -e ${dir}/${ROTATION_INDICATOR} ]; then
		if [ -e $(/usr/bin/dirname ${dir})/Backup_${CUR_DATE} ]; then
			i=1
			while [ -e $(/usr/bin/dirname ${dir})/Backup_${CUR_DATE}_${i} ]; do
				let i=i+1
			done
			ROT_TARGET=$(/usr/bin/dirname ${dir})/Backup_${CUR_DATE}_${i}
		else
			ROT_TARGET=$(/usr/bin/dirname ${dir})/Backup_${CUR_DATE}
		fi
		cp -al ${dir} ${ROT_TARGET}
		rm -rf ${ROT_TARGET}/${ROTATION_INDICATOR} ${dir}/${ROTATION_INDICATOR}
	fi
	# maximal 5 versionen aufheben
	DIRLIST=($(/usr/bin/dirname ${dir})/*)
	while [ ${#DIRLIST[@]} -gt 7 ]; do
		i=0
		while [ ${DIRLIST[${i}]} == "current" -a ${DIRLIST[${i}]} == "lost+found" ]; do
			let i=i+1
		done
		rm -rf ${DIRLIST[${i}]}
		DIRLIST=($(/usr/bin/dirname ${dir})/*)
	done
done

mv /root/.ssh/authorized_keys.disabled /root/.ssh/authorized_keys
