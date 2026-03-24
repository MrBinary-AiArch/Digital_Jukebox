# Digital Jukebox Project TODO

## Active Tasks
- [x] **ARM Stability**: **COMPLETED (Rebooted & Verified)** - The `udev` rule (`UDISKS_IGNORE=1`) and `sysctl` fix (`dev.cdrom.autoclose=0`) are now active.
- [x] **Audiobook Migration**: **COMPLETED (Cleaned Up)** - Migrated ~9GB to TrueNAS and removed local copies from `/mnt/storage`.
- [ ] **Resume Ripping**: **IN PROGRESS** - Testing if ARM automatically triggers on disc insertion or manual trigger after the reboot.
- [ ] **Duplicate Cleanup**: **PENDING** - Follow the plan in `DUPLICATE_CLEANUP_PLAN.md` once ARM is stable.

## Maintenance & Monitoring
- [ ] **Lidarr Audit**: Monitor Lidarr's background scan of the 59,000 files and verify identification progress.
- [ ] **Music Tagger Review**: Begin manual review of `/mnt/storage/music/ingest/loose_batch_01/` via the web app.
- [ ] **Verify Backups**: Check `reports/backup_log.txt` to ensure the daily 03:00 CST backup is succeeding.

## Completed (Recent)
- [x] **Migrate Audiobooks**: **SUCCESS** - 9GB transferred to TrueNAS using `--inplace` and `--no-perms`.
- [x] **Stability Rules**: Created `60-ignore-sr.rules` to prevent `udisks2` from touching the drives.
- [x] **Watchdog Update**: Updated `/home/YOUR_USERNAME/scripts/arm_watchdog.sh` to monitor both `sr0` and `sr1`.
- [x] **Log Updated**: Documented findings and identified root causes in `projects/Digital_Jukebox/ARM_STABILITY_TROUBLESHOOTING.md`.
