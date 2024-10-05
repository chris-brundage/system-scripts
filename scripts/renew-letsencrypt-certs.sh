#!/bin/bash
set -euo pipefail

VIRTUALENV="${1}"

source "${VIRTUALENV}/bin/activate" || exit 1
command -v certbot >/dev/null 2>&1 || exit 1
certbot renew -n \
    --post-hook "systemctl reload nginx.service" \
    --deploy-hook /usr/local/bin/update-router-cert.sh
