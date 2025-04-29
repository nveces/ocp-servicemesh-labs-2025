#!/bin/sh

if [ $# -ne 3 ]; then
  echo 1>&2 "Usage: $0 DOMAIN CN TARGET_DIR" 
  exit 1
fi

DOMAIN=$1
CN=$2
TARGET_DIR=$3/$DOMAIN
mkdir -p $TARGET_DIR

printf "\n[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n\n[req_distinguished_name]\n\n[v3_req]\nsubjectAltName=@alt_names\n\n[alt_names]\nDNS.1=${DOMAIN}" > $TARGET_DIR/openssl.conf
OPENSSL_FILE=$TARGET_DIR/openssl.conf

printf "\nsubjectAltName=@alt_names\n\n[alt_names]\nDNS.1=${DOMAIN}" > $TARGET_DIR/v3.ext
V3EXT_FILE=$TARGET_DIR/v3.ext

echo "Openssl file: $OPENSSL_FILE"

cat $OPENSSL_FILE

openssl req \
    -new \
    -newkey rsa:2048 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Redhat/CN=${CN}" \
    -config $OPENSSL_FILE \
    -keyout $TARGET_DIR/ca.key \
    -out $TARGET_DIR/ca.cert

openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=Redhat/CN=${CN}" \
    -config $OPENSSL_FILE \
    -keyout $TARGET_DIR/cert.key \
    -out $TARGET_DIR/cert.csr

openssl x509 \
    -req \
    -days 365 \
    -in $TARGET_DIR/cert.csr \
    -CA $TARGET_DIR/ca.cert \
    -CAkey $TARGET_DIR/ca.key \
    -CAcreateserial \
    -extfile $V3EXT_FILE \
    -out $TARGET_DIR/cert.cert

openssl pkcs12 \
    -export \
    -passout pass: \
    -in $TARGET_DIR/cert.cert \
    -inkey $TARGET_DIR/cert.key \
    -out $TARGET_DIR/cert.p12

openssl pkcs12 \
    -in $TARGET_DIR/cert.p12 \
    -nodes \
    -out $TARGET_DIR/cert.pem \
    -passin pass: