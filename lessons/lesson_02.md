# Lesson 2: User Environment Management with Home-Manager

## What We Learned

In this lesson, we expanded our Nix flake to manage user-specific configurations using home-manager, moving beyond simple packages to a declarative user environment setup.

### Key Concepts Covered

1. **Home-Manager**: A tool for managing user environments declaratively
2. **User vs System Configuration**: Understanding the difference between user-specific and system-wide settings
3. **Package Management**: Installing user packages through home-manager
4. **Configuration Activation**: How to apply and manage home-manager configurations
5. **Shell Integration**: Properly integrating home-manager with your shell environment

### Our Final Home-Manager Flake

```nix
{
  description = "A minimal Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.runCommand "empty" {} "echo 'Doing nothing' > $out";

      homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home = {
              username = "chan";
              homeDirectory = "/Users/chan";
              stateVersion = "23.11";
            };
            
            home.packages = with pkgs; [
              git
            ];
          }
        ];
      };
    };
}
```

## Step-by-Step Setup

### Step 1: Add Home-Manager Input

We added home-manager as a new input to our flake:

```nix
home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**Key Point**: The `inputs.nixpkgs.follows = "nixpkgs"` ensures home-manager uses the same nixpkgs version as our main flake, preventing version conflicts.

### Step 2: Create Home Configuration

We defined a home configuration for your user:

```nix
homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home = {
        username = "chan";
        homeDirectory = "/Users/chan";
        stateVersion = "23.11";
      };
      
      home.packages = with pkgs; [
        git
      ];
    }
  ];
};
```

**Important Settings**:
- `username`: Your system username
- `homeDirectory`: Your home directory path
- `stateVersion`: Home-manager version for configuration compatibility
- `home.packages`: List of packages to install

### Step 3: Apply the Configuration

Run the activation command to apply your configuration:

```bash
nix run .#homeConfigurations.chan.activationPackage
```

### Step 4: Set Up Shell Integration

Add the home-manager profile to your PATH:

```bash
echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.zshrc
```

## You May Need to Know

### The Eval Problem

**What Happened**: Initially, we tried to use `eval "$(nix run .#homeConfigurations.chan.activationPackage)"` in the shell profile, which caused errors.

**Why It Failed**: The activation script outputs status messages, not shell commands. Using `eval` tried to execute these messages as commands.

**The Fix**: Remove the problematic line and manually run the activation command when needed:

```bash
# Remove the problematic line
sed -i '' '/eval.*homeConfigurations.chan.activationPackage/d' ~/.zshrc

# Apply manually when making changes
nix run .#homeConfigurations.chan.activationPackage
```

### Git Tree Warnings

**What You See**: `warning: Git tree '/Users/chan/nix-config' has uncommitted changes`

**What It Means**: Your flake.nix has uncommitted changes in git.

**Solutions**:
- **Commit your changes**: `git add . && git commit -m "Add home-manager configuration"`
- **Ignore the warning**: It doesn't affect functionality, just indicates uncommitted changes

### State Version Management

**What It Is**: `stateVersion` tells home-manager which version of your configuration format you're using.

**Why It Matters**: When home-manager updates, it may change how configurations are structured. The state version helps it migrate your config properly.

**Best Practice**: Only change this when you're ready to handle potential migration issues.

### Input Following

**The Pattern**: `inputs.nixpkgs.follows = "nixpkgs"`

**Why We Use It**: Ensures all parts of your flake use the same version of nixpkgs, preventing version conflicts and reducing build time.

**Alternative**: You could pin different versions, but this often leads to compatibility issues.

## Challenges

### Challenge 1: Add More Packages
**Goal**: Expand your package collection

**Tasks**:
- Add development tools (ripgrep, fd, fzf)
- Include text editors (neovim, vscode)
- Add language runtimes (node, python, rust)

**Learning**: Package selection and dependency management

### Challenge 2: Configure Git
**Goal**: Set up git configuration declaratively

**Example**:
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
  };
};
```

**Learning**: Home-manager program modules vs package installation

### Challenge 3: Shell Configuration
**Goal**: Configure your shell through home-manager

**Example**:
```nix
programs.zsh = {
  enable = true;
  initExtra = ''
    # Your custom zsh configuration
    export EDITOR="nvim"
    alias ll="ls -la"
  '';
  shellAliases = {
    ll = "ls -la";
    gs = "git status";
  };
};
```

**Learning**: Declarative shell configuration and environment management

### Challenge 4: Dotfile Management
**Goal**: Manage your dotfiles through home-manager

**Options**:
- `.gitconfig` through `programs.git`
- `.vimrc` through `programs.vim`
- Custom dotfiles through `home.file`

**Example**:
```nix
home.file.".vimrc".text = ''
  set number
  set expandtab
  set tabstop=2
'';
```

**Learning**: File management and configuration templating

## Next Lessons Preview

### Lesson 3: System Configuration with Nix-Darwin
- Setting up nix-darwin for macOS system management
- Managing system services, settings, and applications
- Integrating home-manager with nix-darwin

### Lesson 4: Development Environment Management
- Creating project-specific development shells
- Managing language-specific tools and dependencies
- Setting up development workflows

### Lesson 5: Advanced Home-Manager Features
- Custom modules and configuration reuse
- Environment-specific configurations
- Integration with external tools and services

### Lesson 6: Flake Composition and Modularity
- Breaking configurations into modules
- Sharing configurations across projects
- Creating reusable flake components

## Key Takeaways

1. **Declarative User Management**: Home-manager lets you manage your user environment as code
2. **Package vs Program**: Understanding when to use `home.packages` vs `programs.*`
3. **Configuration Activation**: Home-manager configurations must be explicitly applied
4. **Shell Integration**: Proper PATH setup is crucial for accessing installed packages
5. **State Management**: Version tracking helps with configuration evolution

## Reflection Questions

- How does managing user packages through home-manager differ from traditional package managers?
- What advantages do you see in declarative user configuration?
- How might this approach change how you set up new development machines?
- What challenges do you anticipate when scaling this configuration to include more tools and settings?

## Troubleshooting Common Issues

### "Command not found" after installation
**Cause**: PATH not properly set up
**Solution**: Ensure `export PATH="$HOME/.nix-profile/bin:$PATH"` is in your shell profile

### Activation fails with permission errors
**Cause**: Insufficient permissions for home directory modifications
**Solution**: Check file permissions and ensure you own the home directory

### Packages not updating
**Cause**: Old home-manager generation still active
**Solution**: Run activation command again and restart your shell

### Configuration syntax errors
**Cause**: Invalid Nix syntax in home-manager configuration
**Solution**: Use `nix eval .#homeConfigurations.chan.config` to validate syntax

This foundation in home-manager sets you up perfectly for managing your entire user environment declaratively!
