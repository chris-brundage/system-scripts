#!/bin/bash
set -euo pipefail

LOG_TIMESTAMP_FORMAT="+%Y-%m-%d %H:%M:%S"

BACKUP_PATH="/home/system/backups"
BACKUP_FILENAME="system-backup-$(date +%Y-%m-%dT%H:%M:%S).tar.gz"
BACKUP_FILENAME="${BACKUP_PATH}/${BACKUP_FILENAME}"

TAR_EXCLUDES=(
    "/tmp/*" 
    "/media/*"
    "/mnt/*"
    "/home/*"
    "/backup/*"
    "/backup-old/*"
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
    "/var/lib/pterodactyl/*"
)
TAR_CMD=(tar --create --acls --selinux --xattrs --gzip)
TAR_CMD+=(--file "${BACKUP_FILENAME}")
TAR_CMD+=("${TAR_EXCLUDES[@]/#/--exclude=}")
TAR_CMD+=("/")

log_message() {
    printf "[%s] %s\n" "$(date "${LOG_TIMESTAMP_FORMAT}")" "${1}"
}

log_message "Backing up system to ${BACKUP_FILENAME}"

"${TAR_CMD[@]}"

log_message "Successfully backed up system to ${BACKUP_FILENAME}"

log_message "Cleaning up backups older than 7 days from ${BACKUP_PATH}"

find "${BACKUP_PATH}" -type f -name '*.tar.gz' -mtime +7 -print -delete
