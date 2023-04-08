#!/bin/bash
#
# Kopiert iobroker Backups nach NFS Mount /mnt/odin/backup/iobroker
# fstab: 192.168.1.43:/volume1/backup /mnt/odin/backup nfs rw 0 0
# crontab: 30 4 * * * /home/darkiop/dotfiles/bin/iobroker/iobroker-backup-sync-iobroker.sh

MNT="/mnt/odin/backup"
BACKUPS="/opt/iobroker/backups/"
RSYNC="sudo rsync -avz --exclude=mysql_* --exclude=grafana_* --exclude=homematic_* --delete $BACKUPS $MNT/iobroker"

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