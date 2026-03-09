# Digital Jukebox

AI-powered headless server for digital jukebox. Automates CD ripping, intelligent music tagging, and media management. Transforms physical collections into a high-quality, organized digital archive with Gemini CLI assistance.

## Features
- **Automated CD Ripping:** Insert a CD and the system handles the rest.
- **Intelligent Tagging:** Automatic music tagging and organization.
- **Media Management:** Integrated with Plex for easy listening.
- **Headless Operation:** Manage everything remotely via web interface.

## Getting Started

### Prerequisites
- Ubuntu Server installed.
- Internet connection for updates and metadata retrieval.

### Installation
1. Configure persistent networking (Netplan).
2. Update system and install essential tools (git, curl, docker).
3. Clone this repository.
4. Run the setup scripts provided in `scripts/`.

## Usage

### Adding a New CD
1. **Insert the CD** into the disc drive.
2. **Wait** (5-10 minutes).
3. **Eject:** The disc tray will pop open automatically when finished.

### Monitoring Progress
Visit `http://digitaljukebox.local:8080` in your browser.

### Listening to Music
Visit `http://digitaljukebox.local:32400/web` to access your Plex library.

## Project Structure
- `scripts/`: Automation and management scripts.
- `docker/`: Docker Compose configurations for ARM, Lidarr, and Plex.
- `projects/`: Project documentation and plans.
- `reports/`: System health and rip progress reports.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
