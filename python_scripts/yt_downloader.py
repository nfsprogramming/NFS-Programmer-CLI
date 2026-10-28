import sys
import os
from pathlib import Path

try:
    import yt_dlp
except ImportError:
    print("Error: yt-dlp is not installed.")
    print("Please run this command in your terminal first: pip install yt-dlp")
    sys.exit(1)

def main():
    print("--- YouTube Video & Audio Downloader ---")
    url = input("Enter YouTube URL: ").strip()
    if not url:
        return
        
    choice = input("Download (1) Video or (2) Audio? [1/2]: ").strip()
    
    downloads_dir = str(Path.home() / "Downloads")
    script_dir = str(Path(__file__).parent.absolute())
    
    ydl_opts = {
        'outtmpl': os.path.join(downloads_dir, '%(title)s.%(ext)s'),
        'ffmpeg_location': script_dir,
    }
    
    if choice == '2':
        print("Downloading Highest Quality Audio...")
        ydl_opts.update({
            'format': 'bestaudio/best',
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '192',
            }],
        })
    else:
        print("Downloading Highest Quality Video...")
        ydl_opts.update({
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
            'merge_output_format': 'mp4'
        })
        
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])
        print(f"\nSuccess! Download saved to: {downloads_dir}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
