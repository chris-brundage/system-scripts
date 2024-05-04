#!/bin/bash
set -euo pipefail

source "/etc/default/home-scripts.env"

ALERT_EMAIL_SUBJECT="ZFS Auto Scrub Status"

print_help () {
    echo "Please provide a valid zfs pool as the first argument to this script."
    exit 1
}


pool="${1:-}"
if [[ -z "${pool}" ]]; then
    print_help
fi

if ! /sbin/zpool status "${pool}" >/dev/null 2>&1; then
    echo "${pool} is not a valid zfs pool"
    exit 1
fi

if /bin/systemctl status sanoid.timer >/dev/null 2>&1; then
    /bin/systemctl stop sanoid.timer
fi

if /sbin/zpool scrub -w "${pool}"; then
    /bin/systemctl start sanoid.timer
else
    echo "Error scrubbing zfs pool ${pool}. Refer to zpool status for more information"
    echo "Error scrubbing zfs pool ${pool}. Refer to zpool status for more information" | /usr/bin/mail -s "${ALERT_EMAIL_SUBJECT}" "${ALERTS_EMAIL_RECIPIENT}"
fi
