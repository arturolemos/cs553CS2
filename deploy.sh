#!/bin/bash

PORT=22015
REMOTE_USER="student-admin"
REMOTE_HOST="paffenroth-23.dyn.wpi.edu"

# Specify the private key to use
PRIVATE_KEY="my_key"

echo "Attempting to connect with key: $PRIVATE_KEY"

# Attempt SSH and run the commands
ssh -t -i "$PRIVATE_KEY" -p "$PORT" "$REMOTE_USER@$REMOTE_HOST" << 'EOF'

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

    echo "Activating the environment..."
    conda activate myenv

    echo "Installing dependencies from requirements.txt..."
    pip install -r requirements.txt

    # Make app.py executable
    echo "Giving executable permission to app.py..."
    chmod +x app.py

    # Run app.py
    echo "Running app.py..."
    python3 app.py

    echo "Setup and execution complete."
EOF

echo "Connection closed."
