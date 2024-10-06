#!/bin/bash

PORT=22015
REMOTE_USER="student-admin"
REMOTE_HOST="paffenroth-23.dyn.wpi.edu"
AUTHORIZED_KEYS_PATH="~/.ssh/authorized_keys"
PRIVATE_KEY_FILE="student-admin_key.pem"  # Path to the private key file

# Save the private key to a file
cat <<EOF > "$PRIVATE_KEY_FILE"
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAACRjdkS5FFxssF234a3fpZuOrXaEn1A4rLSxUNy+vbQAAAKAnwtEgJ8LR
IAAAAAtzc2gtZWQyNTUxOQAAACAACRjdkS5FFxssF234a3fpZuOrXaEn1A4rLSxUNy+vbQ
AAAEBUA21ze68DxYwSY9Fn+Tv8nDJ+sG4CzyfXy/QbRuqZmQAJGN2RLkUXGywXbfhrd+lm
46tdoSfUDistLFQ3L69tAAAAGnJjcGFmZmVucm90aEBwYWZmZW5yb3RoLTIzAQID
-----END OPENSSH PRIVATE KEY-----
EOF
chmod 600 "$PRIVATE_KEY_FILE"  # Ensure the private key has secure permissions

# Pre-defined public key contents
ARTURO_KEY_PUBLIC="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuil5VU/4F1yXT6SB8mM14imCrgKgcHHJEXLq+qwm2K arturo@LAPTOP-U3RU9JPS"
JOSE_KEY_PUBLIC="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/ximgjSS/j8aBYTKDOeHuYo5g919t1McNyLg8/b+3G josemanuel2000gmail.com@jose.local"
DAVID_KEY_PUBLIC="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpVLzBowx4E2euLHw93BMASzwmh9D70EInSXAREntiL david@Jennifer"

# Key to be removed (from your instruction)
CLASS_KEY_PUBLIC="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAJGN2RLkUXGywXbfhrd+lm46tdoSfUDistLFQ3L69t rcpaffenroth@paffenroth-23"

# List of users and their keys
users_keys=("$ARTURO_KEY_PUBLIC" "$JOSE_KEY_PUBLIC" "$DAVID_KEY_PUBLIC")

# Function to upload a key to the server
upload_key() {
    local user_key_content=$1

    echo "Adding the public key to the server's authorized_keys..."
    ssh -p "$PORT" -i "$PRIVATE_KEY_FILE" "$REMOTE_USER@$REMOTE_HOST" "echo '$user_key_content' >> $AUTHORIZED_KEYS_PATH"
}

# Function to remove the specific class key from the server
remove_class_key() {
    echo "Removing the class key from authorized_keys on the server..."
    ssh -p "$PORT" -i "$PRIVATE_KEY_FILE" "$REMOTE_USER@$REMOTE_HOST" "sed -i '/$CLASS_KEY_PUBLIC/d' $AUTHORIZED_KEYS_PATH"
}

# Step 1: Add the public keys of the users to the server
for key in "${users_keys[@]}"; do
    echo "Processing key..."
    upload_key "$key"
done

# Step 2: Remove the original class key from the server
remove_class_key

# Remove the local private key file
rm -f "$PRIVATE_KEY_FILE"

echo "Process complete: All keys updated on the server."
