# Digital <YOUR_HOSTNAME> Script & Automation Audit [2026-03-23]

This document tracks the current state of automation and utility scripts. Use this to decide which scripts to keep active, move to archives, or delete.

## 1. Active Automation (Cron Jobs)

| Schedule | Command / Script | Summary |
| :--- | :--- | :--- |
| `*/30 * * * *` | `arm_watchdog.sh` | **Critical:** Monitors for stuck rips. Restarts ARM container if a log is idle > 2 hrs. |
| `*/15 * * * *` | `arm_monitor_cron.sh` | **Logging:** Monitors for job timeouts and appends heartbeats to `logs/arm_monitor.log`. |
| `0 8 * * *` | `generate_progress_report.sh` | **Stats:** Summarizes rips from last 24h, 7d, 30d and Plex library totals. |
| `0 8 * * *` | `sync_calendars.sh` | **Privacy:** Syncs personal Google Calendar to Work as "O_o Busy" blocks. |
| `0 3 * * 3` | `/usr/sbin/reboot` | **Maintenance:** Weekly reboot (Wed 3 AM) to clear hardware/SCSI locks. |
| `0 1 * * 0,1,2,4,5,6` | `borg_backup.sh` | **Backup:** Daily snapshot (1 AM, except Wed) of all critical config and code. |
| `0 2 * * 0,1,2,4,5,6` | `backup_storage.sh` | **Sync:** Mirrors `/mnt/storage` (2 AM, except Wed) to secondary backup drive. |

---

## 2. Core Scripts (Keep in `/scripts`)

These are essential for the daily operation of the <YOUR_HOSTNAME>.

- **`arm_watchdog.sh`**: Hardware freeze recovery logic.
- **`arm_monitor_cron.sh`**: Main session logging tool.
- **`diagnose_arm.sh`**: **(NEW)** Comprehensive freeze/ghost-job troubleshooter.
- **`<YOUR_HOSTNAME>_health_check.sh`**: System-wide status (CPU, RAM, Temp, Drives).
- **`inspect_hardware.sh`**: SMART health and firmware update checks.
- **`generate_progress_report.sh`**: Library growth and Plex stats.
- **`notify_plex.sh`**: Triggered by ARM `arm.yaml` to refresh Plex after a rip.
- **`borg_backup.sh`**: Core backup logic.

---

## 3. Maintenance & Utility (Manual Use)

These are used for library cleanup and one-off fixes.

- **`find_duplicates.py`**: Identifies double-ripped albums in the library.
- **`fix_underscore_mess.py`**: Fixes bad naming from old ARM versions.
- **`cleanup_unsorted.py`**: Moves "Unsorted" rips into the proper Artist/Album structure.
- **`migrate_audiobooks.sh`**: Moves non-music media to the `/media` folder.
- **`managed_move.py`**: Safely moves large batches of music with validation.
- **`set_max_speed.sh`**: Slows down noisy/vibrating drives for better rip quality.
- **`debug_optical.sh`**: Low-level SCSI/ATA troubleshooting.

---

## 4. Archived Scripts (Moved to `/scripts/archives`)

These scripts were used for initial setup or historical fixes and are no longer needed for daily operations.

- `setup-github.sh`, `setup_backup_drive.sh`, `setup_transcode_ssd.sh`
- `enable_auto_login.sh`, `enable_weekly_reboot.sh`, `set_hostname.sh`
- `prep_for_publish.sh`, `dlp-check.sh`
- `fix_plex_remote.sh`, `plex_remote_apply.sh`, `plex_remote_config.py`
- `fix_underscore_mess.py`, `fix_compilations.py` (Now integrated into `find_duplicates.py`)
- `test_fix.py`, `test_sanitize.py`

---

## 5. Decision Log

*   **2026-03-23**: Consolidated all logs to `/logs`. Created this audit file.
*   **2026-03-23**: Reconfigured automation schedule (Borg 1AM, Mirror 2AM, Reboot Wed 3AM).
*   **2026-03-23**: Executed mass cleanup of 352 redundant MP3s and archived 15 setup/legacy scripts.
