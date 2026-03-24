# Digital Jukebox: Time Machine Setup Guide
**For Administrator Use Only**

This guide details the process for configuring the client's Mac to use the Digital Jukebox server as a Time Machine destination.

## 1. Prerequisites
*   **Server**: Ensure the Time Machine service is running.
    *   Command: `systemctl status smbd` (Should be `active (running)`)
*   **Client Mac**:
    *   Connected to the same local network (Ethernet preferred for first backup) OR connected via Tailscale.
    *   Administrator access to the Mac.
*   **Credentials**:
    *   **Username**: `tmuser`
    *   **Password**: (The password you set via `sudo smbpasswd -a tmuser`)

## 2. Standard Setup (Try this first)
1.  **Open Settings**: Go to **System Settings** -> **General** -> **Time Machine**.
2.  **Add Disk**: Click the **(+) Add Backup Disk...** button.
3.  **Locate Server**: Look for **"TimeMachine"** or the server's hostname in the list.
    *   *If it appears:* Select it and click **Set Up Disk**.
4.  **Authenticate**:
    *   **Connect As**: Registered User
    *   **Name**: `tmuser`
    *   **Password**: [Enter the password for tmuser]
5.  **Encrypt (Optional but Recommended)**: Check "Encrypt Backup" and create a secure password. Save this in your password manager; without it, the backup is useless.
6.  **Finish**: The Mac will prepare the disk and start the countdown to the first backup.

## 3. Manual Setup (If server is not listed)
If the server doesn't appear automatically (common over VPN/Tailscale), force the connection via Terminal.

1.  **Open Terminal** on the Mac.
2.  **Run Command**:
    ```bash
    sudo tmutil setdestination -p "smb://tmuser:PASSWORD@TAILSCALE_IP_ADDRESS/TimeMachine"
    ```
    *(Replace `PASSWORD` with the actual `tmuser` password. If you prefer not to type it in cleartext, omit `:PASSWORD` and it will prompt you interactively.)*

3.  **Verify**: Go back to **System Settings** -> **Time Machine**. You should now see the disk listed.

## 4. Troubleshooting

### Issue: "Backup Disk Not Available" / "Connection Failed"
*   **Check Tailscale**: ensure the Mac is connected to Tailscale and can ping the server: `ping TAILSCALE_IP_ADDRESS`
*   **Check SMB Service**: On the server, ensure Samba is running: `sudo systemctl restart smbd`
*   **Check Permissions**: On the server, verify `tmuser` owns the folder:
    ```bash
    ls -ld /mnt/storage/timemachine
    # Should look like: drwx------ 2 tmuser tmuser ...
    ```

### Issue: "The backup disk image could not be created"
*   **Permission Error**: This usually means the `tmuser` cannot write to the directory.
    *   **Fix**: On server run: `sudo chown -R tmuser:tmuser /mnt/storage/timemachine && sudo chmod 700 /mnt/storage/timemachine`

### Issue: Backup is extremely slow
*   **Connection**: If backing up over Wi-Fi or Tailscale (VPN), this is normal.
*   **First Backup**: The first backup copies *everything*. It is highly recommended to connect via **Ethernet** for the initial backup.
*   **Throttle**: macOS throttles low-priority backups. To force full speed (uses more CPU), run this on the Mac:
    ```bash
    sudo sysctl debug.lowpri_throttle_enabled=0
    ```
    *(Restarting the Mac resets this to default).*

### Issue: "Sparsebundle is already in use"
*   **Stuck Session**: If a backup was interrupted/crashed, the disk image might be locked.
*   **Fix**: Restart the Mac. If that fails, restart the Samba service on the server (`sudo systemctl restart smbd`).

## 5. Maintenance (Administrator)
To check the size of the backups on the server:
```bash
du -sh /mnt/storage/timemachine
```
The server is configured to limit Time Machine to **1TB**. If this limit is reached, Time Machine will automatically delete the oldest backups to make room for new ones.
