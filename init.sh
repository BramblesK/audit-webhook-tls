#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

openssl genrsa -out certs/ca.key 2048
openssl req -new -x509 -key certs/ca.key -out certs/ca.crt -config certs/ca_config.txt
openssl genrsa -out certs/audit-key.pem 2048
openssl req -new -key certs/audit-key.pem -subj "/CN=audit-webhook-service.zen.svc" -out audit.csr -config certs/audit_config.txt
openssl x509 -req -in audit.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/audit-crt.pem
export CA_BUNDLE=$(cat certs/ca.crt | base64 | tr -d '\n')

printf "the tls is created\n"

kubectl create secret tls audit-webhook-tls-secret --cert=/install/tls/genCerts/certs/ca.crt --key=/install/tls/genCerts/certs/ca.key -n zen
kubectl label secret audit-webhook-tls-secret -n zen app=audit-webhook
