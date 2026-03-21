# 📅 Team Calendar Sync Guide (Self-Hosted)
This guide explains how to set up a "Busy Block" sync using **gcalsync**. This tool monitors your personal calendars and automatically creates "Busy" (O_o) events on your Work calendar.

---

## **Step 1: Create your Google Cloud "App"**
You need to create your own "App credentials" so your server has permission to talk to your calendars.

1.  **Go to the Google Cloud Console:** [console.cloud.google.com](https://console.cloud.google.com/).
2.  **Create a New Project:** (e.g., "Team-Calendar-Sync").
3.  **Enable the API:** Go to **APIs & Services > Library**, search for **"Google Calendar API"**, and click **Enable**.
4.  **Configure the Consent Screen:**
    *   Go to **APIs & Services > OAuth consent screen**.
    *   Select **External**.
    *   **Audience (Test Users):** Add **every email address** you want to sync (Personal, Work, Startup, etc.).
5.  **Create Credentials:**
    *   Go to **APIs & Services > Credentials**.
    *   Click **Create Credentials > OAuth client ID**.
    *   **Application Type:** Select **Web Application**.
    *   **Authorized Redirect URIs:** Add exactly: `http://localhost:8181` (and your Tailscale URL if remote).
6.  **Download JSON:** Copy the `client_id` and `client_secret` into your configuration.

---

## **Included Files**
This project folder includes the following files to make setup easier:
1.  **`Dockerfile`**: Contains the **Privacy Patches** (stripped notes and anonymous titles). You MUST use this to build your image.
2.  **`docker-compose.yml`**: A template for running the tool.
3.  **`sync_calendars.sh`**: The automation script for your cron job.

---

## **Step 2: Server Deployment (Docker)**
Run these commands inside this `Cal_Syn_Proj` directory:

1.  **Create a config folder:** `mkdir config`
2.  **Create the `.gcalsync.toml` file inside `config/`:**
    ```toml
    [google]
    client_id = "YOUR_CLIENT_ID"
    client_secret = "YOUR_CLIENT_SECRET"

    [general]
    block_event_visibility = "private"
    disable_reminders = true
    authorized_ports = [8181]
    ```
3.  **Build the Patched Image:** 
    `docker compose build`

---

## **Step 3: Initial Setup (Interactive)**
You must add each of your accounts manually once. Run:
```bash
docker compose run --rm gcalsync add
```

### **Remote / Headless Server Authorization:**
If you are running this on a remote server (e.g., via SSH), the browser login will "fail" to reach `localhost:8181` on your local machine. Use this trick:
1.  Open the Google URL in your local browser and authorize.
2.  The browser will redirect to a broken page (e.g., `http://localhost:8181/?state=...`).
3.  **Copy that full URL** from your browser's address bar.
4.  Open a **second terminal** to your server and run:
    ```bash
    curl "PASTE_THE_URL_HERE"
    ```
    *(Make sure to wrap the URL in double quotes!)*

### **Prompt Guide:**
*   **Account Name:** Give it a friendly nickname (e.g., `Personal`, `Work`). 
    *   **CRITICAL:** **Do NOT use spaces** in the account name. 
    *   **PRIVACY NOTE:** The name you choose here will be the **public title** of the busy blocks on your work calendar (e.g., `O_o Personal`). Choose a name you are comfortable with your IT department seeing.
*   **Calendar ID:** 
    *   **Main Account:** Type **`primary`**.
    *   **Shared/Secondary:** Get the ID from Google Calendar Settings (e.g., `...group.calendar.google.com`).

### **Privacy Features (Patched):**
This setup uses a custom-built version of `gcalsync` with the following privacy enhancements:
1.  **Anonymous Titles:** Instead of copying your private event names (like "Doctor Appt"), it only shows `O_o [AccountName]`.
2.  **Stripped Notes:** The "Description" field from your personal events is **never** copied to the work calendar.
3.  **Private Visibility:** Coworkers will only see the word "Busy" unless you have explicitly given them permission to see full event details.

*   **Sync Mode:** 
    | Mode | Use Case | Result |
    | :--- | :--- | :--- |
    | **`read`** | **Personal/Family** | Events here block your Work time. Work meetings will NOT clutter your personal calendar. |
    | **`write`** | **Work (Destination)** | This calendar receives "O_o" blocks. Its own events are ignored and won't block other calendars. |
    | **`both`** | **Work (Peer)** | Bidirectional. Use this if you have two jobs/domains and want meetings on A to block B, and B to block A. |

---

## **Managing Your Calendars**

### **List Your Calendars:**
To see your currently configured accounts and sync modes:
```bash
docker compose run --rm gcalsync list
```

### **Renaming or Removing a Calendar**
The `gcalsync` tool is minimalist and does not have a "remove" command. To rename an account or start over:

1.  **Wipe the local database:**
    ```bash
    rm config/.gcalsync.db
    ```
2.  **Clear your target calendar (Optional):**
    If you have already synced, run `docker compose run --rm gcalsync desync` before deleting the database.
3.  **Add your accounts again** using the `add` command.

---

## **Step 4: Automation (The Sync)**
To keep your calendars updated automatically, use the provided `sync_calendars.sh` script or a cron job.

### **Manual Sync (Recommended for large calendars):**
Instead of watching a long list of events, run the sync using the included script:
```bash
./sync_calendars.sh
```

### **To view a summary of the latest sync:**
```bash
tail -n 20 sync.log
```

### **Automated Cron Job (Daily at 8:00 AM):**
1.  Add a cron entry: `crontab -e`
2.  Paste this at the bottom (adjusting the path to your folder):
    `0 8 * * * /path/to/your/folder/sync_calendars.sh`

---

## **Windows 11 / WSL Setup**
1.  Install **Docker Desktop for Windows**.
2.  Open up **PowerShell** or **WSL (Ubuntu)**.
3.  Follow the same steps above. Your files will be stored in your WSL home directory.

---

## **Troubleshooting**
*   **CGO_ENABLED Error:** Ensure you are using the Docker image built with SQLite support (via the included `Dockerfile`).
*   **Redirect URI:** Ensure `http://localhost:8181` is exactly matched in your Google Cloud Console.
