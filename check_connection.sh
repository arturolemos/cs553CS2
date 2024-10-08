#!/bin/bash

REMOTE_USER="student-admin"
REMOTE_HOST="paffenroth-23.dyn.wpi.edu"
PRIVATE_KEY="class_key"  
PORT=22015 

SCRIPTS_TO_RUN=("./secure_keys.sh" "./deploy.sh")

ssh -i "$PRIVATE_KEY" -p "$PORT" -o BatchMode=yes -o ConnectTimeout=10 "$REMOTE_USER@$REMOTE_HOST" "exit"

if [ $? -eq 0 ]; then
    echo "Server is reachable via SSH. Running the scripts..."
    for script in "${SCRIPTS_TO_RUN[@]}"; do
        if [ -x "$script" ]; then
            bash "$script"
            echo "Executed $script"
        else
            echo "Script $script is not executable or not found"
        fi
    done
else
    echo "Cannot SSH to the server. Ignoring..."
fi
