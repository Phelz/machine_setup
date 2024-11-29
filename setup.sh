#!/bin/bash

# TODO: NEEDS TESTING

# Define color variables using tput
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
YELLOW=$(tput setaf 3)

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}This script must be run as root (using sudo).${RESET}" >&2
  exit 1
fi

# Ensure the user provides a KEY_ID argument
if [[ -z $1 ]]; then
  echo -e "${RED}Usage: $0 <KEY_ID>${RESET}"
  echo -e "${RED}Example: sudo $0 my_custom_key${RESET}"
  exit 1
fi

KEY_ID=$1
USER_HOME=$(eval echo ~$SUDO_USER)  # Get the user's home directory (who invoked sudo)
GIT_EMAIL="philogeee@gmail.com"
GIT_USER="Phelz"
SSH_KEY_PATH="$USER_HOME/.ssh/$KEY_ID"

# Update and upgrade system packages
apt update -y && apt upgrade -y

# Install required packages
apt install -y git gh ansible openssh-client openssh-server

# Backup sshd_config and make it read-only
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
chmod a-w /etc/ssh/sshd_config.original

# Test SSH configuration
sshd -t -f /etc/ssh/sshd_config
if [[ $? -ne 0 ]]; then
  echo -e "${RED}SSH configuration test failed. Check /etc/ssh/sshd_config for errors.${RESET}" >&2
  exit 1
fi

# Restart SSH service
systemctl restart sshd.service
if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}SSH service restarted successfully.${RESET}"
else
  echo -e "${RED}Failed to restart SSH service. Check logs for details.${RESET}" >&2
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
  echo -e "${GREEN}SSH key $SSH_KEY_PATH already exists. Skipping key generation.${RESET}"
else
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N "" >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}SSH key $SSH_KEY_PATH created successfully.${RESET}"
  else
    echo -e "${RED}SSH key generation failed.${RESET}" >&2
    exit 1
  fi
fi

# Change ownership of the SSH key files to the correct user
chown "$SUDO_USER":"$SUDO_USER" "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"

# Create SSH configuration file to automatically add the SSH key
SSH_CONFIG_FILE="$USER_HOME/.ssh/config"

# Add configuration to the SSH config file
{
  echo "Host *"
  echo "  AddKeysToAgent yes"
  echo "  IdentityFile $SSH_KEY_PATH"
} >> "$SSH_CONFIG_FILE"

# Set proper permissions for the SSH config file
chown "$SUDO_USER":"$SUDO_USER" "$SSH_CONFIG_FILE"
chmod 600 "$SSH_CONFIG_FILE"

echo -e "${GREEN}SSH configuration updated to persist SSH key.${RESET}"

# Rest of the setup will be done by the user
echo -e "${GREEN}Pre-ansible setup complete!${RESET}"
echo -e "${YELLOW}Please add the following public key to your GitHub account:${RESET}"
cat "$SSH_KEY_PATH.pub"
echo -e "${YELLOW}Run the following commands:${RESET}"
echo -e "${YELLOW}eval \"\$(ssh-agent -s)\"${RESET}"
echo -e "${YELLOW}ssh-add $SSH_KEY_PATH${RESET}"
echo -e "${YELLOW}gh auth login --web ${RESET}(FOR WEB AUTHENTICATION)"
echo -e "${YELLOW}OR....${RESET}"
echo -e "${YELLOW}gh auth login --token ${RESET}(FOR TOKEN AUTHENTICATION)"
echo -e "${YELLOW}gh auth refresh -h github.com -s admin:public_key${RESET}"
echo -e "${YELLOW}gh ssh-key add $SSH_KEY_PATH.pub -t \"$(hostname)\"${RESET}"
echo -e "${YELLOW}ssh -T git@github.com${RESET}"
