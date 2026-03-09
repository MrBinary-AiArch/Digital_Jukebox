from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import os
import musicbrainzngs
import discogs_client
from dotenv import load_dotenv
import glob
from mutagen.flac import FLAC
import shutil

# Load environment variables from the .env file
load_dotenv("/etc/arm/config/.env")

app = FastAPI()

# --- Configuration ---
MUSIC_LIBRARY_PATH = "/mnt/storage/music/library"
UNKNOWN_ARTIST_PATH = os.path.join(MUSIC_LIBRARY_PATH, "Unknown_Artist")

# Setup MusicBrainz
MB_EMAIL = os.getenv("MUSICBRAINZ_CONTACT_EMAIL", "default@example.com")
musicbrainzngs.set_useragent("JukeboxTagger", "1.0", MB_EMAIL)

# Setup Discogs
DISCOGS_TOKEN = os.getenv("DISCOGS_PERSONAL_ACCESS_TOKEN")
d_client = None
if DISCOGS_TOKEN:
    d_client = discogs_client.Client('JukeboxTagger/1.0', user_token=DISCOGS_TOKEN)

class TrackInfo(BaseModel):
    number: str
    title: str
    duration: float = 0.0

class IdentifiedAlbum(BaseModel):
    folder_name: str
    artist: str
    album: str
    tracks: list[TrackInfo]
    source: str
    mbid: str = ""
    discogs_id: str = ""

class TagRequest(BaseModel):
    artist: str
    album: str
    tracks: list[TrackInfo]

# --- Helper Functions ---

def get_local_track_info(folder_path):
    tracks = []
    files = sorted(glob.glob(os.path.join(folder_path, "*.flac")))
    for i, file in enumerate(files):
        try:
            audio = FLAC(file)
            tracks.append({
                "number": str(i + 1),
                "title": f"Track {i + 1}",
                "duration": audio.info.length
            })
        except Exception:
            tracks.append({"number": str(i + 1), "title": f"Track {i + 1}", "duration": 0.0})
    return tracks

def sanitize_filename(name):
    return "".join([c for c in name if c.isalpha() or c.isdigit() or c in (' ', '.', '_', '-')]).strip()

# --- API Endpoints ---

@app.get("/")
async def read_root():
    return {"message": "Music Tagger API is running"}

@app.get("/unidentified-albums")
async def get_unidentified_albums():
    if not os.path.exists(UNKNOWN_ARTIST_PATH):
        return []
    
    albums = []
    for entry in os.listdir(UNKNOWN_ARTIST_PATH):
        full_path = os.path.join(UNKNOWN_ARTIST_PATH, entry)
        if os.path.isdir(full_path):
            track_count = len(glob.glob(os.path.join(full_path, "*.flac")))
            albums.append({
                "folder_name": entry,
                "track_count": track_count,
                "path": full_path
            })
    return albums

