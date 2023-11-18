#!/bin/bash

# Define the repository
REPO="naoxio/inner_breeze"

# Get the latest tag from GitHub
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
echo "Latest tag: $LATEST_TAG"

# Define the URL of the tar.gz file
TAR_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/InnerBreeze-Linux-x86_64.tar.gz"
echo "Tar URL: $TAR_URL"

# Download the tar.gz file
curl -sL $TAR_URL -o temp.tar.gz

# Calculate the sha256 hash of the tar.gz file
SHA256_HASH=$(sha256sum temp.tar.gz | awk '{ print $1 }')
echo "SHA256 Hash: $SHA256_HASH"

# Remove the downloaded tar.gz file
rm temp.tar.gz

# Update the JSON file
JSON_FILE="io.naox.InnerBreeze.json"
jq --arg url "$TAR_URL" --arg hash "$SHA256_HASH" \
   '(.modules[] | select(.name == "InnerBreeze") | .sources[] | select(.type == "archive")).url = $url |
    (.modules[] | select(.name == "InnerBreeze") | .sources[] | select(.type == "archive")).sha256 = $hash' \
   $JSON_FILE > temp.json && mv temp.json $JSON_FILE

echo "JSON file updated."

