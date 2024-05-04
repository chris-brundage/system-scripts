#!/bin/bash
set -euo pipefail

base_dir="intermediate"
config_file="${base_dir}/openssl.cnf"
cert_dir="${base_dir}/certs"
crl_file="${base_dir}/crl/intermediate.crl"

cert_name="$1"
if [[ -z "${cert_name}" ]]; then
    echo "A certificate name to revoke is required."
    exit 1
fi

cert_filename="${cert_dir}/${cert_name}.cert.pem"

openssl ca -config "${config_file}" -revoke "${cert_filename}" 
openssl ca -config "${config_file}" -gencrl -out "${crl_file}" 
