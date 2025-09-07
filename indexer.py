#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
from fractions import Fraction

def format_file_size(size_bytes):
    """Convert bytes to human readable format."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024.0:
            return f"{int(size_bytes)} {unit}" if unit == 'B' else f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f} TB"

def get_aspect_ratio(width, height):
    """Calculate and format aspect ratio."""
    if not width or not height:
        return None

    # Calculate ratio and try to simplify to common ratios
    ratio = width / height

    # Check for common aspect ratios first
    common_ratios = {
        16/9: "16:9",
        4/3: "4:3",
        3/2: "3:2",
        1/1: "1:1",
        9/16: "9:16",
        3/4: "3:4",
        2/3: "2:3"
    }

    for r, name in common_ratios.items():
        if abs(ratio - r) < 0.01:  # Allow small tolerance
            return name

    # For other ratios, use fraction simplification
    try:
        frac = Fraction(width, height).limit_denominator(100)
        return f"{frac.numerator}:{frac.denominator}"
    except:
        return f"{ratio:.2f}:1"

def get_image_info(file_path):
    """Get image dimensions and file size."""
    try:
        with Image.open(file_path) as img:
            width, height = img.size
        file_size = file_path.stat().st_size
        aspect_ratio = get_aspect_ratio(width, height)
        return width, height, file_size, aspect_ratio
    except Exception as e:
        print(f"Warning: Could not read image info for {file_path}: {e}")
        file_size = file_path.stat().st_size if file_path.exists() else 0
        return None, None, file_size, None

def generate_directory_index(base_dir="docs"):
    """Generate main index with directory links."""
    base_path = Path(base_dir)

    # Find directories with .webp files
    directories = []
    for dir_path in base_path.iterdir():
        if dir_path.is_dir():
            webp_files = list(dir_path.glob("*.webp"))
            if webp_files:
                directories.append((dir_path.name, len(webp_files)))

    if not directories:
        print(f"No directories with .webp files found in {base_path}")
        return False

    directories.sort()

    # Generate HTML
    links = "\n".join(
        f'\t\t<p><a href="{name}.html">{name}/</a> ({count} images)</p>'
        for name, count in directories
    )

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
\t<meta charset="UTF-8">
\t<title>WebP Image Directories</title>
\t<style>
\t\tbody {{ text-align: center; font-family: sans-serif; }}
\t\th1 {{ margin: 40px 0; }}
\t\tp {{ margin: 15px 0; }}
\t\ta {{ text-decoration: none; font-size: 1.1em; }}
\t\ta:hover {{ text-decoration: underline; }}
\t</style>
</head>
<body>
\t<h1>WebP Image Directories</h1>
{links}
</body>
</html>"""

    output_path = Path(base_dir) / "index.html"
    output_path.write_text(html, encoding="utf-8")
    print(f"Generated main index {output_path} with {len(directories)} directories")
    return True

def generate_webp_index(source_dir, output_file):
    """Generate HTML index file for .webp images."""
    source = Path(source_dir)
    webp_files = sorted(source.glob("*.webp"))

    if not webp_files:
        print(f"No .webp files found in {source}")
        return False

    dir_name = source.name

    # Generate image figures
    figures = []
    for f in webp_files:
        width, height, file_size, aspect_ratio = get_image_info(f)
        size_str = format_file_size(file_size)

        # Build caption info
        info_parts = []
        if width and height:
            info_parts.append(f"{width}×{height}")
        if aspect_ratio:
            info_parts.append(aspect_ratio)
        info_parts.append(size_str)

        caption = f"{f.name}<br><small>{' • '.join(info_parts)}</small>"
        figures.append(
            f'\t\t<figure>\n\t\t\t<img src="{dir_name}/{f.name}" alt="{f.stem}">\n\t\t\t<figcaption>{caption}</figcaption>\n\t\t</figure>'
        )

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
\t<meta charset="UTF-8">
\t<title>WebP Images - {dir_name}</title>
\t<style>
\t\tbody {{ text-align: center; font-family: sans-serif; }}
\t\tfigure {{ margin: 20px 0; }}
\t\tfigcaption {{ margin-top: 5px; font-size: 0.9em; line-height: 1.3; }}
\t\tfigcaption small {{ color: #666; font-size: 0.8em; }}
\t\timg {{ display: block; margin: 0 auto; max-width: 90%; height: auto; }}
\t\t.back-link {{ margin: 20px 0; font-size: 1.1em; }}
\t\t.back-link a {{ text-decoration: none; }}
\t\t.back-link a:hover {{ text-decoration: underline; }}
\t</style>
</head>
<body>
\t<div class="back-link">
\t\t<a href="index.html">← Back to directories</a>
\t</div>
\t<h1>{dir_name}</h1>
{"".join(figures)}
</body>
</html>"""

    Path(output_file).write_text(html, encoding="utf-8")
    print(f"Generated {output_file} with {len(webp_files)} images")
    return True

def generate_all_indexes(base_dir="docs"):
    """Generate main directory index and individual directory pages."""
    base_path = Path(base_dir)

    # Generate main directory listing
    generate_directory_index(base_dir)

    # Generate individual directory pages
    for dir_path in base_path.iterdir():
        if dir_path.is_dir() and list(dir_path.glob("*.webp")):
            source_dir = f"{base_dir}/{dir_path.name}"
            output_file = f"{base_dir}/{dir_path.name}.html"
            generate_webp_index(source_dir, output_file)

if __name__ == "__main__":
    generate_all_indexes()
