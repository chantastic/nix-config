# Lesson 12: Python Packaging with Nix

## Overview

This lesson covers how to effectively manage Python packages using Nix instead of traditional package managers like pip or conda.

## Why Use Nix for Python Packages?

### Advantages of Nix Python Packages

1. **Reproducible Builds**
   - Exact same versions and dependencies every time
   - No "works on my machine" issues
   - Consistent across different systems

2. **System Integration**
   - Python packages can depend on system libraries seamlessly
   - No need to manage complex native dependencies
   - Works with tools like `ffmpeg`, `tesseract`, `torch`

3. **No Virtual Environment Conflicts**
   - Nix handles isolation automatically
   - No need to activate/deactivate environments
   - System-wide consistency

4. **Better Dependency Resolution**
   - Nix's dependency solver is more robust than pip's
   - Avoids dependency conflicts
   - Handles transitive dependencies better

5. **Rollback Capability**
   - Easy to switch between different package sets
   - Atomic updates and rollbacks
   - Version pinning through flake.lock

## When to Use Nix vs pip

### Use Nix for:
- **Core development tools** (TypeScript, Python, Node.js)
- **System-wide utilities** (ffmpeg, tesseract, media tools)
- **Packages with complex dependencies** (torch, opencv)
- **Tools you want available everywhere**
- **Reproducible development environments**

### Use pip for:
- **Project-specific dependencies**
- **Packages not yet in nixpkgs**
- **Rapid prototyping with latest versions**
- **Very specific version constraints**
- **Local development only**

## Our Configuration Structure

### Media Tools (System-wide)
```nix
# modules/media.nix
{
  home.packages = with pkgs; [
    ffmpeg         # Video and audio processing
    gifski         # GIF creation
    libavif        # AVIF image format
    exiftool       # Image metadata
    tesseract      # OCR
    yt-dlp         # YouTube downloader
    openai-whisper # Speech recognition (CLI + Python)
    sox            # Audio processing and effects
    ffmpegthumbnailer  # Generate video thumbnails
    mediainfo      # Media file information
  ];
}
```

**Benefits:**
- Available system-wide
- Can be used from any language
- CLI tools work in any terminal
- Python libraries included automatically

### Python Development Tools
```nix
# modules/python.nix
{
  home.packages = with pkgs; [
    python312      # Python runtime
    
    # Development tools
    python312Packages.pip
    python312Packages.setuptools
    
    # Add other Python packages here as needed
  ];
}
```

**Benefits:**
- Modular dev-shells possible
- Python-specific tools
- Can be combined with pip for project dependencies

## Practical Examples

### Using openai-whisper

**As CLI tool (from media.nix):**
```bash
whisper audio.mp3 --model base --output_dir transcriptions/
```

**As Python library (included with Nix package):**
```python
import whisper
model = whisper.load_model("base")
result = model.transcribe("audio.mp3")
print(result["text"])
```

### Using yt-dlp

**As CLI tool:**
```bash
yt-dlp "https://youtube.com/watch?v=..." --format "best[height<=720]"
```

**As Python library:**
```python
import yt_dlp

ydl_opts = {
    'format': 'best[height<=720]',
    'outtmpl': '%(title)s.%(ext)s'
}

with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    ydl.download(['https://youtube.com/watch?v=...'])
```

## Best Practices

### 1. Modular Organization
- Separate system tools from language-specific tools
- Group related functionality (media, development, etc.)
- Keep modules focused and maintainable

### 2. System-wide vs Project-specific
- Use Nix for tools you want available everywhere
- Use pip for project-specific dependencies
- Consider dev-shells for project isolation

### 3. Dependency Management
- Let Nix handle system dependencies
- Use pip for Python-specific version constraints
- Document both Nix and pip dependencies

### 4. Development Workflow
```bash
# System tools available everywhere
ffmpeg -i input.mp4 output.mp4
whisper audio.mp3
yt-dlp "https://youtube.com/..."

# Project-specific Python packages
cd my-project
pip install -r requirements.txt
python my_script.py
```

## Troubleshooting

### Common Issues

1. **Package not found in nixpkgs**
   - Check if it exists: `nix search nixpkgs package-name`
   - Consider using pip for that specific package
   - Wait for it to be added to nixpkgs

2. **Broken packages**
   - Some packages may be marked as broken
   - Use `NIXPKGS_ALLOW_BROKEN=1` temporarily
   - Look for alternatives or wait for fixes

3. **Version conflicts**
   - Nix packages are versioned through nixpkgs
   - Use pip for specific version requirements
   - Consider using dev-shells for project isolation

### Checking Package Availability
```bash
# Search for packages
nix search nixpkgs package-name

# Check if package exists
nix show-derivation nixpkgs#python312Packages.package-name

# Dry run to test configuration
nix build .#homeConfigurations.chan.activationPackage --dry-run
```

## Summary

Using Nix for Python packages provides:
- **Better system integration**
- **Reproducible environments**
- **No virtual environment management**
- **Seamless CLI and library access**

The key is choosing the right tool for the job:
- **Nix** for system-wide tools and complex dependencies
- **pip** for project-specific and rapid development needs

This hybrid approach gives you the best of both worlds: reliable system tools and flexible project development.
