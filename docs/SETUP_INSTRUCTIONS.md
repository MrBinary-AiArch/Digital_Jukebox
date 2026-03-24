# Ubuntu Server: Network & Environment Setup

Run the following commands as root (or with `sudo`) to configure a persistent network connection and install essential system tools.

## 1. Configure Persistent Networking
This sets up `eno1` to automatically request an IPv4 address via DHCP.

```bash
# Create the Netplan configuration file
sudo bash -c 'cat > /etc/netplan/00-installer-config.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: true
EOF'

# Apply the new configuration
sudo netplan apply
```

## 2. System Update & Tool Installation
Updates the package repositories, upgrades existing packages, and installs the "minimized" tools that were missing (nano, curl, git, etc.).

```bash
# Update package lists and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Install essential administration tools
sudo apt install nano git htop curl wget -y
```

## 3. verification
Check your IP address to confirm the configuration is active:
```bash
ip addr show eno1
```
