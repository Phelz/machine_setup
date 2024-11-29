#!/bin/bash

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (using sudo)." >&2
  exit 1
fi

# Ensure the user provides a KEY_ID argument
if [[ -z $1 ]]; then
  echo "Usage: $0 <KEY_ID>"
  echo "Example: sudo $0 my_custom_key"
  exit 1
fi

KEY_ID=$1
USER_HOME=$(eval echo ~$SUDO_USER)  # Get the user's home directory (who invoked sudo)
EMAIL="philogeee@gmail.com"
SSH_KEY_PATH="$USER_HOME/.ssh/$KEY_ID"

# Update and upgrade system packages
apt update -y && apt upgrade -y

# Install required packages
apt install -y git gh ansible openssh-client openssh-server wget curl

# Check if Google Chrome is installed
if ! command -v google-chrome-stable &> /dev/null; then
  echo "Google Chrome not found. Installing..."
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -i google-chrome-stable_current_amd64.deb
  apt --fix-broken install -y
else
  echo "Google Chrome is already installed."
fi

# Set Google Chrome as the default browser for everything
#update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
#update-alternatives --set gnome-www-browser /usr/bin/google-chrome-stable

# Set Google Chrome as the browser for GitHub CLI by setting the BROWSER variable
export BROWSER=google-chrome-stable

# Backup sshd_config and make it read-only
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
chmod a-w /etc/ssh/sshd_config.original

# Test SSH configuration
sshd -t -f /etc/ssh/sshd_config
if [[ $? -ne 0 ]]; then
  echo "SSH configuration test failed. Check /etc/ssh/sshd_config for errors." >&2
  exit 1
fi

# Restart SSH service
systemctl restart sshd.service
if [[ $? -eq 0 ]]; then
  echo "SSH service restarted successfully."
else
  echo "Failed to restart SSH service. Check logs for details." >&2
  exit 1
fi

# Create .ssh directory if it doesn't exist
if [[ ! -d "$USER_HOME/.ssh" ]]; then
  mkdir -p "$USER_HOME/.ssh"
  chown "$SUDO_USER":"$SUDO_USER" "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
fi

# SSH Key generation and setup
if [[ -f "$SSH_KEY_PATH" ]]; then
  echo "SSH key $SSH_KEY_PATH already exists. Skipping key generation."
else
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH" -N "" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "SSH key $SSH_KEY_PATH created successfully."
  else
    echo "SSH key generation failed." >&2
    exit 1
  fi
fi

# Change ownership of the SSH key files to the correct user
chown "$SUDO_USER":"$SUDO_USER" "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"

# Start ssh-agent and add the SSH key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

# Authenticate GitHub CLI (run as the non-root user)
echo "Authenticating GitHub CLI as user $SUDO_USER..."

# Run gh auth login for web authentication only
sudo -u "$SUDO_USER" gh auth login

echo "Initial setup complete! Your SSH public key is:"
cat "$SSH_KEY_PATH.pub"
