# ARM Stability Troubleshooting

## Problem Description
The Digital <YOUR_HOSTNAME> frequently encounters hardware-level I/O errors and "Illegal Request" sense keys on the optical drives (`/dev/sr0` and `/dev/sr1`). These errors sometimes lead to the drives becoming unresponsive or ARM getting stuck, necessitating a full system reboot to clear the hardware state.

## Suspected Causes
1. **Host-Side I/O Locks**: The Ubuntu kernel might be locking the drives due to perceived I/O errors.
2. **Docker Privilege Issues**: While the container is `privileged`, there might be subtle interactions with the host's `udev` or `sg` (SCSI generic) drivers.
3. **Power Management**: The drives might be entering a low-power state and failing to wake correctly.
4. **Media Quality**: "Illegal Request" sense keys often indicate the drive is struggling to read a specific part of the disc.

## Current Mitigations (Workarounds)
- **30-Minute Watchdog**: A cron job (`scripts/arm_watchdog.sh`) checks for active jobs and restarts the ARM container if no progress is made.
- **Weekly Reboot**: A scheduled weekly system reboot (`/etc/cron.d/weekly_reboot`) to proactively clear any persistent I/O locks.
- **Manual Eject**: Using the `eject` command to clear the drive state (seems to work sometimes when ARM is stuck).

## Investigation Log
### 2026-03-05
- **Observation**: System rebooted to clear errors. `sr0` resumed ripping, but `sr1` was ejected after several "Bailing out" logs.
- **Root Cause Identified**: The `udisks2` service and kernel auto-mounting are attempting to read audio CDs as data disks (ISO/UDF) during insertion or boot. This creates a race condition with ARM's `cdparanoia`, leading to "Illegal Request: Illegal mode for this track" errors and hardware-level SCSI bus lockups.
- **Permanent Fix Plan**: Disable OS-level interference by telling `udev` to ignore the drives and disabling kernel `autoclose`.
- **Action**: Task added to `TODO.md`. User to run the following commands tomorrow when not actively ripping:

#### Required Commands (Run Tomorrow):
```bash
# 1. Tell udisks2 to ignore the optical drives
echo 'KERNEL=="sr[0-1]", ENV{UDISKS_IGNORE}="1"' | sudo tee /etc/udev/rules.d/60-ignore-sr.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# 2. Disable kernel-level autoclose
echo "dev.cdrom.autoclose=0" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### 2026-03-06
- **Status Update**: Permanent stability fixes (udev rules and sysctl) successfully applied by user while on-site.
- **Persistent Observation**: Even after udev rules were applied, both `sr0` and `sr1` continued to encounter "Input/output error" and "Illegal Mode" when attempting to set drive speed or start new rips.
- **Conclusion**: The kernel and hardware SCSI buffers still held the previous error state. A "warm" reload of udev rules was insufficient to clear existing hardware-level locks.
- **Action**: Full system reboot initiated to initialize the hardware from a clean state with the new "OS ignore" parameters active from boot.

## Reference Commands
- `dmesg | grep -iE "sr0|sr1|cdrom|ata"` (Check kernel logs for drive errors)
- `udevadm info -a -n /dev/sr0` (Check drive properties)
- `hdparm -i /dev/sr0` (Check drive identification and settings)
- `lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINTS,MODE,OWNER,GROUP` (Detailed block device list)
