#!/bin/sh

CERTIFICATE_FILE=Certificate.p12
KEYCHAIN_FILE=travis.keychain
KEYCHAIN_PASSWORD=travis

echo "Setting up keychain..."

echo $SIGNING_CERTIFICATE_P12_DATA | base64 --decode > $CERTIFICATE_FILE;

security create-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
security default-keychain -s $KEYCHAIN_FILE
security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
security import $CERTIFICATE_FILE -k $KEYCHAIN_FILE -P $SIGNING_CERTIFICATE_PASSWORD -T /usr/bin/codesign

# https://stackoverflow.com/a/40039594
security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD $KEYCHAIN_FILE
