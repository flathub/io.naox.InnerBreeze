#!/bin/sh

REPO="naoxio/inbreeze"
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
echo "Latest tag: $LATEST_TAG"
TAR_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/InnerBreeze-Linux-x86_64.tar.gz"
echo "Tar URL: $TAR_URL"
curl -sL $TAR_URL -o temp.tar.gz
SHA256_HASH=$(sha256sum temp.tar.gz | awk '{ print $1 }')
echo "SHA256 Hash: $SHA256_HASH"
rm temp.tar.gz
JSON_FILE="io.naox.InnerBreeze.json"
jq --arg url "$TAR_URL" --arg hash "$SHA256_HASH" \
   '(.modules[] | select(.name == "InnerBreeze") | .sources[] | select(.type == "archive")).url = $url |
    (.modules[] | select(.name == "InnerBreeze") | .sources[] | select(.type == "archive")).sha256 = $hash' \
   $JSON_FILE > temp.json && mv temp.json $JSON_FILE

echo "JSON file updated."

git add $JSON_FILE
git commit -m "Update InnerBreeze to version $LATEST_TAG"
git push

echo "Git commit and push done."
