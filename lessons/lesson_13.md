# Lesson 13: Organizing Node.js Packages in Nix

## Overview

This lesson covers how to properly organize Node.js packages in your Nix configuration, including when to use `nodePackages` vs npm global installation, and how to organize packages semantically across different modules.

## Key Concepts

### Node.js Packages in Nix

There are two main approaches to installing Node.js packages globally:

1. **`nodePackages.<package-name>`** - Pre-built Node.js packages from Nix
2. **npm global installation** - Installing via npm/yarn/pnpm with global directory management

### When to Use Each Approach

#### Use `nodePackages` When:
- The package is available in the Nix package repository
- You want declarative, reproducible installation
- You want faster installation and better isolation
- The package is a standalone tool (like `svgo`, `typescript`, `eslint`)

#### Use npm Global When:
- The package isn't available in `nodePackages`
- You need the latest version that's not yet in Nix
- You're working with packages that have complex dependencies
- You need to manage versions dynamically

## Practical Example: Adding SVG Optimization

Let's walk through adding `svgo` (SVG optimization tool) to your configuration.

### Step 1: Check Availability

First, check if the package is available in `nodePackages`:

```bash
nix search nixpkgs svgo
```

### Step 2: Choose the Right Module

Consider where the package belongs semantically:

- **`node.nix`**: Node.js development tools (runtime, package managers, build tools)
- **`media.nix`**: Media processing tools (image, video, audio processing)

Since `svgo` is primarily a media processing tool, it belongs in `media.nix`.

### Step 3: Add to Configuration

```nix
# modules/media.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg         # Video and audio processing
    gifski         # GIF creation
    libavif        # AVIF image format
    exiftool       # Image metadata
    tesseract      # OCR
    yt-dlp         # YouTube downloader
    openai-whisper # Speech recognition
    sox            # Audio processing and effects
    ffmpegthumbnailer  # Generate video thumbnails
    mediainfo      # Media file information
    nodePackages.svgo  # SVG optimization
  ];
}
```

### Step 4: Verify Installation

After running `home-manager switch`, verify the installation:

```bash
svgo --help
```

## Module Organization Best Practices

### Semantic Grouping

Organize packages by their primary function, not their implementation:

```nix
# modules/node.nix - Node.js development tools
home.packages = with pkgs; [
  nodejs_22        # Runtime
  typescript       # Compiler
  wrangler         # Cloudflare CLI
  pnpm             # Package manager
];

# modules/media.nix - Media processing tools
home.packages = with pkgs; [
  ffmpeg           # Video processing
  nodePackages.svgo # Image optimization
  gifski           # GIF creation
];
```

### Benefits of This Approach

1. **Discoverability**: Easy to find related tools
2. **Maintainability**: Clear separation of concerns
3. **Reusability**: Modules can be shared or conditionally included
4. **Clarity**: New team members understand the structure quickly

## npm Global Installation Setup

For packages that need npm global installation, use this pattern:

```nix
# modules/node.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
    # ... other packages
  ];

  # Set up environment variables for Node.js
  home.sessionVariables = {
    NODE_ENV = "development";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Add npm global bin to PATH
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # Create npm global directory if it doesn't exist
  home.activation = {
    createNpmGlobalDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/.npm-global
    '';
  };
}
```

Then install packages manually:

```bash
npm install -g some-package
```

## Comparison: nodePackages vs npm Global

| Aspect | nodePackages | npm Global |
|--------|-------------|------------|
| **Installation** | Declarative in Nix | Manual via npm |
| **Versioning** | Fixed by Nix | Latest available |
| **Reproducibility** | High | Medium |
| **Speed** | Fast | Slower |
| **Isolation** | High | Medium |
| **Updates** | Via flake update | Manual |
| **Availability** | Limited to Nix packages | All npm packages |

## Common Patterns

### Development Tools in node.nix

```nix
# modules/node.nix
home.packages = with pkgs; [
  nodejs_22
  typescript
  nodePackages.eslint
  nodePackages.prettier
  wrangler
  pnpm
];
```

### Media Tools in media.nix

```nix
# modules/media.nix
home.packages = with pkgs; [
  ffmpeg
  nodePackages.svgo
  nodePackages.sharp
  gifski
  # ... other media tools
];
```

### Build Tools in a separate module

```nix
# modules/build.nix
home.packages = with pkgs; [
  nodePackages.webpack
  nodePackages.vite
  nodePackages.rollup
];
```

## Troubleshooting

### Package Not Found

If a package isn't available in `nodePackages`:

1. Check if it exists: `nix search nixpkgs <package-name>`
2. Consider using npm global installation
3. Check if there's an alternative package name

### Version Issues

If you need a specific version:

1. Use npm global installation for exact version control
2. Consider using `nodePackages` with version pinning in your flake
3. Create a custom package derivation if needed

### PATH Issues

If a package isn't found in PATH:

```bash
# Check if it's installed
which svgo

# Verify PATH includes home-manager profile
echo $PATH | grep nix-profile

# Restart shell or source profile
source ~/.zshrc
```

## Summary

- Use `nodePackages` for available packages - it's faster, more reproducible, and better isolated
- Organize packages semantically by function, not implementation
- Use npm global installation only when necessary
- Keep related tools together in the same module
- Consider creating separate modules for different categories of tools

This approach gives you the best of both worlds: declarative, reproducible configuration with the flexibility to use npm packages when needed.
