Hamster Backup System -  Server
===============================

* Diese Dateien werden auf dem Server nach /etc/hamster_backups kopiert.
* Es existiert für jeden Host ein Mountpunkt in /srv/backups
* Jeder Host hat sein eigenes logical Volume für sein Backup
* im Backupverzeichnis des Hosts muss vor dem ersten Backup das Verzeichnis current angelegt werden, damit der rsync dort reinschreiben kann
* Jeder Host hat einen eigenen SSH-Key, der sich nur von der entsprechenden IP (v6 nicht vergessen) einloggen darf und per forced command /usr/local/bin/rrsync /srv/backups/<host>/current auf rsync in seinem Backup-Home eingeschränkt ist
* Auf den Servern wird beim Backup eine Datei angelegt, die Hamster signalisiert, dass ein neues Backup da ist, sobald das Backup auf Hamster verarbeitet ist, wird diese auf Hamster gelöscht
* Die Backups werden per Hardcopy aus dem current-dir kopiert, um eine Versionierung realisiert ist. Es werden 5 Versionen aufgehoben
* Hamster selbst wird wöchentlich ins TSM gebackuped
* Das rotate-Skript und das TSM-Backup muss regelmäßig per Cron oder Systemd-Timer laufen.
