# Lesson 5: Adding Node.js and npm as a Nix Module

## Overview
This lesson demonstrates how to add Node.js (with npm) to your Nix configuration using a dedicated module. You'll learn how to set up the latest Node.js version, configure npm for global package installs, and ensure your configuration is reproducible and tracked by Git.

## Why Modularize Node.js?
- **Separation of concerns**: Keep language runtimes and tools in their own modules
- **Easy upgrades**: Update Node.js or npm in one place
- **Custom configuration**: Set environment variables and npm global directory

## Step 1: Create the Node.js Module
Create a new file at `modules/node.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22  # Latest version
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

## Step 2: Import the Module in `flake.nix`
Add the new module to your `homeConfigurations` in `flake.nix`:

```nix
modules = [
  {
    home = {
      username = "chan";
      homeDirectory = "/Users/chan";
      stateVersion = "23.11";
    };
  }
  ./modules/git.nix
  ./modules/node.nix  # Import the Node.js module
];
```

## Step 3: Track the Module with Git
**Important:** Nix requires all referenced files to be tracked by Git.

```bash
git add modules/node.nix
```

Commit your changes:
```bash
git commit -m "Add Node.js and npm module"
```

## Step 4: Activate the Configuration
Build and activate your updated configuration:

```bash
nix build .#homeConfigurations.chan.activationPackage && ./result/activate
```

## Step 5: Verify Node.js and npm
Check that Node.js and npm are available and working:

```bash
node --version
npm --version
```

## Troubleshooting
- **File not tracked by Git**: If you see an error about a path not being tracked, make sure you've added and committed the new module file.
- **Version conflicts**: Only include one Node.js version in your `home.packages` to avoid collisions.

## Summary
You now have a modular, reproducible Node.js and npm setup managed by Nix! This approach makes it easy to update, share, and maintain your development environment.
