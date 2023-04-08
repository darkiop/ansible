#!/bin/bash
#
# Kopiert MariaDB Backups nach NFS Mount /mnt/odin/backup/mariadb
# fstab: 192.168.1.43:/volume1/backup /mnt/odin/backup nfs rw 0 0
# crontab: 30 4 * * * /home/darkiop/dotfiles/bin/iobroker/iobroker-backup-sync-mariadb.sh

MNT="/mnt/odin/backup"
BACKUPS="/opt/iobroker/backups/"
RSYNC="sudo rsync -avz --exclude=yahka.* --exclude=homematic_* --exclude=grafana_* --exclude=javascripts_* --exclude=iobroker_* --exclude=redis*  --exclude=*-migration --delete $BACKUPS $MNT/mariadb"

if mountpoint -q $MNT
  then
    $RSYNC
  else
    mount $MNT
    if mountpoint -q $MNT
      then
        $RSYNC
      else
        exit 0
    fi
fi

# EOF