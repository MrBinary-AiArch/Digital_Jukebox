# Troubleshooting Guide: Digital Jukebox (ARM)

This guide provides a step-by-step workflow for diagnosing and fixing issues when the Digital Jukebox fails to rip a disc automatically.

**Pre-requisite:** Always assume the user is remote. Connect via:
`ssh YOUR_USERNAME@TAILSCALE_IP_ADDRESS`

---

## Phase 1: Diagnosis

**Step 1: Run the Diagnostic Script**
Execute this command to get a snapshot of the system's health.
```bash
sudo bash ~/scripts/diagnose_arm.sh
```

**Step 2: Analyze the Output**
Check the section **"3. Checking for Recent Logs"**.

| **Scenario** | **Symptom in Log** | **What it Means** | **Go To** |
| :--- | :--- | :--- | :--- |
| **A** | `Job (##) status 'ripping'... started 7446min ago` | **Zombie Job.** The database thinks a job is still running from days ago. | [Fix A](#fix-a-zombie-job-reset) |
| **B** | `[ARM] Not CD, Blu-ray... Bailing out` | **Unreadable Media.** The drive cannot read the disc format (or disc is damaged). | [Fix B](#fix-b-media-rejection) |
| **C** | `Drive /dev/sr0 NOT DETECTED` | **Hardware Loss.** The OS has lost contact with the optical drive. | [Fix C](#fix-c-hardware-reset) |
| **D** | `No log files found` (and disc is in) | **Sensor Miss.** The system didn't notice the disc insertion. | [Fix D](#fix-d-sensor-trigger) |

---

## Phase 2: Solutions

### Fix A: Zombie Job Reset
*Use this when the system is stuck on an old job ID.*

1.  **Clear the internal database:**
    ```bash
    sudo docker exec arm rm -f /home/arm/db/arm.db
    ```
2.  **Restart the service:**
    ```bash
    sudo docker restart arm
    ```
3.  **Wait 60 seconds**, then run `diagnose_arm.sh` again to confirm a new job has started.

### Fix B: Media Rejection
*Use this when the log says "Bailing out" or the disc ejects immediately.*

1.  **Inspect the disc:** Ask the client to clean the disc and check for scratches.
2.  **Force Eject (if stuck):**
    ```bash
    sudo eject /dev/sr0
    ```
3.  **Note:** Some copy-protected DVDs or Data CDs cannot be ripped by this system.

### Fix C: Hardware Reset
*Use this when `/dev/sr0` is missing or the drive won't open.*

1.  **Reboot the Server:** This is the only reliable way to reset the hardware controller remotely.
    ```bash
    sudo reboot
    ```
2.  **Wait 5 minutes**, then reconnect and check diagnostics.

### Fix D: Sensor Trigger
*Use this when the disc is inside but nothing is happening (no logs).*

1.  **Force a manual check:**
    ```bash
    sudo docker exec -u arm arm python3 /opt/arm/arm/ripper/main.py -d /dev/sr0
    ```
2.  **Verify:** Check the dashboard at `http://TAILSCALE_IP_ADDRESS:8080`.

### Fix E: Power Instability (NEW)
*Use this if the server is found powered off or has rebooted unexpectedly.*

1.  **Physical Check:** Ensure the server is plugged into a "non-switched" outlet. If the outlet is controlled by a wall switch, it **MUST** be taped in the "ON" position or bypassed.
2.  **Hardware Protection:** A **UPS (Uninterruptible Power Supply)** is strongly recommended to prevent filesystem corruption and database locks during power flickers.
3.  **Check Shutdown History:**
    ```bash
    last reboot | head -n 5
    ```
    *Note: If multiple "reboot" entries appear without a corresponding "shutdown", the power was likely cut.*

---

## Phase 3: Prevention

**Weekly Auto-Reboot**
Ensure the scheduled Sunday reboot is active to clear out potential zombies.
*   **Check:** `crontab -l`
*   **Expect:** `0 6 * * 0 /sbin/shutdown -r now`

---

## Phase 4: Progress Reporting

**Generate Progress Report**
To see how many CDs have been ripped recently (24h, 7 days, 30 days), run:
```bash
sudo bash ~/scripts/generate_progress_report.sh
```
This will calculate statistics and display the full report in the terminal.
