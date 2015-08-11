Hamster Backup System
=====================

Über das Hamster Backup werden unsere Server lokal und off site (TSM) gesichert, ohne dass jeder Server Zugriff auf das TSM-System haben muss.  
Die einzelnen Server pushen ihre Backups auf Hamster, der sie versioniert und einmal wöchentlich ins TSM weiter schiebt.

neuen Host für Backups anlegen
------------------------------

### auf dem Host hostname.stusta.mhn.de:

	* Dateien aus client/ nach hostname:/etc/hamster_backups/ kopieren (dann auch mal in die README schauen), evtl. rsync_excl.list erweitern.
	* SSH-Key in /etc/hamster_backups/ erzeugen:
	* ssh-keygen -t rsa -b 4096 -f id_rsa_hamster
	* cronjob oder Systemd-Timer  anlegen, der regelmäßig /etc/hamster_backups/hamster_backup.sh als root ausführt, 
	* /etc/cron.d/ssn_hamster_backup
		#
		#crontab for automatic hamster backup
		#
		
		# m  h   dom mon dow   user     command
		00 05    *   *   3    root     /etc/hamster_backups/hamster_backup.sh
		#
	* /etc/systemd/system/hamster_backup.timer
		[Unit]
		Description=Run hamster-Backup weekly
		
		[Timer]
		OnCalendar=Mon *-*-* 04:00:00
		Persistent=false
		
		[Install]
		WantedBy=timers.target
	* /etc/systemd/system/hamster_backup.service
		[Unit]
		Description=Backup Server to hamster
		After=multi-user.target
		Requires=multi-user.target
		
		[Service]
		Type=oneshot
		ExecStart=/etc/hamster_backups/hamster_backup.sh

	* Wenn der Systemd-Timer verwendet wird, das aktivieren nicht vergessen:
		systemctl enable hamster_backup.timer
	* TSM deinstallieren, falls vorhanden:
		sudo apt purge tivsm-api64 tivsm-ba gskcrypt64 gskssl64 gskcrypt32 gskssl32


### auf Hamster:

	* LV anlegen:
		lvcreate -L 20G -n hostname-lv hamster-data-vg
		mkfs.ext4 /dev/mapper/hamster--data--vg-hostname--lv
	* /etc/fstab anpassen
	* Mountverzeichnis /srv/backups/hostname anlegen
	* LV mounten 
	* im Backupverzeichnis das Verzeichnis current anlegen
	* public Key des Servers in /root/.ssh/authorized_keys einfügen und ip und command option entsprechend anpassen. (don't forget IPv6, it's the new shit)

### Testen ob's geht (einfach als root das script ausführen), ssh-key prüfen 
