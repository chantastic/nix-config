# Nix Configuration

This repository contains my personal Nix configuration using flakes and home-manager for declarative system and user environment management.

## What's Included

- **Home-Manager Configuration**: User environment management with declarative configuration
- **Git Configuration**: Complete git setup with aliases, LFS support, and workflow optimizations
- **Package Management**: User packages and development tools
- **Lessons**: Step-by-step guides for learning Nix configuration

## Quick Start

### Prerequisites

- Nix with flakes enabled
- macOS (aarch64-darwin)

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url> nix-config
   cd nix-config
   ```

2. **Apply the configuration**:
   ```bash
   nix run .#homeConfigurations.chan.activationPackage
   ```

3. **Set up shell integration** (if not already done):
   ```bash
   echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

## Making Changes

### Adding New Packages

Edit `flake.nix` and add packages to the `home.packages` list:

```nix
home.packages = with pkgs; [
  git
  ripgrep
  fd
  fzf
  # Add your packages here
];
```

### Modifying Git Configuration

Edit the `programs.git` section in `flake.nix`:

```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  # Add more configuration...
};
```

### Applying Changes

After making any changes to `flake.nix`, apply them:

```bash
nix run .#homeConfigurations.chan.activationPackage
```

## Configuration Structure

```
flake.nix
├── inputs
│   ├── nixpkgs (unstable)
│   └── home-manager
└── outputs
    └── homeConfigurations.chan
        ├── home.packages (user packages)
        └── programs.git (git configuration)
```

## Lessons

This repository includes step-by-step lessons for learning Nix configuration:

- **Lesson 1**: Basic Nix flake setup
- **Lesson 2**: Home-manager introduction and user environment management
- **Lesson 3**: Git configuration with home-manager (first-class options vs extraConfig)

Each lesson builds on the previous one, providing a comprehensive learning path.

## Key Concepts

### First-Class Options vs ExtraConfig

- **First-Class Options**: Type-validated configuration options (e.g., `userName`, `userEmail`, `aliases`)
- **ExtraConfig**: Flexible configuration for any setting (e.g., `core.editor`, `init.defaultBranch`)

### Object Syntax

Group related settings for better organization:

```nix
extraConfig = {
  diff = {
    compactionHeuristic = true;
    colorMoved = "zebra";
  };
  log = {
    pretty = "oneline";
    abbrevCommit = true;
  };
};
```

## Troubleshooting

### Configuration Not Applied

```bash
# Check if home-manager is properly set up
nix run .#homeConfigurations.chan.activationPackage

# Verify git configuration
git config --list --show-origin
```

### Package Not Found

```bash
# Ensure PATH includes home-manager profile
echo $PATH | grep nix-profile

# Restart your shell or source your profile
source ~/.zshrc
```

### Build Errors

```bash
# Check for syntax errors
nix eval .#homeConfigurations.chan.config

# Update flake inputs
nix flake update
```

## Development

### Adding New Programs

To add configuration for a new program:

1. Check if home-manager has a module for it: `programs.<program-name>`
2. If available, use the first-class options
3. If not, use `extraConfig` for flexibility

### Creating Custom Modules

For reusable configuration components, create separate `.nix` files and import them:

```nix
# modules/git-development.nix
{ config, lib, ... }:
{
  programs.git = {
    enable = true;
    # Your git configuration
  };
}

# flake.nix
modules = [
  ./modules/git-development.nix
  # ... other modules
];
```

## Resources

- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Wiki](https://nixos.wiki/)

## License

This configuration is for personal use. Feel free to adapt it for your own needs. 