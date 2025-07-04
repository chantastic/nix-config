# Lesson 15: Python Packaging with Nix - The Reality Check

## Overview

This lesson covers the practical realities of managing Python packages with Nix, including common issues, workarounds, and idiomatic solutions.

## The Problem: "Typical Python Bullshit"

### Initial Issue
- Attempted to use `openai-whisper` for speech recognition
- Encountered import errors with numpy/torch dependencies
- Classic "dependency hell" with native library linking on macOS

### Root Cause
```
ImportError: dlopen(...) Library not loaded: /nix/store/.../libgfortran.5.dylib
```

**Why this happens:**
- Nix prebuilt packages have hardcoded library paths
- macOS dynamic linking doesn't find libraries in Nix store paths
- Scientific Python packages (numpy, torch) depend on native libraries (BLAS, LAPACK, gfortran)
- These dependencies are complex to get right in Nix on macOS

## The Solution: Choose the Right Tool

### Option 1: C++ Alternatives (Recommended)
Instead of fighting Python dependencies, use C++ implementations:

```nix
# modules/media.nix
{
  home.packages = with pkgs; [
    openai-whisper-cpp  # C++ implementation, no Python dependencies
    # Available commands: whisper-cpp, whisper-cpp-stream
  ];
}
```

**Benefits:**
- No dependency hell
- Faster execution
- Lower memory usage
- Same quality results
- Fully reproducible

### Option 2: Dev Shells for Complex Dependencies
For cases where you need Python packages with complex dependencies:

```nix
# flake.nix
devShells.${system} = {
  python-ml = pkgs.mkShell {
    buildInputs = with pkgs; [
      python312
      python312Packages.openai-whisper
      python312Packages.torch
      # System dependencies included automatically
      gfortran
      blas
      lapack
    ];
  };
};
```

## Idiomatic Python Configuration in Nix

### What We Learned About Python Defaults

```bash
# Python automatically includes user site-packages in sys.path
python -m site --user-site
# Output: /Users/chan/.local/lib/python3.12/site-packages

# User binaries go to
python -m site --user-base  # /Users/chan/.local
# So binaries are in: /Users/chan/.local/bin
```

### Minimal, Idiomatic Setup

```nix
# modules/python.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python runtime and package manager
    python312
    python312Packages.pip
  ];

  # Add Python user bin to PATH for pip-installed packages
  # (Python automatically includes ~/.local/lib/python3.12/site-packages in sys.path)
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
```

### What We Don't Need

❌ **Redundant PYTHONPATH**: Python includes user site-packages automatically
❌ **setuptools/wheel**: Modern pip includes these
❌ **python.withPackages**: Overly complex for simple setups
❌ **System dependencies**: Only needed if actually using problematic packages
❌ **Complex environment variables**: DYLD_* variables don't work reliably

## Nix Python Package Management Strategy

### 1. Externally Managed Environment
Nix Python prevents pip installs by default:
```bash
pip install package
# Error: externally-managed-environment
```

This is **good** - it encourages proper package management.

### 2. Package Priority Order

1. **Nix packages first** (when available):
   ```nix
   python312Packages.requests
   python312Packages.flask
   ```

2. **C++ alternatives** (for ML/scientific packages):
   ```nix
   openai-whisper-cpp    # Instead of openai-whisper
   sqlite               # Instead of python sqlite3 modules
   ```

3. **Dev shells** (for project-specific needs):
   ```bash
   nix develop .#python-ml
   ```

4. **Pip as last resort** (with caution):
   ```bash
   pip install --user --break-system-packages package-name
   ```

## Practical Examples

### Working Example: whisper-cpp
```bash
# Download model
whisper-cpp-download-ggml-model base

# Transcribe audio
whisper-cpp -m models/ggml-base.bin audio.wav

# Output to SRT
whisper-cpp -m models/ggml-base.bin --output-srt audio.wav
```

### Failed Example: openai-whisper (Python)
```bash
whisper --help
# Traceback... ImportError: Library not loaded: libgfortran.5.dylib
```

## Key Takeaways

### 1. **Embrace Nix Philosophy**
- Use system packages when available
- Prefer compiled alternatives to complex Python dependencies
- Keep configurations minimal and idiomatic

### 2. **Python-Specific Lessons**
- Python automatically handles user site-packages paths
- Nix protects against pip pollution (this is good!)
- Version-specific paths (python3.12) prevent conflicts

### 3. **When to Use What**
- **System tools**: Use Nix packages (`ffmpeg`, `tesseract`, `whisper-cpp`)
- **Development**: Use dev shells with proper dependencies
- **Simple packages**: Nix packages when available
- **Complex ML packages**: Consider C++ alternatives first

### 4. **Debugging Strategy**
When packages don't work:
1. Check if C++ alternative exists
2. Try dev shell with system dependencies
3. Search for known working combinations
4. Consider if you really need that specific package

## Module Organization

```
modules/
├── python.nix     # Minimal Python runtime + pip
├── media.nix      # Media tools (including whisper-cpp)
└── ...
```

Keep Python simple, put media tools where they belong.

## Conclusion

The best Python setup in Nix is often the one that avoids complex Python dependencies entirely. When you do need Python packages, keep the base configuration minimal and use the right tool for each job.

Remember: "Typical Python bullshit" often has elegant solutions in the Nix ecosystem - you just need to know where to look!
