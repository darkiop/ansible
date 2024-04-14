#!/bin/bash

debug=true
host="192.168.1.30"
nfsshare="/volume1/backup"
date=$(date +%Y%m%d_%H%M%S)
backup_user="darkiop"
backup_group="darkiop"
backup_name="bind_loki"
backup_name_date="$backup_name-$date"
backup_path_local="/home/darkiop/backups/$backup_name"
backup_path_remote="/mnt/odin/backup"
backup_objects="/etc/bind/ /var/cache/bind/"
backup_files=`find $backup_path_local -name "$backup_name-*.gz" | wc -l | sed 's/\ //g'`
backup_keep=8

fancy_echo() {
  local color="$1"; shift
  local fmt="$1"; shift
  local color_code
  case "$color" in
    red) color_code="1;31" ;;
    green) color_code="1;32" ;;
    blue) color_code="1;34" ;;
    orange) color_code="1;33" ;;
    *) color_code="0" ;;
  esac
  printf "\n\033[${color_code}m$fmt\033[0m\n" "$@"
}

function debug_msg() {
    local color="$1"
    local msg="$2"
    if [ "$debug" = "true" ]; then fancy_echo "$color" "$msg"; fi
}

# check if user is root, if not -> exit
function check_if_user_is_root() {
    if [ "${EUID}" -ne 0 ]; then
        debug_msg "red" "You need to run this as root. Exit."
        exit 1
    fi
}

# check if local path exists, and if not create it
if [ ! -d $backup_path_local ]; then
    mkdir -p $backup_path_local
fi

function mount_share() {
    debug_msg orange "mount NFS share $nfsshare ..."
    mount -t nfs $host:$nfsshare $backup_path_remote
}

function umount_share() {
    debug_msg orange "umount NFS share $nfsshare ..."
    sudo umount.nfs $backup_path_remote
}

function cleanup() {
    while [ $backup_files -ge $backup_keep ]
    do
        debug_msg orange "deleting old backup files [$backup_files] ..."
        ls -tr1 $backup_path_local/$backup_name-*.gz | head -n 1 | xargs rm -f 
        backup_files=`expr $backup_files - 1` 
    done
}

function targz_to_local_path() {
    debug_msg orange "Run targz_to_local_path ..."
    tar czf $backup_path_local/$backup_name_date.tar.gz $backup_objects
    chown $backup_user:$backup_group $backup_path_local/$backup_name_date.tar.gz
}

function rsync_to_remote_path() {
    debug_msg orange "Run rsync_to_remote_path ..."
    rsync -avz --delete $backup_path_local $backup_path_remote
}

## run backup

# check if host is reachable
if fping -c 1 $host > /dev/null 2>&1; then

    debug_msg blue "----- Connect to NFS Share -----"
    
    debug_msg green "Host $host is reachable."

    check_if_user_is_root

    # Mount the NFS share
    mount_share

    if [ $? -eq 0 ]; then
        
        debug_msg green "NFS share $nfsshare mounted successfully."

        debug_msg blue "----- Run Backup -----"
      
        cleanup

        targz_to_local_path
        
        rsync_to_remote_path
        
        sleep 5
        
        debug_msg blue "----- Disconnect from NFS Share -----"
        
        umount_share

    else

        debug_msg red "Failed to mount NFS $nfsshare share."

    fi

else

    debug_msg red "Host $host is not reachable."

fi