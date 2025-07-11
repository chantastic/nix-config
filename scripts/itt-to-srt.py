#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python312

import argparse
import xml.etree.ElementTree as ET
import re
from pathlib import Path

def convert_itt_to_srt(input_file, output_file=None):
    # Parse the ITT file
    tree = ET.parse(input_file)
    root = tree.getroot()
    namespaces = {'ttml': 'http://www.w3.org/ns/ttml'}

    # Find all caption entries
    captions = []
    for i, p in enumerate(root.findall(".//ttml:p", namespaces)):
        begin = p.attrib.get('begin')
        end = p.attrib.get('end')
        text = "".join(p.itertext()).strip()

        # Skip entries without proper timing
        if not begin or not end:
            continue

        # Convert timestamp format: 00:00:01.000 → 00:00:01,000
        begin = re.sub(r'\.(\d+)', r',\1', begin)
        end = re.sub(r'\.(\d+)', r',\1', end)

        captions.append(f"{i+1}\n{begin} --> {end}\n{text}\n")

    # Determine output path
    if not output_file:
        output_file = Path(input_file).with_suffix(".srt")

    with open(output_file, "w", encoding="utf-8") as f:
        f.writelines(captions)

    print(f"✅ Converted to: {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert .itt (iTunes Timed Text) to .srt (SubRip Subtitle)")
    parser.add_argument("input", help="Path to .itt file")
    parser.add_argument("-o", "--output", help="Optional path to output .srt file")

    args = parser.parse_args()
    convert_itt_to_srt(args.input, args.output) 