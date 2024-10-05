#!/bin/bash
set -u

LOG_TIMESTAMP_FORMAT="+%Y-%m-%d %H:%M:%S"

BACKUP_PATH="/home/system/backups"
BACKUP_FILENAME="system-backup-$(date +%Y-%m-%dT%H:%M:%S).tar.gz"
BACKUP_FILENAME="${BACKUP_PATH}/${BACKUP_FILENAME}"

TAR_EXCLUDES=(
    "/boot/*"
    "/tmp/*" 
    "/media/*"
    "/mnt/*"
    "/home/*"
    "/backup/*"
    "/backup-old/*"
    "/opt/games/*"
    "/dev/*"
    "/sys/*"
    "/proc/*"
    "/run/*"
    "lost+found"
    "/pool"
    "/srv/kvm/*"
    "/srv/kvm-disks/*"
    "/var/db/repos/gentoo"
    "/var/cache/distfiles/*"
    "/var/lock/*"
    "/var/run/*"
    "/var/lib/docker/*"
    "/var/lib/mysql/*"
    "/var/lib/pterodactyl/*"
    "/var/tmp/*"
)
TAR_CMD=(tar --create --acls --selinux --xattrs --gzip)
# Make tar output less spammy
TAR_CMD+=(--warning=no-file-changed)
TAR_CMD+=(--warning=no-file-ignored)
TAR_CMD+=(--file "${BACKUP_FILENAME}")
TAR_CMD+=("${TAR_EXCLUDES[@]/#/--exclude=}")
TAR_CMD+=("/")

log_message() {
    printf "[%s] %s\n" "$(date "${LOG_TIMESTAMP_FORMAT}")" "${1}"
}

log_message "Backing up system to ${BACKUP_FILENAME}"

"${TAR_CMD[@]}"

# tar will exit 1 if a fail changes while building the archive
# this is ok for our purposes, but prevents simple error handling 
tar_exit_code=$?
if [[ "${tar_exit_code}" -ne 0 && "${tar_exit_code}" -ne 1 ]]; then
    log_message "Error creating backup file at ${BACKUP_FILENAME}"
    exit "${tar_exit_code}"
fi

log_message "Successfully backed up system to ${BACKUP_FILENAME}"

log_message "Cleaning up backups older than 7 days from ${BACKUP_PATH}"

find "${BACKUP_PATH}" -type f -name '*.tar.gz' -mtime +4 -print -delete
