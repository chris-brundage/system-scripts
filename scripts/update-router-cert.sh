#!/usr/bin/env bash
set -euo pipefail

CERT_DOMAIN_NAME="*.home.brundage.me"

domain_updated=0
for domain_name in ${RENEWED_DOMAINS:-}; do
    if [[ "${domain_name}" == "${CERT_DOMAIN_NAME}" ]]; then
        domain_updated=1
        break
    fi
done

if [[ "${domain_updated}" -ne 1 ]]; then
    printf "Router cert %s was not updated. Exiting\n" "${CERT_DOMAIN_NAME}"
    printf "Updated domains include: %s\n" "${RENEWED_DOMAINS:-}"
    exit 0
fi

if [[ ! -d "${RENEWED_LINEAGE:-}" ]]; then
    printf "The Letsencrypt cert dir %s does not exist. Huh?\n" "${RENEWED_LINEAGE:-}"
    exit 1
fi

SSH_IDENTITY_FILE="/root/.ssh/id_rsa_router"

ROUTER_IP="192.168.50.1"
ROUTER_USER="root"

CERT_DIR="/etc/ssl"

CERT_FILENAME="${CERT_DIR}/wildcard.home.brundage.me.pem"
PRIVATE_KEY_FILENAME="${CERT_DIR}/private/wildcard.home.brundage.me.key"

scp -i "${SSH_IDENTITY_FILE}" "${RENEWED_LINEAGE}/fullchain.pem" "${ROUTER_USER}"@"${ROUTER_IP}":"${CERT_FILENAME}"
scp -i "${SSH_IDENTITY_FILE}" "${RENEWED_LINEAGE}/privkey.pem" "${ROUTER_USER}"@"${ROUTER_IP}":"${PRIVATE_KEY_FILENAME}"

ssh -i "${SSH_IDENTITY_FILE}" "${ROUTER_USER}"@"${ROUTER_IP}" /etc/init.d/uhttpd restart
