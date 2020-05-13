#!/bin/sh

# TRAVIS_TAG
# GITHUB_USERNAME
# GITHUB_OAUTH_TOKEN

CASK_NAME=giphy-anywhere
FILENAME="build/GIPHY_Anywhere.dmg"
TARGET_REPO=bacongravy/homebrew-tap

CASK_VERSION=$(echo $TRAVIS_TAG | cut -c2-)
SHA256=$(shasum --algorithm 256 $FILENAME | awk '{print $1}')

echo "Updating cask..."

curl \
  -X POST \
  -u "$GITHUB_USERNAME:$GITHUB_OAUTH_TOKEN" \
  -H "Accept: application/vnd.github.everest-preview+json" \
  -H "Content-Type: application/json" \
  --data '{"event_type":"update_cask","client_payload":{"name":"'${CASK_NAME}'","version":"'${CASK_VERSION}'","sha256":"'${SHA256}'"}}' \
  https://api.github.com/repos/${TARGET_REPO}/dispatches
