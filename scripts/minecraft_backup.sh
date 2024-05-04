#!/bin/bash
source /etc/default/home-scripts.env

CONTAINER_VOLUME="${1}"
CONTAINER_ID="$(echo "${CONTAINER_VOLUME}" | awk -F/ '{print $NF}')"

BACKUP_DIR="/home/system/minecraft_backups/${CONTAINER_ID}"
MAX_BACKUP_AGE=14

function remove_old_backups {
    echo "Deleting backups over ${MAX_BACKUP_AGE} days old"
    echo

    mapfile -t removed_backups < <(find "${BACKUP_DIR}" -type f -mtime "+${MAX_BACKUP_AGE}" -print -delete)

    echo "The following backups were deleted:"
    for backup in "${removed_backups[@]}"; do
        echo "${backup}"
    done
}

function rcon {
    /usr/bin/mcrcon -H "${MCRCON_HOST}" -P "${MCRCON_PORT}" -p "${MCRCON_PASS}" "${1}"
}

rcon 'say [WARNING!] Server backup process will begin in 1 hour.'

sleep 50m
rcon 'say [WARNING!] Server backup process will begin in 10 minutes.'

sleep 5m
rcon 'say [WARNING!] Server backup process will begin in 5 minutes.'

sleep 4m
rcon 'say [WARNING!] Server backup process will begin in 1 minute.'

sleep 1m
rcon 'say [WARNING!] Serer backup is starting NOW!' 

rcon "save-off"
rcon "save-all"

sleep 5
backup_filename="${BACKUP_DIR}/mc-server-$(date +%Y.%m.%dT%H:%M:%S).tar.gz"

if ! tar czf "${backup_filename}" "${CONTAINER_VOLUME}"; then
    backup_failed=1
else
    backup_failed=0
fi

rcon "save-on"

if [[ "${backup_failed}" == 0 ]]; then
    rcon 'say [NOTICE!] Server backup is complete.'

    echo "Successfully backed up server to ${backup_filename}"
else
    rcon 'say [WARNING!] Backup completed with errors. It is safe to continue playing.'

    echo "Error backing up server to ${backup_filename}!"
    exit 1
fi

remove_old_backups
