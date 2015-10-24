#!/bin/bash

ROTATION_INDICATOR=/etc/hamster_backups/do_rotate

rm -rf ${ROTATION_INDICATOR}
echo "# Achtung! Diese Datei wird regelmäßig vom Hamster-Backup überschrieben" > ${ROTATION_INDICATOR}

/usr/bin/rsync -aAE --delete --numeric-ids --exclude-from=/etc/hamster_backups/rsync_excl.list --hard-links -e "ssh -i /etc/hamster_backups/id_rsa_hamster" / root@hamster.stusta.mhn.de:.
EC=${?}
if [ ${EC} -gt 0 ]; then
	echo "Rsync failed, something went wrong.. :("
	exit 2
fi

rm -rf ${ROTATION_INDICATOR}
