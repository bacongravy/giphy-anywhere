#!/bin/bash

# adapted from https://scriptingosx.com/2019/09/notarize-a-command-line-tool/

# NOTARIZATION_USERNAME
# NOTARIZATION_PASSWORD

FILENAME="build/GIPHY_Anywhere.dmg"
PRIMARY_BUNDLE_ID="net.bacongravy.giphy-anywhere"

echo "Notarizing disk image..."

requeststatus() {
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --username "$NOTARIZATION_USERNAME" \
                              --password "$NOTARIZATION_PASSWORD" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$req_status"
}

requestUUID=$(xcrun altool --notarize-app \
                            --primary-bundle-id "$PRIMARY_BUNDLE_ID" \
                            --username "$NOTARIZATION_USERNAME" \
                            --password "$NOTARIZATION_PASSWORD" \
                            --file "$FILENAME" 2>&1 \
                | awk '/RequestUUID/ { print $NF; }')
                            
echo "Notarization RequestUUID: $requestUUID"

if [[ $requestUUID == "" ]]; then 
    echo "could not upload for notarization"
    exit 1
fi
    
request_status="in progress"
while [[ "$request_status" == "in progress" ]]; do
    echo -n "waiting... "
    sleep 10
    request_status=$(requeststatus "$requestUUID")
    echo "$request_status"
done

xcrun altool --notarization-info "$requestUUID" \
                --username "$NOTARIZATION_USERNAME" \
                --password "$NOTARIZATION_PASSWORD"

xcrun stapler staple "$FILENAME"

echo 

if [[ $request_status != "success" ]]; then
    echo "could not notarize $FILENAME"
    exit 1
fi
