from PIL import Image, ImageDraw
import os

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_icon(input_path, output_path, scale_ratio=0.45, background_color=None, radius_ratio=0.0):
    try:
        img = Image.open(input_path).convert("RGBA")
        width, height = img.size
        
        # Calculate new content size
        new_width = int(width * scale_ratio)
        new_height = int(height * scale_ratio)
        
        # Resize the original image
        resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create background
        if background_color:
            bg_color = hex_to_rgb(background_color) + (255,) # Add alpha
            new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
            
            # Draw background shape (Square or Rounded)
            # For app icons, usually better to provide full square and let OS mask.
            # But if radius is requested specifically:
            if radius_ratio > 0:
                draw = ImageDraw.Draw(new_img)
                # Draw rounded rectangle
                radius = int(width * radius_ratio)
                draw.rounded_rectangle([(0,0), (width, height)], radius=radius, fill=bg_color)
            else:
                new_img = Image.new("RGBA", (width, height), bg_color)
                
        else:
            # Transparent background
            new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        
        # Calculate paste position (center)
        paste_x = (width - new_width) // 2
        paste_y = (height - new_height) // 2
        
        # Paste the resized logo
        new_img.paste(resized_img, (paste_x, paste_y), resized_img)
        
        # Save
        new_img.save(output_path)
        print(f"Successfully created icon at {output_path}")
        
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    input_file = "assets/images/logo_test.png"
    
    # 1. Create transparent padded version (for Android Foreground)
    create_icon(input_file, "assets/images/logo_test_padded.png", scale_ratio=0.45, background_color=None)
    
    # 2. Create Blue Background version (for iOS / Android Legacy / Fallback)
    # Using #0F172A (Deep Space Blue from theme)
    # We generate a SQUARE icon. iOS/Android will apply the mask (radius).
    # If we apply radius here, iOS might show black corners. 
    # However, to simulate "radius" if the user REALLY wants to see it in the file, we could.
    # But usually "App Icon" implies the platform icon.
    create_icon(input_file, "assets/images/logo_blue.png", scale_ratio=0.45, background_color="#0F172A")

