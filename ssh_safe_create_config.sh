#!/bin/bash

USER_SSH_CONFIG="$HOME/.ssh/config"
GLOBAL_SSH_CONFIG="/etc/ssh/sshd_config"

# Function to safely set SSH config options, handling commented lines
set_ssh_option() {
  local option="$1"
  local value="$2"
  local config_file="$3"

  if grep -Eq "^\s*#?\s*${option}\s+" "$config_file"; then
    sudo sed -i "s|^\s*#\?\s*${option}\s\+.*|${option} ${value}|g" "$config_file"
  else
    echo "${option} ${value}" | sudo tee -a "$config_file" > /dev/null
  fi
}

# 1. Install OpenSSH Server if missing
if ! command -v sshd >/dev/null 2>&1; then
  echo "Installing OpenSSH Server..."
  sudo apt-get update
  sudo apt-get install -y openssh-server
fi

# 2. Create .ssh directory
if [ ! -d "$HOME/.ssh" ]; then
  echo "Creating $HOME/.ssh..."
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

# 3. Configure user-specific SSH settings
echo "Configuring user SSH settings..."

cat > "$USER_SSH_CONFIG" <<EOL
Host *
  PasswordAuthentication no
  PubkeyAuthentication yes
  ChallengeResponseAuthentication no
  UsePAM no
EOL

chmod 600 "$USER_SSH_CONFIG"
echo "User SSH config updated at $USER_SSH_CONFIG."

# 4. Backup global SSH config
if [ -f "$GLOBAL_SSH_CONFIG" ]; then
  echo "Backing up global SSH config..."
  sudo cp "$GLOBAL_SSH_CONFIG" "$GLOBAL_SSH_CONFIG.bak"
fi

# 5. Apply global SSH settings safely
echo "Applying global SSH settings..."

set_ssh_option "PermitRootLogin" "no" "$GLOBAL_SSH_CONFIG"
set_ssh_option "PasswordAuthentication" "no" "$GLOBAL_SSH_CONFIG"
set_ssh_option "PubkeyAuthentication" "yes" "$GLOBAL_SSH_CONFIG"
set_ssh_option "ChallengeResponseAuthentication" "no" "$GLOBAL_SSH_CONFIG"
set_ssh_option "UsePAM" "no" "$GLOBAL_SSH_CONFIG"
set_ssh_option "LoginGraceTime" "15m" "$GLOBAL_SSH_CONFIG"
set_ssh_option "MaxAuthTries" "3" "$GLOBAL_SSH_CONFIG"
set_ssh_option "AllowUsers" "$USER" "$GLOBAL_SSH_CONFIG"
set_ssh_option "ClientAliveInterval" "15" "$GLOBAL_SSH_CONFIG"
set_ssh_option "ClientAliveCountMax" "0" "$GLOBAL_SSH_CONFIG"

# 6. Reload SSH service
echo "Reloading SSH service..."
sudo systemctl reload sshd

echo "SSH configuration has been updated and applied."
