#!/bin/bash

export SSL_DIR={{ provisioner.env.MOLECULE_EPHEMERAL_DIRECTORY }}/stages/bootstrap/build/secrets/root_cert/ssl
mkdir -p $SSL_DIR

cat << EOF > $SSL_DIR/req.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = {{ ansible_facts['all_ipv4_addresses'][1] }}
IP.1 =  {{ ansible_facts['all_ipv4_addresses'][1] }}
DNS.2 = {{ ansible_facts['all_ipv4_addresses'][0] }}
IP.2 =  {{ ansible_facts['all_ipv4_addresses'][0] }}
EOF

openssl genrsa -out $SSL_DIR/ca.key 4096
openssl req -x509 -new -nodes -key $SSL_DIR/ca.key -days 3650 -out $SSL_DIR/ca.crt -subj "/CN=kube-ca"

openssl genrsa -out $SSL_DIR/tls.key 4096
openssl req -new -key $SSL_DIR/tls.key -out $SSL_DIR/tls.csr -subj "/CN=kube-ca" -config $SSL_DIR/req.cnf
openssl x509 -req -in $SSL_DIR/tls.csr -CA $SSL_DIR/ca.crt -CAkey $SSL_DIR/ca.key -CAcreateserial -out $SSL_DIR/tls.crt -days 3650 -extensions v3_req -extfile $SSL_DIR/req.cnf
