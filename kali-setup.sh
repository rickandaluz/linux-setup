#!/bin/bash

print_status() {
    echo "================================================"
    echo ">>> $1"
    echo "================================================"
}

# Check if script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Update and upgrade system packages
print_status "Updating package repositories and upgrading all packages"
apt update && apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean

# Install and update hardware drivers
print_status "Installing hardware drivers and updates"
apt install -y linux-firmware
apt install -y firmware-linux firmware-linux-nonfree

# For Nvidia drivers (if needed)
print_status "Installing Nvidia drivers (if applicable)"
apt install -y nvidia-driver

# Install NordVPN
print_status "Installing NordVPN"
sh -c 'echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list'
wget -qO - https://repo.nordvpn.com/gpg/nordvpn_public.asc | apt-key add -
apt update
apt install -y nordvpn

print_status "NordVPN installed. Run 'nordvpn login' to connect to your account"

# Install Docker
print_status "Installing Docker"
# Remove old versions if any
apt remove -y docker docker-engine docker.io containerd runc

# Install prerequisites
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker repository for Kali (using Debian repository)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
USER=$(logname)
usermod -aG docker $USER
print_status "Docker installed. You may need to log out and log back in for group changes to take effect"

# Install additional useful tools
# Note: Many tools are already included in Kali Linux by default
print_status "Installing additional useful tools"
apt install -y htop neofetch tlp tlp-rdw timeshift

# Enable TLP for battery optimization (for laptops)
systemctl enable tlp
systemctl start tlp

# Optional: Install common pentesting tools if not already installed
print_status "Ensuring common security tools are installed"
apt install -y metasploit-framework burpsuite wireshark nmap dirb

print_status "Setup complete!"
print_status "System upgraded and all requested software installed."
print_status "Please reboot your system to ensure all changes take effect."

# Display system info
neofetch