# Lesson 4: Modularizing Nix Configurations

## Overview
As your Nix configuration grows, it becomes important to organize it into separate modules for better maintainability and readability. This lesson covers how to extract large configuration blocks into dedicated files and the critical requirement that these files must be tracked by Git.

## Why Modularize?

When your `flake.nix` file becomes large and unwieldy, it's a good practice to separate different configuration concerns into dedicated modules. This provides several benefits:

- **Cleaner main file**: Your `flake.nix` becomes more focused and easier to read
- **Better organization**: Related configurations are grouped together
- **Reusability**: Modules can be imported by multiple configurations
- **Easier maintenance**: Changes to specific functionality are isolated

## Creating a Git Module

Let's extract the git configuration from the main flake into a separate module:

### Step 1: Create the modules directory
```bash
mkdir modules
```

### Step 2: Create `modules/git.nix`
```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    
    userName = "Michael Chan";
    userEmail = "mijoch@gmail.com";
    
    extraConfig = {
      core.editor = "nvim";
      credential.helper = "osxkeychain";
      # ... rest of git configuration
    };
    
    aliases = {
      a = "add";
      b = "branch";
      # ... rest of aliases
    };
  };
}
```

### Step 3: Update `flake.nix`
```nix
{
  # ... inputs and other configuration

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home = {
              username = "chan";
              homeDirectory = "/Users/chan";
              stateVersion = "23.11";
            };
          }
          ./modules/git.nix  # Import the git module
        ];
      };
    };
}
```

## Critical: Git Tracking Requirement

**⚠️ IMPORTANT**: All files referenced in your Nix configuration must be tracked by Git. This is a security feature of Nix that prevents arbitrary file access.

### The Error You'll See
If you try to use a module that isn't tracked by Git, you'll get an error like this:

```
warning: Git tree '/Users/chan/nix-config' has uncommitted changes
error: Path 'modules/git.nix' in the repository "/Users/chan/nix-config" is not tracked by Git.

To make it visible to Nix, run:
git -C "/Users/chan/nix-config" add "modules/git.nix"
```

### The Solution
Always add new module files to Git before using them:

```bash
# Add the new module file
git add modules/git.nix

# Commit the changes
git commit -m "Add git configuration module"
```

### Why This Happens
Nix enforces this requirement because:
- **Security**: Prevents arbitrary file access outside the repository
- **Reproducibility**: Ensures configurations are version-controlled
- **Transparency**: Makes it clear what files are part of the configuration

## Best Practices for Module Organization

### 1. Directory Structure
```
nix-config/
├── flake.nix
├── modules/
│   ├── git.nix
│   ├── shell.nix
│   ├── editor.nix
│   └── development.nix
└── hosts/
    └── your-host.nix
```

### 2. Module Naming
- Use descriptive names: `git.nix`, `shell.nix`, `editor.nix`
- Group related functionality: `development.nix` for dev tools
- Consider host-specific modules: `macos.nix`, `linux.nix`

### 3. Module Structure
```nix
{ config, lib, pkgs, ... }:

{
  # Import any dependencies
  imports = [
    ./other-module.nix
  ];

  # Your configuration here
  programs.some-program = {
    enable = true;
    # ... configuration
  };
}
```

## Common Module Patterns

### Package Installation
```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    neovim
    ripgrep
  ];
}
```

### Program Configuration
```nix
{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      " Your vim configuration
    '';
  };
}
```

### Service Configuration
```nix
{ config, lib, pkgs, ... }:

{
  services.some-service = {
    enable = true;
    settings = {
      # Service settings
    };
  };
}
```

## Troubleshooting

### Module Not Found
If you get a "file not found" error:
1. Check the file path is correct
2. Ensure the file exists
3. Verify the file is tracked by Git

### Import Errors
If you get import-related errors:
1. Check the module syntax
2. Ensure all required arguments are provided
3. Verify the module returns a valid configuration

### Git Tracking Issues
If you get Git tracking errors:
1. Add the file: `git add path/to/file.nix`
2. Commit the changes: `git commit -m "Add new module"`
3. Try your Nix command again

## Summary

Modularizing your Nix configuration makes it more maintainable and organized. Remember these key points:

1. **Always track new modules in Git** before using them
2. **Use descriptive file names** for your modules
3. **Group related functionality** together
4. **Keep your main flake.nix clean** and focused
5. **Test your configuration** after making changes

This approach scales well as your configuration grows and makes it easier to share and reuse configuration components.
