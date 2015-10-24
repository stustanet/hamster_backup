#!/bin/sh

#become root
sudo -i

cd /opt

## for the following step you need to set up a deploy key in gitlab:
## https://gitlab.stusta.mhn.de/stustanet/hamster_backup/deploy_keys
## "enable" deploy key if exists, else:
## if ssh key on the server doesn't exist create new ssh key on server
# ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519
## create new deploy key in gitlab with name = "ServerName" and
## content = content of /root/.ssh/id_ed25519.pub.

# clone the git repository containing the client scripts
git clone git@gitlab.stusta.mhn.de:stustanet/hamster_backup.git

# create ssh key
ssh-keygen -t rsa -b 4096 -f /opt/hamster_backup/client/id_rsa_hamster

# read README
less /opt/hamster_backup/client/README.md

# extend / update rsync_excl.list
nano /opt/hamster_backup/client/rsync_excl.list

# cron DEPRECATED, better use systemd
### create cronjob
### echo -e "#\n#crontab for automatic hamster backup\n#\n\n# m  h   dom mon dow   user     command\n00 05    *   *   3    root     /etc/hamster_backups/hamster_backup.sh\n" > /etc/cron.d/ssn_hamster_backup

# create, start and enable systemd.timer and systemd.service:
echo -e "[Unit]\nDescription=Run hamster-Backup weekly\n\n[Timer]" > /etc/systemd/system/hamster_backup.timer

# change following date/time to meaningful values!
echo "OnCalendar=Mon *-*-* 04:00:00" >> > /etc/systemd/system/hamster_backup.timer

echo -e "Persistent=false\n\n[Install]\nWantedBy=timers.target" > /etc/systemd/system/hamster_backup.timer
echo -e "[Unit]\nDescription=Backup Server to hamster\nAfter=multi-user.target\nRequires=multi-user.target\n\n[Service]\nType=oneshot\nExecStart=/opt/hamster_backup/client/hamster_backup.sh" > /etc/systemd/system/hamster_backup.service
systemctl start hamster_backup.timer
systemctl enable hamster_backup.timer

# TSM deinstallieren, falls vorhanden:
apt purge tivsm-api64 tivsm-ba gskcrypt64 gskssl64 gskcrypt32 gskssl32
