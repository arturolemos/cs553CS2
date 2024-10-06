#!/bin/bash

# Needs to be run from the same folder where student-admin_key is
# Need to set executable permisions accordingly: chmod u+x securekeys.sh

port=22015  

if [ -z "$1" ]; then
    read -p "Please enter the name of the key: " key_name
else
    key_name="$1"
fi

if [ -z "$2" ]; then
    read -p "Please enter the key password: " key_password
else
    key_password="$2"
fi

ssh-keygen -t ed25519 -f "$key_name" -N "$key_password"

scp -P "$port" -i student-admin_key "$key_name.pub" student-admin@paffenroth-23.dyn.wpi.edu:~/
