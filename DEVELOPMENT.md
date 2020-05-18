# Development

This project is configured to use [GitHub Actions](https://github.com/features/actions) for continuous integration and deployment. The project is rebuilt on every commit and a signed, notarized disk image is published as a GitHub release on every tag. After the app is pubished, a cask in a Homebrew tap is updated to point to the new version.

## CI integration

* create and download a Developer ID certificate from developer.apple.com
* install the .cer file in Keychain Access
* find the certificate and private key in Keychain Access and export them in .p12 format
* set a password for the p12 file
* base64-encode the p12 file: `base64 -i Certificates.p12`
* set the SIGNING_CERTIFICATE_P12_DATA secret on GitHub with the data
* set the SIGNING_CERTIFICATE_PASSWORD secret on GitHub with the password
* generate an [application specific password](https://support.apple.com/en-us/HT204397) for your developer account
* set the NOTARIZE_USERNAME secret on GitHub to your developer account username
* set the NOTARIZE_PASSWORD secret on GitHub to the generated application specific password
* generate a GitHub OAuth token that has access to the Homebrew tap
* set the CASK_REPO_USERNAME secret on GitHub to the username used to generate the OAuth token
* set the CASK_REPO_TOKEN secret on GitHub to the OAuth token