@app.post("/identify-album/{folder_name}")
async def identify_album(folder_name: str, q: str = Query(None), barcode: str = Query(None)):
    folder_path = os.path.join(UNKNOWN_ARTIST_PATH, folder_name)
    if not os.path.exists(folder_path):
        raise HTTPException(status_code=404, detail="Folder not found")

    local_tracks = get_local_track_info(folder_path)

    # 1. Search by BARCODE (Highest Accuracy)
    if barcode:
        # Search MusicBrainz by barcode
        try:
            result = musicbrainzngs.search_releases(barcode=barcode)
            if result['release-list']:
                best_match = result['release-list'][0]
                rel = musicbrainzngs.get_release_by_id(best_match['id'], includes=["recordings"])
                mb_tracks = []
                for medium in rel['release']['medium-list']:
                    for track in medium['track-list']:
                        mb_tracks.append({
                            "number": track['number'],
                            "title": track['recording']['title'],
                            "duration": int(track['length'])/1000 if 'length' in track else 0
                        })
                return {
                    "folder_name": folder_name,
                    "artist": best_match['artist-credit-phrase'],
                    "album": best_match['title'],
                    "tracks": mb_tracks,
                    "source": "MusicBrainz (Barcode)",
                    "mbid": best_match['id']
                }
        except Exception as e:
            print(f"MB Barcode error: {e}")

        # Search Discogs by barcode
        if d_client:
            try:
                results = d_client.search(barcode=barcode, type='release')
                if results.count > 0:
                    best_match = results[0]
                    return {
                        "folder_name": folder_name,
                        "artist": best_match.artists[0].name,
                        "album": best_match.title,
                        "tracks": [{"number": str(i+1), "title": t.title} for i, t in enumerate(best_match.tracklist)],
                        "source": "Discogs (Barcode)",
                        "discogs_id": str(best_match.id)
                    }
            except Exception as e:
                print(f"Discogs Barcode error: {e}")

    # 2. Search by TEXT QUERY (Standard Search)
    if q:
        # Search MusicBrainz
        try:
            result = musicbrainzngs.search_releases(query=q, limit=5)
            if result['release-list']:
                best_match = result['release-list'][0]
                rel = musicbrainzngs.get_release_by_id(best_match['id'], includes=["recordings"])
                mb_tracks = []
                for medium in rel['release']['medium-list']:
                    for track in medium['track-list']:
                        mb_tracks.append({
                            "number": track['number'],
                            "title": track['recording']['title'],
                            "duration": int(track['length'])/1000 if 'length' in track else 0
                        })
                
                return {
                    "folder_name": folder_name,
                    "artist": best_match['artist-credit-phrase'],
                    "album": best_match['title'],
                    "tracks": mb_tracks,
                    "source": "MusicBrainz",
                    "mbid": best_match['id']
                }
        except Exception as e:
            print(f"MusicBrainz error: {e}")

        # Fallback to Discogs
        if d_client:
            try:
                results = d_client.search(q, type='release')
                if results.count > 0:
                    best_match = results[0]
                    return {
                        "folder_name": folder_name,
                        "artist": best_match.artists[0].name,
                        "album": best_match.title,
                        "tracks": [{"number": str(i+1), "title": t.title} for i, t in enumerate(best_match.tracklist)],
                        "source": "Discogs",
                        "discogs_id": str(best_match.id)
                    }
            except Exception as e:
                print(f"Discogs error: {e}")

    return {
        "folder_name": folder_name,
        "artist": "Unknown Artist",
        "album": "Unknown Album",
        "tracks": local_tracks,
        "source": "Local Files"
    }

@app.post("/apply-tags/{folder_name}")
async def apply_tags(folder_name: str, request: TagRequest):
    src_path = os.path.join(UNKNOWN_ARTIST_PATH, folder_name)
    if not os.path.exists(src_path):
        raise HTTPException(status_code=404, detail="Source folder not found")

    dest_artist = sanitize_filename(request.artist)
    dest_album = sanitize_filename(request.album)
    dest_path = os.path.join(MUSIC_LIBRARY_PATH, dest_artist, dest_album)

    if os.path.exists(dest_path):
        raise HTTPException(status_code=400, detail="Destination album already exists")

    os.makedirs(dest_path, exist_ok=True)

    files = sorted(glob.glob(os.path.join(src_path, "*.flac")))
    
    # Process each track
    for i, file_path in enumerate(files):
        if i < len(request.tracks):
            track_info = request.tracks[i]
            # Tag the file
            try:
                audio = FLAC(file_path)
                audio["artist"] = request.artist
                audio["album"] = request.album
                audio["title"] = track_info.title
                audio["tracknumber"] = track_info.number
                audio.save()
            except Exception as e:
                print(f"Error tagging {file_path}: {e}")

            # Move and rename
            new_filename = f"{int(track_info.number):02d} - {sanitize_filename(track_info.title)}.flac"
            shutil.move(file_path, os.path.join(dest_path, new_filename))

    # Remove source folder if empty
    if not os.listdir(src_path):
        os.rmdir(src_path)

    return {"message": f"Successfully tagged and moved to {dest_artist}/{dest_album}"}
