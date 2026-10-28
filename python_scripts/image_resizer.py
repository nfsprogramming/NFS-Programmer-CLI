import os
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Error: Pillow is not installed.")
    print("Please run this command in your terminal first: pip install Pillow")
    sys.exit(1)

def main():
    print("--- Bulk Image Resizer & Converter ---")
    source_dir = input("Enter the path to the folder containing images: ").strip()
    source_dir = source_dir.strip('"').strip("'")
    
    if not os.path.isdir(source_dir):
        print(f"Error: '{source_dir}' is not a valid directory.")
        return

    width_input = input("Enter target width in pixels (e.g., 800) or press Enter to keep original: ").strip()
    target_width = int(width_input) if width_input.isdigit() else None
    
    format_input = input("Enter target format (e.g., webp, jpg, png) or press Enter to keep original: ").strip().lower()
    
    source_path = Path(source_dir)
    output_path = source_path / "Output"
    output_path.mkdir(exist_ok=True)
    
    supported_formats = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
    count = 0
    
    for item in source_path.iterdir():
        if item.is_file() and item.suffix.lower() in supported_formats:
            try:
                img = Image.open(item)
                # Convert to RGB if saving to JPEG from PNG/RGBA
                if img.mode in ("RGBA", "P") and format_input in ("jpg", "jpeg"):
                    img = img.convert("RGB")
                    
                target_format = format_input if format_input else item.suffix.lower().strip('.')
                target_name = f"{item.stem}.{target_format}"
                target_file = output_path / target_name
                
                if target_width and target_width < img.width:
                    wpercent = (target_width / float(img.width))
                    hsize = int((float(img.height) * float(wpercent)))
                    img = img.resize((target_width, hsize), Image.Resampling.LANCZOS)
                
                img.save(target_file)
                print(f"Processed: {item.name} -> {target_name}")
                count += 1
            except Exception as e:
                print(f"Error processing {item.name}: {e}")

    print(f"Done! {count} images processed and saved to:\n{output_path}")

if __name__ == "__main__":
    main()
