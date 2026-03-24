# SSH Key-Based Authentication Setup

This guide outlines the steps to enable passwordless login from a Windows laptop to the Digital Jukebox (HP EliteDesk).

## Prerequisites
- **Client**: Windows Laptop (PowerShell)
- **Server**: LOCAL_IP_ADDRESS (YOUR_USERNAME)
- **Password**: `AugustaDr1029`

## Step 1: Generate Key Pair (Laptop)
If you haven't generated a key yet, run this on your laptop:
```powershell
ssh-keygen -t ed25519 -C "laptop-to-jukebox"
```
*Press Enter to accept defaults.*

## Step 2: Fix Server-Side Permissions
Ensure the `YOUR_USERNAME` user owns the configuration directory:
```powershell
ssh -t YOUR_USERNAME@LOCAL_IP_ADDRESS "sudo chown -R YOUR_USERNAME:YOUR_USERNAME ~/.ssh && sudo chmod 700 ~/.ssh"
```

## Step 3: Transfer Public Key
Copy the public key from the laptop to the server's authorized list:
```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh YOUR_USERNAME@LOCAL_IP_ADDRESS "cat >> ~/.ssh/authorized_keys"
```

## Step 4: Finalize Permissions
Secure the authorized_keys file:
```powershell
ssh YOUR_USERNAME@LOCAL_IP_ADDRESS "chmod 600 ~/.ssh/authorized_keys"
```

## Verification
Test the connection. It should log in immediately without a password:
```powershell
ssh YOUR_USERNAME@LOCAL_IP_ADDRESS
```
