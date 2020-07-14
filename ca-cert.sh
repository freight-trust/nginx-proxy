#!/usr/bin/env bash
# <!-- Edit -->
 
commonName=node.user1
certDir=/tmp/certs
caCert=/tmp/certs/ca-cert-chain.pem
intCert=/tmp/certs/int-cert.pem
intKey=/tmp/certs/int-key.pem
extFile=/tmp/certs/user.ext
 
# <!-- Do Not Edit Below -->
 
ORG_NAME="/O=Freight Trust Network LLC/OU=Validators/C=US"
 
TLS_VALIDITY=2922
TLS_KEY_SIZE=2048
KEY_ENC_ALG=-aes256
SIGN_ALG=-sha256
PASSWORD=$PASSWORD
 
SN=0
 
function genSN
{
    SN=`expr $SN + 1`
}
 
printf "Creating $commonName cert\n"
 
printf "Creating User key\n"
openssl genrsa $KEY_ENC_ALG -passout pass:$PASSWORD -out $certDir/$commonName-key.pem $TLS_KEY_SIZE
 
printf  "Generating User certificate request\n"
openssl req -new -key $certDir/$commonName-key.pem -passin pass:$PASSWORD -subj "/CN=$commonName$ORG_NAME" -out $certDir/$commonName-req.pem
 
printf "Creating User certificate\n"
genSN
openssl x509 -req $SIGN_ALG -days $TLS_VALIDITY -in $certDir/$commonName-req.pem -CA $intCert -CAkey $intKey -passin pass:$PASSWORD -out $certDir/$commonName-cert.pem -set_serial 0x$SN -extfile $extFile
 
printf "Creating PKCS12 file including key and certificates\n"
 
openssl pkcs12 -export -out $certDir/$commonName.p12 -aes256 -in $certDir/$commonName-cert.pem -inkey $certDir/$commonName-key.pem -passin pass:$PASSWORD -certfile $caCert -passout pass:$PASSWORD
