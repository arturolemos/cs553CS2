#!/bin/bash

PORT=22015
REMOTE_USER="student-admin"
REMOTE_HOST="paffenroth-23.dyn.wpi.edu"

# List of public keys to try
KEY_LIST=("david_key" "arturo_key" "jose_key")

# Function to attempt SSH and run the commands
attempt_ssh() {
    PUBLIC_KEY=$1
    echo "Attempting to connect with key: $PUBLIC_KEY"

    ssh -i "$PUBLIC_KEY" -p "$PORT" "$REMOTE_USER@$REMOTE_HOST" << 'EOF'

    REPO="https://github.com/arturolemos/cs553CS2.git"
    PYTHON_VERSION="3.9"

    # Ensure we're in the home directory
    cd ~

    REPO_NAME=$(basename "$REPO" .git)

    # Check if the repository directory already exists
    if [ -d "$REPO_NAME" ]; then
        echo "Repository directory $REPO_NAME already exists. Deleting it..."
        rm -rf "$REPO_NAME"
    fi

    echo "Cloning repository $REPO..."
    git clone "$REPO"

    echo "Changing directory to $REPO_NAME..."
    cd "$REPO_NAME"

    echo "Downloading Miniconda installer..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

    echo "Installing Miniconda..."
    bash Miniconda3-latest-Linux-x86_64.sh -b -u

    echo "Activating Miniconda..."
    source ~/miniconda3/bin/activate

    echo "Creating Conda environment with Python $PYTHON_VERSION..."
    conda create --name myenv "python=$PYTHON_VERSION" -y

    echo "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt

    # Make app.py executable
    echo "Giving executable permission to app.py..."
    chmod +x app.py

    # Run app.py
    echo "Running app.py..."
    ./app.py

    echo "Setup and execution complete."
EOF

    # Return SSH exit status
    return $?
}

# Iterate through the list of keys and try to connect
for PUBLIC_KEY in "${KEY_LIST[@]}"; do
    attempt_ssh "$PUBLIC_KEY"
    if [ $? -eq 0 ]; then
        echo "Connected successfully with key: $PUBLIC_KEY"
        exit 0
    else
        echo "Failed to connect with key: $PUBLIC_KEY"
    fi
done

echo "All SSH connection attempts failed."
exit 1

EOF

echo "Connection closed."

