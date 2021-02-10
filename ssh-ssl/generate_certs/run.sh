#!/bin/sh
# https://jamielinux.com/docs/openssl-certificate-authority/index.html
# https://gist.github.com/Soarez/9688998

mkdir certs crl newcerts private
touch index.txt
echo 1000 > serial

# create root key
openssl genrsa -aes256 -out private/ca.key.pem 4096

#Enter pass phrase for ca.key.pem: secretpassword
#Verifying - Enter pass phrase for ca.key.pem: secretpassword

#chmod 400 private/ca.key.pem

# Create the root certificate
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem


# Enter pass phrase for ca.key.pem: secretpassword
# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# -----
# Country Name (2 letter code) [XX]:GB
# State or Province Name []:England
# Locality Name []:
# Organization Name []:Alice Ltd
# Organizational Unit Name []:Alice Ltd Certificate Authority
# Common Name []:Alice Ltd Root CA
# Email Address []:

# verify root CA
openssl x509 -noout -text -in certs/ca.cert.pem

pushd intermediate

mkdir certs crl newcerts private csr
touch index.txt
echo 1000 > serial

echo 1000 > crlnumber

popd

# create private key
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096

#Enter pass phrase for intermediate.key.pem: secretpassword
#Verifying - Enter pass phrase for intermediate.key.pem: secretpassword

# Create the intermediate certificate

openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem

# Enter pass phrase for intermediate.key.pem: secretpassword
# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# -----
# Country Name (2 letter code) [XX]:GB
# State or Province Name []:England
# Locality Name []:
# Organization Name []:Alice Ltd
# Organizational Unit Name []:Alice Ltd Certificate Authority
# Common Name []:Alice Ltd Intermediate CA
# Email Address []:

openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

# Enter pass phrase for ca.key.pem: secretpassword
# Sign the certificate? [y/n]: y


# verify
openssl x509 -noout -text \
      -in intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem \
      intermediate/certs/intermediate.cert.pem


# create certificate chain file

cat intermediate/certs/intermediate.cert.pem \
    certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem


# server cert

# use -aes256 to have a password protected key
openssl genrsa \
      -out intermediate/private/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.key.pem 2048

openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.key.pem \
      -new -sha256 -out intermediate/csr/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.csr.pem

# Enter pass phrase for nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.key.pem: secretpassword
# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# -----
# Country Name (2 letter code) [XX]:US
# State or Province Name []:California
# Locality Name []:Mountain View
# Organization Name []:Alice Ltd
# Organizational Unit Name []:Alice Ltd Web Services
# Common Name []:Nexus3 behind TLS auth
# Email Address []:

openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 3650 -notext -md sha256 \
      -in intermediate/csr/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.csr.pem \
      -out intermediate/certs/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.cert.pem

openssl x509 -noout -text \
      -in intermediate/certs/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/nexus3-tlsauth-proxy-devops-tools-dep.apps.cicd.arcus.soprasteria.com.cert.pem



# client cert

openssl genrsa \
      -out intermediate/private/client.key.pem 2048

openssl req -config intermediate/openssl.cnf \
      -key intermediate/private/client.key.pem \
      -new -sha256 -out intermediate/csr/client.csr.pem

# Enter pass phrase for client.key.pem: secretpassword
# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# -----
# Country Name (2 letter code) [XX]:US
# State or Province Name []:California
# Locality Name []:Mountain View
# Organization Name []:Alice Ltd
# Organizational Unit Name []:Alice Ltd Web Services
# Common Name []:Nexus3 behind TLS auth
# Email Address []:

openssl ca -config intermediate/openssl.cnf \
      -extensions usr_cert -days 3650 -notext -md sha256 \
      -in intermediate/csr/client.csr.pem \
      -out intermediate/certs/client.cert.pem

openssl x509 -noout -text \
      -in intermediate/certs/client.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/client.cert.pem