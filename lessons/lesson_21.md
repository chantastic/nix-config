# Lesson 21: Python Scripts in Nix Configuration

## Overview

This lesson covers how to integrate Python scripts into your nix-config, making them both locally convenient and globally shareable. We'll learn about nix-shell shebangs, flake apps, and the powerful remote execution capabilities.

## Prerequisites

- Completed Lesson 1 (Basic Nix flake setup)
- Completed Lesson 11 (Organizing with modules)
- Basic understanding of Python

## What You'll Learn

- How to add Python scripts to your nix-config
- Using nix-shell shebangs for dependency management
- Creating flake apps for Python scripts
- Making commands globally available
- Remote execution capabilities
- Best practices for script organization

---

## Step 1: Understanding the Architecture

### The Three-Layer System

```
Python Script (itt-to-srt.py)
    ↓
Flake App (packages script + dependencies)
    ↓
Shell Alias (convenient global access)
```

**Why this architecture?**

- **Flake Apps**: Package scripts with dependencies, enable remote execution
- **Shell Aliases**: Provide convenient local access
- **Scripts**: The actual functionality

### Key Benefits

✅ **Reproducible**: Dependencies are declared and versioned  
✅ **Portable**: Can run from anywhere without setup  
✅ **Discoverable**: `nix flake show` lists all available tools  
✅ **Shareable**: Anyone can use your tools remotely  

---

## Step 2: Creating a Python Script

### Basic Script Structure

Create your Python script in the `scripts/` directory:

```python
#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python312

import argparse
import xml.etree.ElementTree as ET
import re
from pathlib import Path

def main():
    # Your script logic here
    pass

if __name__ == "__main__":
    main()
```

### The Nix-Shell Shebang

The shebang tells nix-shell to:
- Use Python 3 as the interpreter (`-i python3`)
- Install Python 3.12 and any additional packages (`-p python312`)

**For scripts with dependencies:**
```python
#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python312 python312Packages.requests python312Packages.click
```

---

## Step 3: Adding as a Flake App

### Update flake.nix

Add your script to the `apps` section:

```nix
apps.${system} = {
  itt-to-srt = {
    type = "app";
    program = toString (pkgs.writeShellScript "itt-to-srt" ''
      exec ${pkgs.python312}/bin/python ${./scripts/itt-to-srt.py} "$@"
    '');
  };
};
```

### What This Does

- Creates an executable command named `itt-to-srt`
- Wraps your Python script with proper argument passing (`"$@"`)
- Uses the Python interpreter from your nix environment

---

## Step 4: Making Commands Global

### Option A: Shell Aliases (Recommended)

Add to `dotfiles/zsh/aliases.zsh`:

```bash
# Nix Config Commands
alias nix-activate="nix run ~/nix-config#activate"
alias nix-macos-settings="nix run ~/nix-config#macos-settings"
alias itt-to-srt="nix run ~/nix-config#itt-to-srt"
```

### Option B: Full Path Usage

```bash
# From anywhere
nix run ~/nix-config#itt-to-srt input.itt
```

### Option C: Remote Execution

```bash
# Anyone can run your tools without cloning
nix run github:youruser/nix-config#itt-to-srt input.itt
```

---

## Step 5: Discovering Available Commands

### Local Discovery

```bash
# From within your nix-config directory
nix flake show
```

### Remote Discovery

```bash
# From anywhere
nix flake show github:youruser/nix-config
```

This shows all available:
- **Apps**: Your executable commands
- **Packages**: Available packages
- **Home Configurations**: User environments

---

## Step 6: Best Practices

### Script Organization

```
scripts/
├── itt-to-srt.py          # Python scripts
├── macos-settings.sh      # Shell scripts
└── configure-dock.sh      # Shell scripts
```

### Dependency Management

**Minimal approach** (recommended):
```python
#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python312
```

**With external packages**:
```python
#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python312 python312Packages.requests
```

### Error Handling

Always include proper error handling in your scripts:

```python
import sys

try:
    # Your script logic
    pass
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
```

---

## Step 7: Advanced Features

### Version-Specific Execution

```bash
# Run specific versions
nix run github:youruser/nix-config/v1.0.0#itt-to-srt input.itt
nix run github:youruser/nix-config/main#itt-to-srt input.itt
```

### Branch-Specific Execution

```bash
# Run from specific branches
nix run github:youruser/nix-config/feature-branch#itt-to-srt input.itt
```

### CI/CD Integration

Your scripts can be used in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Convert subtitles
  run: nix run github:youruser/nix-config#itt-to-srt input.itt
```

---

## Practical Example: itt-to-srt.py

Let's walk through the complete example:

### 1. Script Creation

```python
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
    parser = argparse.ArgumentParser(description="Convert .itt to .srt")
    parser.add_argument("input", help="Path to .itt file")
    parser.add_argument("-o", "--output", help="Optional output path")

    args = parser.parse_args()
    convert_itt_to_srt(args.input, args.output)
```

### 2. Flake App Addition

```nix
apps.${system} = {
  itt-to-srt = {
    type = "app";
    program = toString (pkgs.writeShellScript "itt-to-srt" ''
      exec ${pkgs.python312}/bin/python ${./scripts/itt-to-srt.py} "$@"
    '');
  };
};
```

### 3. Shell Alias

```bash
alias itt-to-srt="nix run ~/nix-config#itt-to-srt"
```

### 4. Usage

```bash
# Local usage
itt-to-srt input.itt

# Remote usage
nix run github:youruser/nix-config#itt-to-srt input.itt
```

---

## Key Takeaways

### The Power of Remote Execution

This is one of the most powerful features of Nix flakes:

- **Zero-install**: Run tools without downloading or installing
- **Reproducible**: Same environment every time
- **Shareable**: Anyone can use your tools instantly
- **Versioned**: Run specific versions or branches

### When to Use This Pattern

✅ **Utility scripts** (like itt-to-srt)  
✅ **One-off tools** you don't want to install globally  
✅ **Team tools** that need consistent environments  
✅ **CI/CD tools** that require specific dependencies  

### Architecture Benefits

- **Flake Apps**: The engine (packages dependencies)
- **Shell Aliases**: The steering wheel (convenience)
- **Remote Execution**: The superpower (global sharing)

---

## Next Steps

1. **Apply your configuration**: `nix run .#activate`
2. **Test your script**: `itt-to-srt input.itt`
3. **Share your tools**: Push to GitHub and share the remote execution commands
4. **Explore discovery**: Use `nix flake show` to see all available tools

## Related Lessons

- **Lesson 1**: Basic Nix flake setup
- **Lesson 11**: Organizing with modules
- **Lesson 12**: Python packaging with Nix

---

## Callouts

> **💡 Pro Tip**: Use `nix flake show` to discover what tools are available in any flake, including your own!

> **🚀 Superpower**: Remote execution makes your nix-config a portable toolkit that anyone can use without setup.

> **🔧 Best Practice**: Keep your Python module minimal and add dependencies only when needed in individual scripts.

> **📦 Architecture**: Flake apps are the source of truth, aliases are convenience layers. Both are valuable!
