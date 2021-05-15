import os, sys
from PIL import Image

def pad(filename):
    file, ext = os.path.splitext(filename)
    if len(file) < 3 or file[-3:] == "_sq" or ext != ".png":
        return

    img = Image.open(filename)
    img = img.convert('RGBA')
    pixels = img.load()
    (width, height) = img.size
    gap_w = (48 - width) // 2
    gap_h = (48 - height) // 2
    
    new_img = Image.new('RGBA', (48, 48), "#0000")
    pixels_new = new_img.load()
    for i in range(48):
        for j in range(48):
            if i < gap_w or j < gap_h or i >= width + gap_w or j >= height + gap_h:
                pixels_new[i,j] = 0
            else:
                pixels_new[i,j] = pixels[i-gap_w, j-gap_h]
    
    new_img.save(file + "_sq.png", "PNG")

def pad_for_scaled(filename):
    file, ext = os.path.splitext(filename)
    if len(file) < 3 or file[-3:] == "_sq" or ext != ".png":
        return

    img = Image.open(filename)
    img = img.convert('RGBA')
    pixels = img.load()
    (width, height) = img.size
    gap_w = (height - width) // 2
    
    new_img = Image.new('RGBA', (height, height), "#0000")
    pixels_new = new_img.load()
    for i in range(height):
        for j in range(height):
            if i < gap_w or i >= width + gap_w:
                pixels_new[i,j] = 0
            else:
                pixels_new[i,j] = pixels[i-gap_w, j]
    
    new_img.save(file + "_sq.png", "PNG")


    
def pad_all_folder(folder):
    files = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    for file in files:
        pad(os.path.join(folder, file))


pad_all_folder("assets/images/units/basic")
pad_all_folder("assets/images/units/advanced")
pad_all_folder("assets/images/units/master")
pad_all_folder("assets/images/units/elite")
pad_all_folder("assets/images/units/boss")
pad_all_folder("assets/images/units/basic/battle")
pad_all_folder("assets/images/units/advanced/battle")
pad_all_folder("assets/images/units/master/battle")
pad_all_folder("assets/images/units/elite/battle")
pad_all_folder("assets/images/units/boss/battle")
pad_all_folder("assets/images/weapons")
pad_all_folder("assets/images/projectiles")
