#!/usr/bin/env python3
from pathlib import Path

def generate_directory_index(base_dir="docs", output_file="docs/index.html"):
    """Generate main index with directory links."""
    script_dir = Path(__file__).parent.resolve()
    base_path = (script_dir / base_dir).resolve()
    output_path = (script_dir / output_file).resolve()

    # Find directories with .webp files
    directories = []
    for dir_path in base_path.iterdir():
        if dir_path.is_dir() and list(dir_path.glob("*.webp")):
            webp_count = len(list(dir_path.glob("*.webp")))
            directories.append((dir_path.name, webp_count))

    if not directories:
        print(f"No directories with .webp files found in {base_path}")
        return False

    directories.sort()  # Sort alphabetically

    # Generate directory links
    links = "\n".join(
        f'\t\t<p><a href="{dir_name}.html">{dir_name}/</a> ({count} images)</p>'
        for dir_name, count in directories
    )

    html = f"""<!DOCTYPE html>
<html lang="en">
\t<head>
\t\t<meta charset="UTF-8">
\t\t<title>WebP Image Directories</title>
\t\t<style>
\t\t\t/* Minimal CSS for directory listing */
\t\t\tbody {{ text-align: center; font-family: sans-serif; }}
\t\t\th1 {{ margin: 40px 0; }}
\t\t\tp {{ margin: 15px 0; }}
\t\t\ta {{ text-decoration: none; font-size: 1.1em; }}
\t\t\ta:hover {{ text-decoration: underline; }}
\t\t</style>
\t</head>
\t<body>
\t\t<h1>WebP Image Directories</h1>
{links}
\t</body>
</html>"""

    output_path.write_text(html, encoding="utf-8")
    print(f"Generated main index {output_path} with {len(directories)} directories")
    return True

def generate_webp_index(source_dir, output_file):
    """Generate HTML index file for .webp images with centered vertical layout."""
    script_dir = Path(__file__).parent.resolve()
    source = (script_dir / source_dir).resolve()
    output_path = (script_dir / output_file).resolve()

    webp_files = sorted(source.glob("*.webp"))
    if not webp_files:
        print(f"No .webp files found in {source}")
        return False

    dir_name = Path(source_dir).name

    body = "\n".join(
        f'\t\t<figure>\n\t\t\t<img src="{dir_name}/{f.name}" alt="{f.stem}">\n\t\t\t<figcaption>{f.name}</figcaption>\n\t\t</figure>'
        for f in webp_files
    )

    html = f"""<!DOCTYPE html>
<html lang="en">
\t<head>
\t\t<meta charset="UTF-8">
\t\t<title>WebP Images - {dir_name}</title>
\t\t<style>
\t\t\t/* Minimal CSS for vertical centered images with captions */
\t\t\tbody {{ text-align: center; }}
\t\t\tfigure {{ margin: 20px 0; }}
\t\t\tfigcaption {{ margin-top: 5px; font-size: 0.9em; }}
\t\t\timg {{ display: block; margin: 0 auto; max-width: 90%; height: auto; }}
\t\t\t.back-link {{ margin: 20px 0; font-size: 1.1em; }}
\t\t\t.back-link a {{ text-decoration: none; }}
\t\t\t.back-link a:hover {{ text-decoration: underline; }}
\t\t</style>
\t</head>
\t<body>
\t\t<div class="back-link">
\t\t\t<a href="index.html">← Back to directories</a>
\t\t</div>
\t\t<h1>{dir_name}</h1>
{body}
\t</body>
</html>"""

    output_path.write_text(html, encoding="utf-8")
    print(f"Generated {output_path} with {len(webp_files)} images")
    return True

def generate_all_indexes(base_dir="docs"):
    """Generate main directory index and individual directory pages."""
    script_dir = Path(__file__).parent.resolve()
    base_path = (script_dir / base_dir).resolve()

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
