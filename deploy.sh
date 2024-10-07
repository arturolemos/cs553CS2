#!/bin/bash

PORT=22015
REMOTE_USER="student-admin"
REMOTE_HOST="paffenroth-23.dyn.wpi.edu"

PUBLIC_KEY=${1:-"jose_key"}
REPO="https://github.com/arturolemos/cs553CS2.git"
PYTHON_VERSION="3.9"

echo "Using public key: $PUBLIC_KEY"
echo "Connecting to remote server..."
ssh -i "$PUBLIC_KEY" -p "$PORT" "$REMOTE_USER@$REMOTE_HOST"

echo "Cloning repository $REPO..."
git clone "$REPO"

REPO_NAME=$(basename "$REPO" .git)

echo "Changing directory to $REPO_NAME..."
cd "$REPO_NAME"

echo "Downloading Miniconda installer..."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

echo "Installing Miniconda..."
bash Miniconda3-latest-Linux-x86_64.sh -b

echo "Activating Miniconda..."
source ~/miniconda3/bin/activate

echo "Creating Conda environment with Python $PYTHON_VERSION..."
conda create --name myenv "python=$PYTHON_VERSION" -y

echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Setup complete."
