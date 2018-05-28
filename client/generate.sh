#!/bin/bash

set -e

USER_NAME=$1

UPN=$USER_NAME@localhost

PFX_FILE=`pwd`/cert.pfx
PFX_PASSWORD=111111

PEM_FILE=`pwd`/cert.pem
PEM_KEY_FILE=`pwd`/cert.key.pem

CA_DIR=`mktemp -d -t openssl`




pushd .
cd $CA_DIR

mkdir private
chmod 700 private
mkdir certs

cat > conf << EOF
distinguished_name  = req_distinguished_name

[req_distinguished_name]

[v3_req_client]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:$UPN
EOF

export OPENSSL_CONF=conf

openssl req -x509 -newkey rsa:2048 -nodes -sha1 -keyout private/cert.key -out certs/cert.pem -days 3650 -outform PEM -extensions v3_req_client -subj \
"/C=CN/ST=Beijing/L=Dongcheng/emailAddress=jijie.chen@outlook.com/organizationName=DevOps/CN=$USER_NAME"
openssl pkcs12 -export -in certs/cert.pem -inkey private/cert.key -out $PFX_FILE -password pass:$PFX_PASSWORD

rm conf



cp certs/cert.pem $PEM_FILE
cp private/cert.key $PEM_KEY_FILE



rm -rf $CA_DIR


popd







