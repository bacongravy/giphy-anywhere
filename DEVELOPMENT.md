# Development

This project is configured to use [GitHub Actions](https://github.com/features/actions) for continuous integration and deployment. The project is rebuilt on every commit and a signed, notarized disk image is published as a GitHub release on every tag. After the app is pubished, a cask in a Homebrew tap is updated to point to the new version.

## CI integration

Secrets for signing, notarizing, and deploying must be set in order for the workflow to run successfully.

### Signing

1. Create and download a Developer ID certificate from developer.apple.com
1. Install the .cer file in Keychain Access
1. Find the certificate and private key in Keychain Access and export them in .p12 format
1. Set a password for the p12 file
1. Base64-encode the p12 file: `base64 -i Certificates.p12`
1. Set the SIGNING_CERTIFICATE_P12_DATA secret with the data
1. Set the SIGNING_CERTIFICATE_PASSWORD secret with the password

### Notarizing

1. Generate an [application specific password](https://support.apple.com/en-us/HT204397) for your developer account
1. Set the NOTARIZE_USERNAME secret to your developer account username
1. Set the NOTARIZE_PASSWORD secret to the generated application specific password

### Deploying

1. Generate a GitHub OAuth token that has access to a Homebrew tap repository
1. Set the CASK_REPO secret to the name of the tap repository (e.g. `bacongravy/homebrew-tap`)
1. Set the CASK_REPO_TOKEN secret to the generated OAuth token
