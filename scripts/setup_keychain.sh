#!/bin/bash

KEYCHAIN_FILE=default.keychain
KEYCHAIN_PASSWORD=myvoiceismypassport

echo "Setting up keychain..."

security create-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
security default-keychain -s $KEYCHAIN_FILE
security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
security import <(echo $SIGNING_CERTIFICATE_P12_DATA | base64 --decode) \
                -f pkcs12 \
                -k $KEYCHAIN_FILE \
                -P $SIGNING_CERTIFICATE_PASSWORD \
                -T /usr/bin/codesign

# https://stackoverflow.com/a/40039594
security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
