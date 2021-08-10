#!/bin/bash

set -eo pipefail

MOBILEPROV_NAME="itbznoicommunity.mobileprovision"
CERTIFICATE_NAME="ios_distribution.cer"
SECRETS_PATH="./.github/secrets"

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEY_PASSPHRASE" --output $SECRETS_PATH/$MOBILEPROV_NAME.mobileprovision $SECRETS_PATH/$MOBILEPROV_NAME.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_KEY_PASSPHRASE" --output $SECRETS_PATH/$CERTIFICATE_NAME $SECRETS_PATH/$CERTIFICATE_NAME.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp $SECRETS_PATH/$MOBILEPROV_NAME.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$MOBILEPROV_NAME.mobileprovision


security create-keychain -p "" build.keychain
security import $SECRETS_PATH/$CERTIFICATE_NAME -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
view raw
