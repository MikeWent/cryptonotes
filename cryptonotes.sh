#!/bin/bash

if [ ! -f /usr/bin/openssl ] || [ ! -f /usr/bin/zenity ] || [ ! -f /usr/bin/xdg-open ] || [ ! -f /bin/mktemp ]; then
    echo "Unable to satisfy one of these dependencies: openssl, zenity, xdg-open, mktemp"
    exit 1
fi

function decrypt () {
    openssl aes-256-cbc -d -a -pbkdf2 -k "$PASSWORD" -in "$ENCRYPTED_FILENAME" -out "$PLAINTEXT_FILENAME"
}

function encrypt () {
    openssl aes-256-cbc -e -a -pbkdf2 -k "$PASSWORD" -in "$PLAINTEXT_FILENAME" -out "$ENCRYPTED_FILENAME"
}

ENCRYPTED_FILENAME="$1"
# ask for a password
PASSWORD="$(zenity --password)"
# create a plaintext file that is readable by current user only
PLAINTEXT_FILENAME=$(mktemp ~/.local/share/XXXXXXX.txt)
# try to decrypt note
if [[ -s "$ENCRYPTED_FILENAME" ]]; then
    decrypt || error=1
    if [ "$error" == 1 ]; then
        zenity --error --text="Wrong password, unable to decrypt." --no-wrap
        rm "$PLAINTEXT_FILENAME"
        exit
    fi
fi
# start editor
xdg-open "$PLAINTEXT_FILENAME"
# encrypt notes
encrypt && zenity --info --text="Encrypted and saved successfully!" --icon-name=security-high --no-wrap
