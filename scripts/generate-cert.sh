#!/bin/bash
set -euo pipefail

base_dir="intermediate"
config_file="${base_dir}/openssl.cnf"
cert_dir="${base_dir}/certs"
key_dir="${base_dir}/private"
csr_dir="${base_dir}/csr"

# Special CSR config for requesting wildcard certs
wildcard_req_config_file="${base_dir}/wildcard_req.cnf"

cert_name="${1:-}"
if [[ -z "${cert_name}" ]]; then
    echo "A certificate name to revoke is required."
    exit 1
fi

cert_filename="${cert_dir}/${cert_name}.cert.pem"
csr_filename="${csr_dir}/${cert_name}.csr.pem"
key_filename="${key_dir}/${cert_name}.key.pem"

openssl_req_args=("req")
# Good enough for me way to decide if a req is for a wildcard cert
if [[ "${cert_name}" == wildcard.* ]]; then
    openssl_req_args+=("-config" "${wildcard_req_config_file}")
fi
# Make a new key or use an existing key if provided
if [[ -n "${2:-}" ]]; then
    openssl_req_args+=("-key" "$2")
else
    openssl_req_args+=("-newkey" "rsa:2048" "-noenc")
fi
openssl_req_args+=("-keyout" "${key_filename}" "-out" "${csr_filename}")

openssl "${openssl_req_args[@]}"
openssl ca -config "${config_file}" -extensions server_cert -days 365 -notext -md sha256 -in "${csr_filename}" -out "${cert_filename}" 
