# Lesson 11: Organizing Your Nix Configuration with Modules

## Overview

As your Nix configuration grows, it becomes essential to organize it into logical, maintainable modules. This lesson covers how to structure your configuration for clarity, reusability, and ease of maintenance.

## Why Organize with Modules?

### Benefits of Modular Organization

1. **Separation of Concerns**: Each module handles a specific domain
2. **Maintainability**: Easier to find and modify specific configurations
3. **Reusability**: Modules can be shared across different configurations
4. **Clarity**: Clear purpose for each file
5. **Collaboration**: Easier for teams to work on different areas

### Common Organization Patterns

#### 1. **Language-Specific Modules**
```nix
modules/node.nix      # Node.js, TypeScript, npm tools
modules/python.nix    # Python, pip, virtual environments
modules/rust.nix      # Rust, cargo, rustup
```

#### 2. **Purpose-Specific Modules**
```nix
modules/git.nix       # Git configuration and aliases
modules/media.nix     # Video, audio, image processing
modules/editors.nix   # Text editors and IDEs
```

#### 3. **Category-Based Modules**
```nix
modules/development.nix  # All development tools
modules/system.nix       # System utilities
modules/productivity.nix # Productivity tools
```

## Creating Your First Module

### Step 1: Identify What to Extract

Look for related functionality in your main configuration. For example, if you have multiple media-related packages:

```nix
# Before: Everything in flake.nix
home.packages = with pkgs; [
  ffmpeg
  gifski
  exiftool
  tesseract
  # ... other packages
];
```

### Step 2: Create the Module File

Create a new file in the `modules/` directory:

```nix
# modules/media.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg         # Video and audio processing
    gifski         # GIF creation
    exiftool       # Image metadata
    tesseract      # OCR
    yt-dlp         # YouTube downloader
  ];
}
```

### Step 3: Import the Module

Add the module to your `flake.nix`:

```nix
# flake.nix
homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    # ... other modules
    ./modules/media.nix
  ];
};
```

### Step 4: Remove from Main Configuration

Remove the extracted packages from your main configuration to avoid duplication.

## Module Best Practices

### 1. **Descriptive File Names**

Use clear, descriptive names that indicate the module's purpose:

```bash
# Good
modules/git.nix
modules/node.nix
modules/media.nix

# Avoid
modules/tools.nix
modules/stuff.nix
modules/config.nix
```

### 2. **Consistent Structure**

Follow a consistent pattern in each module:

```nix
{ config, lib, pkgs, ... }:

{
  # Packages
  home.packages = with pkgs; [
    # Group related packages with comments
  ];

  # Program configurations
  programs.someProgram = {
    enable = true;
    # Configuration here
  };

  # Environment variables
  home.sessionVariables = {
    # Variables here
  };
}
```

### 3. **Group Related Functionality**

Keep related tools together:

```nix
# modules/development.nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Version control
    git
    lazygit
    
    # Editors
    neovim
    
    # Terminal tools
    tmux
    zoxide
  ];
}
```

### 4. **Use Comments for Organization**

Add comments to group related items:

```nix
home.packages = with pkgs; [
  # Video processing
  ffmpeg
  gifski
  yt-dlp
  
  # Image processing
  exiftool
  tesseract
  
  # Audio processing
  sox
  openai-whisper
];
```

## Advanced Module Patterns

### 1. **Conditional Modules**

Create modules that can be conditionally enabled:

```nix
# modules/optional.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.optional;
in
{
  options.optional = {
    enable = lib.mkEnableOption "Enable optional features";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Optional packages
    ];
  };
}
```

### 2. **Module Composition**

Combine multiple modules into a larger configuration:

```nix
# modules/development.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./node.nix
    ./editors.nix
  ];
}
```

### 3. **Shared Configuration**

Create modules for shared settings:

```nix
# modules/common.nix
{ config, lib, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
```

## Common Module Categories

### **Language Development**
- `modules/node.nix` - Node.js ecosystem
- `modules/python.nix` - Python ecosystem
- `modules/rust.nix` - Rust ecosystem

### **System & Utilities**
- `modules/git.nix` - Git configuration
- `modules/shell.nix` - Shell configuration
- `modules/tools.nix` - General utilities

### **Media & Content**
- `modules/media.nix` - Media processing
- `modules/design.nix` - Design tools
- `modules/writing.nix` - Writing tools

### **Workflow & Productivity**
- `modules/editors.nix` - Text editors
- `modules/terminal.nix` - Terminal tools
- `modules/productivity.nix` - Productivity apps

## Troubleshooting Module Issues

### 1. **Module Not Found**

If you get a "file not found" error:

```bash
# Check if the file exists
ls -la modules/

# Ensure the path is correct in flake.nix
cat flake.nix | grep modules
```

### 2. **Duplicate Packages**

If packages appear twice:

```bash
# Check for duplicates across modules
grep -r "ffmpeg" modules/
```

### 3. **Configuration Conflicts**

If configurations conflict:

```bash
# Check for conflicting settings
nix eval .#homeConfigurations.chan.config
```

## Migration Strategy

### Step-by-Step Migration

1. **Start Small**: Begin with one logical group
2. **Test Incrementally**: Apply changes and test after each module
3. **Keep Backups**: Maintain working configuration
4. **Document Changes**: Update README and comments

### Example Migration

```bash
# 1. Create new module
touch modules/media.nix

# 2. Move packages
# (Edit files manually)

# 3. Test configuration
nix run .#activate

# 4. Verify packages work
ffmpeg -version
```

## Exercises

### Exercise 1: Create a Media Module

1. Create `modules/media.nix`
2. Move all media-related packages from your main configuration
3. Test that everything still works

### Exercise 2: Organize by Purpose

1. Identify 3-4 logical groups in your current configuration
2. Create modules for each group
3. Update your `flake.nix` to import the new modules

### Exercise 3: Add Conditional Features

1. Create a module with optional features
2. Add a configuration option to enable/disable it
3. Test both enabled and disabled states

## Key Takeaways

1. **Start with clear boundaries**: Each module should have a single, clear purpose
2. **Use descriptive names**: File names should indicate the module's function
3. **Group related items**: Keep related packages and configurations together
4. **Test incrementally**: Apply and test changes one module at a time
5. **Document your structure**: Update README and add comments for clarity

## Next Steps

- **Lesson 12**: Advanced home-manager configurations
- **Lesson 13**: Creating custom flake apps
- **Lesson 14**: Managing multiple environments

## Resources

- [Home-Manager Modules](https://nix-community.github.io/home-manager/options.html)
- [NixOS Module System](https://nixos.wiki/wiki/Module)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

---

**Reflection Questions:**
- What patterns do you see in your current configuration that could be modularized?
- How might modular organization help with your specific use cases?
- What challenges do you anticipate when organizing your configuration?
