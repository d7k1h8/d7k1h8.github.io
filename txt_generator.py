#!/usr/bin/env python3

"""
Generate the the .txt lora description of each image file in the format of
descriptions = {"BASENAME0": "DESCRIPTION0", "BASENAME1": "DESCRIPTION1", etc}
The key is the filename without txt extension, the value is the .txt content
"""

import os

# Get the directory where the script resides
script_dir = os.path.dirname(os.path.abspath(__file__))

# Build output path relative to script directory
output_dir = script_dir + "/docs/dir0"

# Ensure directory exists
os.makedirs(output_dir, exist_ok=True)

descriptions = {
		"CG01000": "Rance, solo, young man, brown hair, short spiky hair, brown eyes, confident smile, half-closed eyes, wearing green tunic, white metal armor, shoulder pauldrons, gauntlets, gold accents, belt with sword sheath, hand on hip, standing pose, three-quarter view, anime style, high detail",
		"CG02000": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, smirking, subtle smile, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02001": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, laughing happily, eyes closed, open mouth, sharp teeth visible, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02002": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, angry expression, yelling, wide open mouth, sharp fangs, furrowed brows, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02003": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, surprised expression, wide eyes, sweat drop, wavy mouth line, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02004": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, sly smile, half-closed eyes, hand touching chin, blushing slightly, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02005": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, serious frown, pursed lips, narrowed eyes, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02006": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, wearing glasses, sly smile, half-closed eyes, hand touching chin, wearing green collar with gold trim, white armor collar, anime style, close-up, high detail",
		"CG02010": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, smirking, subtle smile, shirtless, bare chest, muscular build, anime style, close-up, high detail",
		"CG02011": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, laughing happily, eyes closed, open mouth, sharp teeth visible, shirtless, bare chest, muscular build, anime style, close-up, high detail",
		"CG02012": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, angry expression, yelling, wide open mouth, sharp fangs, furrowed brows, shirtless, bare chest, muscular build, anime style, close-up, high detail",
		"CG02013": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, surprised expression, wide eyes, sweat drop, wavy mouth line, shirtless, bare chest, muscular build, anime style, close-up, high detail",
		"CG02014": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, sly smile, half-closed eyes, hand touching chin, blushing slightly, shirtless, bare chest, muscular build, anime style, close-up, high detail",
		"CG02015": "Rance, solo, bust portrait, young man, brown hair, short spiky hair, brown eyes, serious frown, pursed lips, narrowed eyes, shirtless, bare chest, muscular build, anime style, close-up, high detail"
		}

"""
Claude
descriptions = {
    "image1": "1boy, brown hair, messy hair, green eyes, nervous expression, gritted teeth, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image2": "1boy, brown hair, messy hair, green eyes, laughing, open mouth, fangs, happy expression, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image3": "1boy, brown hair, messy hair, green eyes, laughing, open mouth, fangs, happy expression, bare shoulders, upper body, anime style",
    "image4": "1boy, brown hair, messy hair, blue eyes, determined expression, clenched fist, bare shoulders, upper body, anime style",
    "image5": "1boy, brown hair, messy hair, green eyes, worried expression, gritted teeth, bare shoulders, upper body, anime style",
    "image6": "1boy, brown hair, messy hair, brown eyes, serious expression, closed mouth, bare shoulders, upper body, anime style",
    "image7": "1boy, brown hair, messy hair, brown eyes, confident expression, slight smile, bare shoulders, upper body, anime style",
    "image8": "1boy, brown hair, messy hair, brown eyes, confident pose, green tunic with gold trim, white armor, cape, sword at waist, full body, fantasy knight, anime style",
    "image9": "1boy, brown hair, messy hair, green eyes, angry expression, shouting, open mouth, fangs, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image10": "1boy, brown hair, messy hair, brown eyes, calm expression, slight smile, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image11": "1boy, brown hair, messy hair, blue eyes, glasses, nervous expression, gritted teeth, clenched fist, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image12": "1boy, brown hair, messy hair, blue eyes, glasses, worried expression, gritted teeth, clenched fist, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image13": "1boy, brown hair, messy hair, brown eyes, neutral expression, green uniform with gold trim, armor shoulder pads, upper body, anime style",
    "image14": "1boy, brown hair, messy hair, green eyes, angry expression, shouting, open mouth, fangs, bare shoulders, upper body, anime style"
}
"""

for img_name, desc in descriptions.items():
	txt_file = os.path.join(output_dir, f"{img_name}.txt")
    with open(txt_file, "w", encoding="utf-8") as f:
	    f.write(desc)

print("All descriptions saved in", output_dir, "as .txt files.")
