#!/bin/bash
set -euo pipefail

BACKUP_TIMESTAMP=$(date +%Y.%m.%d:%H:%M:%S)

BACKUP_DIR="/home/system/mysql_backups"
EXCLUDED_DATABASES=("information_schema" "performance_schema" "sys")

MAX_BACKUP_AGE=7

function validate_backup_dir {
    if [[ -e "${BACKUP_DIR}" && ! -d "${BACKUP_DIR}" ]]; then 
        echo "${BACKUP_DIR} exists, but is not a directory!"
        exit 20
    elif [[ ! -e "${BACKUP_DIR}" ]]; then
        mkdir "${BACKUP_DIR}"
    fi
}

function backup {
    for db in $(mysql -BNe "show databases" | grep -v "${EXCLUDED_DATABASES[@]/#/-e}"); do
        backup_filename="${db}-${BACKUP_TIMESTAMP}.sql"

        mysqldump --single-transaction "${db}" > "${BACKUP_DIR}/${backup_filename}"
        gzip "${BACKUP_DIR}/${backup_filename}"
    done

    echo "Successfully backed up databases to ${BACKUP_DIR}"
}

function cleanup_old_backups {
    find "${BACKUP_DIR}" -type f -name '*.sql.gz' -mtime "+${MAX_BACKUP_AGE}" -print -delete
    echo "Deleted database backups older than ${MAX_BACKUP_AGE} days"
}

validate_backup_dir
backup
cleanup_old_backups
