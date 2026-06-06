import shutil
from pathlib import Path

FILE_CATEGORIES = {
    "Documents": [".pdf", ".docx", ".doc", ".txt", ".xlsx", ".csv", ".pptx"],
    "Images": [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".webp"],
    "Videos": [".mp4", ".mov", ".mkv", ".avi", ".wmv", ".flv"],
    "Audio": [".mp3", ".wav", ".aac", ".flac", ".ogg"],
    "Archives": [".zip", ".rar", ".tar", ".gz", ".7z"],
    "Executables": [".exe", ".msi", ".bat", ".cmd"],
}

def get_unique_path(destination_dir: Path, filename: str) -> Path:
    target_path = destination_dir / filename
    if not target_path.exists():
        return target_path
    
    name = target_path.stem
    suffix = target_path.suffix
    
    counter = 1
    while True:
        new_name = f"{name} ({counter}){suffix}"
        new_path = destination_dir / new_name
        if not new_path.exists():
            return new_path
        counter += 1

def main():
    print("--- Universal File Organizer ---")
    default_dir = Path.home() / "Downloads"
    target_dir_input = input(f"Enter the folder to organize (Press Enter for '{default_dir}'): ").strip()
    
    if target_dir_input:
        target_dir = Path(target_dir_input.strip('"').strip("'"))
    else:
        target_dir = default_dir
        
    if not target_dir.exists():
        print(f"Error: {target_dir} does not exist.")
        return

    print(f"Organizing {target_dir}...")
    count = 0
    for item in target_dir.iterdir():
        if item.is_dir():
            continue

        file_extension = item.suffix.lower()
        
        target_folder_name = None
        for category, extensions in FILE_CATEGORIES.items():
            if file_extension in extensions:
                target_folder_name = category
                break
        
        if target_folder_name:
            cat_dir = target_dir / target_folder_name
            cat_dir.mkdir(parents=True, exist_ok=True)
            
            new_path = get_unique_path(cat_dir, item.name)
            shutil.move(str(item), str(new_path))
            print(f"Moved: '{item.name}' -> '{target_folder_name}/{new_path.name}'")
            count += 1
            
    print(f"Done! Organized {count} files.")

if __name__ == "__main__":
    main()
