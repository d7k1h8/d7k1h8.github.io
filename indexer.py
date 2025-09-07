#!/usr/bin/env python3

from pathlib import Path

def generate_webp_index(source_dir="docs/dir0", output_file="docs/index.html"):
    """Generate HTML index file for .webp images with centered vertical layout."""

    # Get directory of the current script
    script_dir = Path(__file__).parent.resolve()

    # Resolve source and output paths relative to script_dir
    source = (script_dir / source_dir).resolve()
    output_file = (script_dir / output_file).resolve()

    webp_files = sorted(source.glob("*.webp"))

    if not webp_files:
        print(f"No .webp files found in {source}")
        return False

    body = "\n".join(
        f'\t\t<figure>\n\t\t\t<img src="dir0/{f.name}" alt="{f.stem}">\n\t\t\t<figcaption>{f.name}</figcaption>\n\t\t</figure>'
        for f in webp_files
    )

    html = f"""<!DOCTYPE html>
<html lang="en">
\t<head>
\t\t<meta charset="UTF-8">
\t\t<title>WebP Images</title>
\t\t<style>
\t\t\t/* Minimal CSS for vertical centered images with captions */
\t\t\tbody {{ text-align: center; }}
\t\t\tfigure {{ margin: 20px 0; }}
\t\t\tfigcaption {{ margin-top: 5px; font-size: 0.9em; }}
\t\t\timg {{ display: block; margin: 0 auto; max-width: 90%; height: auto; }}
\t\t</style>
\t</head>
\t<body>
{body}
\t</body>
</html>"""

    output_file.write_text(html, encoding="utf-8")
    print(f"Generated {output_file} with {len(webp_files)} images")
    return True

if __name__ == "__main__":
    generate_webp_index()
