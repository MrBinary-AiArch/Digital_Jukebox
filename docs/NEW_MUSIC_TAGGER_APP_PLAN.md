# Plan: Simplified Music Tagger Web App

## 1. Objective
To create a simple, modern web application that allows for easy identification and organization of music ripped by the Digital Jukebox that ARM could not identify (i.e., the contents of the `Unknown_Artist` folder). This will replace the need to use the current VNC-based Picard interface for routine tagging.

## 2. Core Features

### 2.1. Unidentified Album Inbox
- The main page will display a list of unidentified albums, with each entry representing a folder inside `/mnt/storage/music/library/Unknown_Artist/`.
- Each album entry will show the number of tracks and allow the user to initiate an identification process.

### 2.2. Automatic Identification
- An "Identify" button for each album will trigger an automatic lookup.
- **Data Sources:**
    - **Primary:** [MusicBrainz](https://musicbrainz.org/) (via its API) will be the first and most reliable source.
    - **Secondary:** [Discogs](https://www.discogs.com/) (via its API) will be used as a fallback if no confident match is found on MusicBrainz.
    - **(Future) Web Scrapers:** We can explore adding scrapers for specific websites (like the 9starmedia.com example), but this is less reliable and would be a lower-priority feature.
- The top match will be displayed clearly to the user.
- An "Apply Match" button will automatically tag, rename, and move the files to the main library.

### 2.3. Manual Identification Workflow
- **This addresses your question about what happens if a match isn't found.**
- If no match is found, or if the user rejects the automatic match, a "Manual Edit" button will become available.
- This will open a simple form with the following fields:
    - Album Artist
    - Album Title
    - A list of input fields for each track title.
- A "Save Manual Tags" button will then use the user-provided information to tag, rename, and move the files.

## 3. Technology Stack
- **Backend:** Python (using the FastAPI framework) to handle file operations and API lookups.
- **Frontend:** React (with TypeScript) for a modern, responsive user interface.
- **Styling:** A clean component library like Material-UI to ensure the application is easy to use and visually appealing.

## 4. Next Steps
- Please review this plan. We can continue to add details or make changes as needed.
- Once you approve the plan, I will begin scaffolding the project structure and developing the application.
