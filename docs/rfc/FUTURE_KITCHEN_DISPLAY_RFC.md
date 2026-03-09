# RFC: Kitchen Display for Digital Jukebox

**Status:** Proposed / Draft
**Proposed Date:** 2026-03-09

## 1. Objective
Design and implement a dedicated, low-cost, and visually appealing interactive display for the kitchen. This display will allow users to:
- See what's currently playing on the Digital Jukebox.
- Browse the music library.
- Initiate basic playback controls (Play/Pause/Skip).
- Monitor system status (ripping progress, storage capacity).

## 2. Requirements
### Hardware
- **Display:** 7-10 inch touchscreen (Raspberry Pi Touch Display or similar).
- **Controller:** Raspberry Pi 4 or 5 (Zero 2 W might suffice for a web-based UI).
- **Enclosure:** Wall-mounted or stand-alone kitchen-friendly case.
- **Power:** USB-C wall adapter with discreet cabling.

### Software
- **OS:** Raspberry Pi OS Lite (Kiosk Mode).
- **Interface:** Custom web dashboard or a simplified Plex web client.
- **Integration:** 
    - **Plex API:** For library browsing and playback status.
    - **Jukebox API/Webhooks:** For ripping notifications and health monitoring.

## 3. Core Features
1. **Now Playing Dashboard:** Large album art, track info, and playback controls.
2. **Library Explorer:** Simple, touch-optimized grid of albums and artists.
3. **Rip Status Overlay:** Real-time progress bar when a new CD is being ripped.
4. **Kitchen Timer:** Optional, non-music utility since the display is in the kitchen.

## 4. Design Aesthetics
- Follow Material Design principles.
- High-contrast UI for visibility from a distance.
- Minimalist and "app-like" experience.

## 5. Potential Challenges
- **Network Stability:** Ensuring consistent connectivity from the server to the kitchen.
- **Plex Authentication:** Securely managing credentials for a shared kiosk.
- **Touch Responsiveness:** Optimizing the web UI for low-powered hardware.

---
**Next Step:** Prototyping the web UI and selecting hardware components.
