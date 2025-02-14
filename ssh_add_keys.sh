#!/bin/bash

# === Load Environment Variables ===
if [ -f ".env" ]; then
    set -o allexport
    source .env
    set +o allexport
fi

# === Extract All SSH_KEYS_N Entries ===
SSH_KEYS=()

# Iterate over all environment variables that start with SSH_KEYS_
for key in $(env | grep '^SSH_KEYS_' | cut -d '=' -f 1); do
    SSH_KEYS+=("${!key}")  # Dereference the variable name to get its value
done

# === Ensure .ssh Directory and authorized_keys Exist ===
SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# 1. Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating $SSH_DIR directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# 2. Create authorized_keys if it doesn't exist
if [ ! -f "$AUTHORIZED_KEYS" ]; then
    echo "Creating $AUTHORIZED_KEYS file..."
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
fi

# 3. Add SSH Keys if they don't already exist
echo "Adding SSH keys..."

for KEY in "${SSH_KEYS[@]}"; do
    if ! grep -Fxq "$KEY" "$AUTHORIZED_KEYS"; then
        echo "$KEY" >> "$AUTHORIZED_KEYS"
        echo "Added key: $KEY"
    else
        echo "Key already exists: $KEY"
    fi
done

# 4. Set correct permissions
chmod 600 "$AUTHORIZED_KEYS"
chmod 700 "$SSH_DIR"

echo "All keys have been added and permissions are set."
