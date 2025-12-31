from PIL import Image
import sys
import os

def process_image(file_path):
    try:
        print(f"Processing: {file_path}")
        img = Image.open(file_path).convert("RGBA")
        datas = img.getdata()

        new_data = []
        for item in datas:
            # Green detection: High Green, Low Red/Blue
            # Target: #00FF00 (0, 255, 0)
            # Threshold matches bright green
            if item[1] > 200 and item[0] < 100 and item[2] < 100:
                new_data.append((0, 0, 0, 0))  # Make transparent
            else:
                new_data.append(item)

        img.putdata(new_data)

        # Crop transparent areas (Trim)
        bbox = img.getbbox()
        if bbox:
            img = img.crop(bbox)
            print(f"  Cropped to: {bbox}")
        else:
            print("  Warning: Image resulted in empty bounding box (all transparent?).")

        img.save(file_path, "PNG")
        print("  Done.")
    except Exception as e:
        print(f"  Error processing {file_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process_green_images.py <file_path1> <file_path2> ...")
        sys.exit(1)
    
    for file_path in sys.argv[1:]:
        process_image(file_path)
