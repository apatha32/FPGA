def rgb_to_rgb565(r, g, b):
    r5 = (r >> 3) & 0x1F
    g6 = (g >> 2) & 0x3F
    b5 = (b >> 3) & 0x1F
    return (r5 << 11) | (g6 << 5) | b5

def image_to_rgb565(image):
    binary_data = bytearray()
    width, height = image.size
    for y in range(height):
        for x in range(width):
            r, g, b = image.getpixel((x, y))            
            rgb565 = rgb_to_rgb565(r, g, b) # RGB 565 16bits
            # divied to 2 bytes
            binary_data.append((rgb565 >> 8) & 0xFF)
            binary_data.append(rgb565 & 0xFF)

    return binary_data