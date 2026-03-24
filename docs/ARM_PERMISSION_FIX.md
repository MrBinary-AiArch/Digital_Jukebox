# Troubleshooting ARM Docker Permission Errors

The error `[ERROR]: ARM does not have permissions to /home/arm using 1000:1000` indicates that the Docker container cannot write to the mapped volumes because the host directories are owned by `root` (UID 0), while the container runs as user `1000` (YOUR_USERNAME).

## The Fix

We need to recursively change the ownership of all mapped directories to your user account.

### 1. Stop the Container
First, ensure the container is not trying to access the files while we modify them.
```bash
cd ~/docker/arm
docker compose down
```

### 2. Correct Directory Ownership
Run these commands to transfer ownership of the configuration and storage directories to your user (UID 1000).

```bash
# Fix the local Docker config folder
sudo chown -R $USER:$USER ~/docker/arm

# Fix the main storage destination
sudo chown -R $USER:$USER /mnt/storage/music
```

### 3. Verify Permissions
Check that the directories now show your username (`YOUR_USERNAME`) instead of `root`.
```bash
ls -ld ~/docker/arm
ls -ld /mnt/storage/music
```

### 4. Restart the Container
Bring the service back up.
```bash
docker compose up -d
```

### 5. Check Logs
Verify the error is gone.
```bash
docker logs -f arm
```
You should now see the startup script proceed past the permission check.
