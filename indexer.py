#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
from math import gcd

def format_file_size(size_bytes):
    """Convert bytes to human readable format."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.0f} {unit}" if unit == 'B' else f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"

def get_aspect_ratio(width, height):
    """Calculate aspect ratio as simplified fraction."""
    if not width or not height:
        return None

    divisor = gcd(width, height)
    return f"{width//divisor}:{height//divisor}"

def get_image_info(file_path):
    """Get image info: width, height, file size, aspect ratio."""
    try:
        with Image.open(file_path) as img:
            width, height = img.size
        file_size = file_path.stat().st_size
        aspect_ratio = get_aspect_ratio(width, height)
        return width, height, file_size, aspect_ratio
    except Exception:
        return None, None, file_path.stat().st_size, None

def create_html(title, body, back_link=False):
    """Create HTML page with common structure."""
    back = '<div class="back-link"><a href="index.html">← Back to directories</a></div>' if back_link else ''

    return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
        body {{ text-align: center; font-family: sans-serif; }}
        h1 {{ margin: 40px 0; }}
        p {{ margin: 15px 0; }}
        a {{ text-decoration: none; font-size: 1.1em; }}
        a:hover {{ text-decoration: underline; }}
        figure {{ margin: 20px 0; }}
        figcaption {{ margin-top: 5px; font-size: 0.9em; }}
        figcaption small {{ color: #666; font-size: 0.8em; }}
        img {{ max-width: 90%; height: auto; }}
        .back-link {{ margin: 20px 0; }}
    </style>
</head>
<body>
    {back}
    {body}
</body>
</html>'''

def generate_main_index(base_dir="docs"):
    """Generate main directory index."""
    base_path = Path(base_dir)

    directories = []
    for dir_path in base_path.iterdir():
        if dir_path.is_dir():
            webp_count = len(list(dir_path.glob("*.webp")))
            if webp_count > 0:
                directories.append((dir_path.name, webp_count))

    if not directories:
        print(f"No .webp files found in {base_path}")
        return

    directories.sort()

    links = "\n    ".join(f'<p><a href="{name}.html">{name}/</a> ({count} images)</p>'
                         for name, count in directories)

    body = f"<h1>WebP Image Directories</h1>\n    {links}"
    html = create_html("WebP Image Directories", body)

    (base_path / "index.html").write_text(html)
    print(f"Generated index with {len(directories)} directories")

def generate_dir_page(dir_path):
    """Generate page for a single directory."""
    webp_files = sorted(dir_path.glob("*.webp"))
    if not webp_files:
        return

    figures = []
    for f in webp_files:
        width, height, file_size, aspect_ratio = get_image_info(f)

        info = []
        if width and height:
            info.append(f"{width}×{height}")
        if aspect_ratio:
            info.append(aspect_ratio)
        info.append(format_file_size(file_size))

        caption = f"{f.name}<br><small>{' • '.join(info)}</small>"
        figures.append(f'<figure><img src="{dir_path.name}/{f.name}"><figcaption>{caption}</figcaption></figure>')

    body = f'<h1>{dir_path.name}</h1>\n    ' + '\n    '.join(figures)
    html = create_html(f"WebP Images - {dir_path.name}", body, back_link=True)

    output_file = dir_path.parent / f"{dir_path.name}.html"
    output_file.write_text(html)
    print(f"Generated {dir_path.name}.html with {len(webp_files)} images")

def main():
    """Generate all index files."""
    base_path = Path("docs")

    generate_main_index("docs")

    for dir_path in base_path.iterdir():
        if dir_path.is_dir() and list(dir_path.glob("*.webp")):
            generate_dir_page(dir_path)

if __name__ == "__main__":
    main()
