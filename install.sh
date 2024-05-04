#!/bin/bash
set -euo pipefail

TARGET_DIR="/usr/local/bin"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for script in "${SCRIPT_DIR}"/scripts/*.sh; do
    filename="$(basename "${script}")"
    ln -sf "${script}" "${TARGET_DIR}/${filename}"
done
