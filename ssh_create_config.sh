#!/bin/bash

# Define the paths for user-specific and global SSH configuration
USER_SSH_CONFIG="$HOME/.ssh/config"
GLOBAL_SSH_CONFIG="/etc/ssh/sshd_config"

# 1. Create the .ssh directory if it doesn't exist
if [ ! -d "$HOME/.ssh" ]; then
  echo "Creating directory $HOME/.ssh..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

# 2. Create or overwrite the user-specific SSH config
echo "Configuring user-specific SSH settings..."

cat > "$USER_SSH_CONFIG" <<EOL
# User-specific SSH Config
Host *
  PasswordAuthentication no
  PubkeyAuthentication yes
  ChallengeResponseAuthentication no
  UsePAM no
EOL

# Set proper permissions on the user config
chmod 600 "$USER_SSH_CONFIG"
echo "User-specific SSH config written to $USER_SSH_CONFIG."

# 3. Backup the existing global SSH config if it exists
if [ -f "$GLOBAL_SSH_CONFIG" ]; then
  echo "Backing up existing global SSH config..."
  sudo cp "$GLOBAL_SSH_CONFIG" "$GLOBAL_SSH_CONFIG.bak"
  echo "Backup created at $GLOBAL_SSH_CONFIG.bak."
fi

# 4. Modify the global SSH config to match the requirements
echo "Configuring global SSH settings..."

# Add or modify the required settings
sudo tee "$GLOBAL_SSH_CONFIG" > /dev/null <<EOL
# Global SSH Config
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM no
LoginGraceTime 15m
MaxAuthTries 3
AllowUsers $USER
EOL

# Add the connection cooldown (15 seconds) between connection attempts
sudo sed -i '/#ClientAliveInterval/a ClientAliveCountMax 0\nClientAliveInterval 15' "$GLOBAL_SSH_CONFIG"

# 5. Reload SSH to apply the new global settings
echo "Reloading SSH service to apply the global configuration..."
sudo systemctl reload sshd

# Provide feedback
echo "SSH configuration has been updated for user $USER and globally. Changes applied!"
