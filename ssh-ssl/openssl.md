# OPENSSL

https://www.sslshopper.com/article-most-common-openssl-commands.html

```sh
openssl x509 -text -inform DER -in gitlabptx.cer
openssl x509 -text -inform PEM -in gitlabptx.pem
openssl x509 -in certificate.crt -text -noout
```

```sh
openssl pkcs12 -in rootCert.pfx -out rootCert.crt -nokeys -clcerts
openssl x509 -inform pem -in rootCert.crt -outform der -out rootCert.cer
openssl x509 -in rootCert.crt -outform PEM -out rootCert.pem
```

## General OpenSSL Commands

Generate a new private key and Certificate Signing Request

`openssl req -out CSR.csr -new -newkey rsa:2048 -nodes -keyout privateKey.key`

Generate a self-signed certificate (see How to Create and Install an Apache Self Signed Certificate for more info)

`openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt`

Generate a certificate signing request (CSR) for an existing private key

`openssl req -out CSR.csr -key privateKey.key -new`

Generate a certificate signing request based on an existing certificate

`openssl x509 -x509toreq -in certificate.crt -out CSR.csr -signkey privateKey.key`

Remove a passphrase from a private key

`openssl rsa -in privateKey.pem -out newPrivateKey.pem`

## Checking Using OpenSSL

Get remote server certificate chain

`openssl s_client -showcerts -connect gitlab.ptx.fr.sopra:443`

Get remote server certificate and save as file 

`openssl s_client -showcerts -connect www.example.com:443 < /dev/null | openssl x509 -outform DER > derp.der`

Check a Certificate Signing Request (CSR)

`openssl req -text -noout -verify -in CSR.csr`

Check a private key

`openssl rsa -in privateKey.key -check`

Check a certificate

`openssl x509 -in certificate.crt -text -noout`

Check a PKCS#12 file (.pfx or .p12)

`openssl pkcs12 -info -in keyStore.p12`

## Converting Using OpenSSL

Convert a DER file (.crt .cer .der) to PEM

`openssl x509 -inform der -in certificate.cer -out certificate.pem`

Convert a PEM file to DER

`openssl x509 -outform der -in certificate.pem -out certificate.der`

Convert a PKCS#12 file (.pfx .p12) containing a private key and certificates to PEM

`openssl pkcs12 -in keyStore.pfx -out keyStore.pem -nodes`

You can add -nocerts to only output the private key or add -nokeys to only output the certificates.

Convert a PEM certificate file and a private key to PKCS#12 (.pfx .p12)

`openssl pkcs12 -export -out certificate.pfx -inkey privateKey.key -in certificate.crt -certfile CACert.crt`
