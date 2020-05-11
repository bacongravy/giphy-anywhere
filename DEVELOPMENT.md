# Development

This project is configured to use [Travis CI](https://travis-ci.org) for continuous integration and deployment. The project is rebuilt on every commit and a signed, notarized disk image is published as a GitHub release on every tag.

## CI integration

* create and download a Developer ID certificate from developer.apple.com
* install the .cer file in Keychain Access
* find the certificate and private key in Keychain Access and export them in .p12 format
* set a password for the p12 file
* base64-encode the p12 file: `base64 -i Certificates.p12`
* set the SIGNING_CERTIFICATE_P12_DATA environment variable in Travis CI with the data
* set the SIGNING_CERTIFICATE_PASSWORD environment variable in Travis CI with the password
* set the SIGNING_DEVELOPMENT_TEAM environment variable in Travis CI to "WPEJJ9FF9Y"
* set the SIGNING_IDENTITY environment variable in Travis CI to "Developer ID Application: David Kramer (WPEJJ9FF9Y)"
* generate an [application specific password](https://support.apple.com/en-us/HT204397) for your developer account
* set the NOTARIZATION_USERNAME environment variable in Travis CI to your developer account username
* set the NOTARIZATION_PASSWORD environment variable in Travis CI to the generated application specific password
* generate a GitHub OAuth token
* set the GITHUB_OAUTH_TOKEN environment variable in Travis CI to the token

## Local testing of CI integration

Testing keychain setup:

* Export the certificate and private key in .p12 format and set a password
* Set the environment variables
  * export SIGNING_CERTIFICATE_P12_DATA=\`base64 -i Certificates.p12\`
  * export SIGNING_CERTIFICATE_PASSWORD=password
  * export SIGNING_DEVELOPMENT_TEAM=WPEJJ9FF9Y
  * export SIGNING_IDENTITY="Developer ID Application: David Kramer (WPEJJ9FF9Y)"
* Run `scripts/setup_keychain.sh`

Testing building (uses the certificate/key from the login keychain):

* Set the environment variables
  * export SIGNING_DEVELOPMENT_TEAM=WPEJJ9FF9Y
  * export SIGNING_IDENTITY="Developer ID Application: David Kramer (WPEJJ9FF9Y)"
* Run `scripts/build.sh`

Testing notarization:

* Set the environment variables
  * export NOTARIZATION_USERNAME=stevejobs@icloud.com
  * export NOTARIZATION_PASSWORD=abcd-efgh-ijkl-mnop
* Run `scripts/notarize.sh`
* Verify that the signing and notarization worked
  * Quarantine the disk image: `xattr -w com.apple.quarantine "0000;00000000;Safari;" build/GIPHY_Anywhere.dmg`
  * Open the disk image
  * Open GIPHY Anywhere.app

