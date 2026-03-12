# Drive Troubleshooting: Digital Jukebox (ARM)

This document specifically covers issues related to the physical optical drives (`sr0` and `sr1`) and their interaction with the Automatic Ripping Machine (ARM).

## Hardware Mapping

| **Drive ID** | **Physical Location** | **Model** | **Type** |
| :--- | :--- | :--- | :--- |
| **`/dev/sr1`** | **TOP** | HL-DT-ST DVDRAM GH41N | Desktop (Standard) |
| **`/dev/sr0`** | **BOTTOM** | hp HLDS DVDRW GUD1N | Slim (Laptop style) |

---

## Known Quirks & Stability Settings

### 1. Speed Limit (12x Stability Cap)
Due to excessive vibration on the desktop drive (`sr1`), the ripping speed is capped at **12x** instead of **MAX**. This prevents read errors on older or slightly off-balance discs.
- **Enforced via:** `~/scripts/set_max_speed.sh`
- **Config:** `abcde.conf` uses `readspeed=12` for stability.

### 2. Software Eject Limitations
- **`/dev/sr0` (Bottom):** This is a slim drive. It **CANNOT** be closed via software (`eject -t`). It must be physically pushed back into the machine.
- **`/dev/sr1` (Top):** This is a desktop drive and typically supports software closing, though mechanical obstructions may occur.

### 3. "Not CD, Blu-ray, DVD or Data" Errors
If ARM logs report this error in a loop:
- **Case A: Upside-down disc.** Verify the disc is silver-side down (common in the slim `sr0` drive).
- **Case B: Damaged media.** The drive sensor detects the disc but the laser cannot read the Table of Contents (TOC).
- **Case C: Zombie Job.** A previous failed rip has "locked" the drive in the ARM database.

---

## Troubleshooting "Stuck" Drives

### Step 1: Check for Zombie Jobs
If a drive is not responding to new discs, check if ARM thinks it's still busy.
```bash
# Check for jobs active for more than 60 minutes
sudo bash ~/scripts/diagnose_arm.sh
```

### Step 2: Clear Database Locks (Remotely)
If `diagnose_arm.sh` shows a job stuck for hours/days:
1. **Mark job as failed & ejected:**
   ```bash
   # Clear jobs that are blocking the hardware
   sqlite3 /home/arm/db/arm.db "UPDATE job SET status='fail', ejected=1 WHERE status IN ('ripping', 'transcoding', 'waiting');"
   ```
2. **Release the hardware:**
   ```bash
   # Clear the current job ID from the drives table
   sqlite3 /home/arm/db/arm.db "UPDATE system_drives SET job_id_current=NULL;"
   ```
3. **Restart ARM:**
   ```bash
   sudo docker restart arm
   ```
4. **Manual Trigger (if needed):**
   ```bash
   # Use 'sr0' or 'sr1' (no /dev/ prefix)
   sudo docker exec -u arm arm python3 /opt/arm/arm/ripper/main.py -d sr0
   ```

### Step 3: Hardware Reset
If software commands fail:
1. **Force Eject:**
   ```bash
   sudo eject /dev/sr0  # Bottom
   sudo eject /dev/sr1  # Top
   ```
2. **Cold Boot:** If the drive is completely unresponsive (missing from `lsblk`), a full server reboot is required.
   ```bash
   sudo reboot
   ```

---

## Prevention

1. **Physical Inspection:** Ensure discs are clean and centered on the spindle (especially on `sr0`).
2. **Weekly Reboot:** The scheduled Sunday reboot (06:00 UTC) clears transient SATA controller errors.
3. **Log Monitoring:** Periodically check `reports/arm_watchdog.log` for recurring failure loops.
