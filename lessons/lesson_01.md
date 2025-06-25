# Lesson 1: Building Your First Nix Flake

## What We Learned

In this lesson, we created a minimal working Nix flake from scratch and explored fundamental Nix concepts.

### Key Concepts Covered

1. **Flake Structure**: A Nix flake is a JSON-like configuration with `inputs`, `outputs`, and metadata
2. **System Targeting**: Flakes can target specific architectures (we used `aarch64-darwin` for Apple Silicon)
3. **Package Building**: How to define buildable packages using `pkgs.runCommand`
4. **Development Environments**: Understanding `devShells` vs global dependencies
5. **Flake Commands**: Essential commands for working with flakes

### Our Final Minimal Flake

```nix
{
  description = "A minimal Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.runCommand "empty" {} "echo 'Doing nothing' > $out";
    };
}
```

## Challenges

### Challenge 1: Multi-Platform Support
**Goal**: Make your flake work on both Apple Silicon and Intel Macs

**Hint**: Look into `nixpkgs.lib.platforms` and `builtins.currentSystem`

**Expected Outcome**: A flake that automatically detects and works on your system

### Challenge 2: Add a Real Package
**Goal**: Replace the "empty" package with something useful

**Options**:
- Build a simple shell script
- Package a small utility like `cowsay` or `fortune`
- Create a custom "Hello World" program

**Learning**: Understanding `pkgs.writeScriptBin`, `pkgs.stdenv.mkDerivation`, and package building

### Challenge 3: Reintroduce Development Shells
**Goal**: Add back `devShells` but with a purpose

**Tasks**:
- Create a devShell with project-specific tools
- Add environment variables
- Include shell hooks for setup

**Learning**: `pkgs.mkShell`, `buildInputs`, `shellHook`, and development environment management

### Challenge 4: Add More Inputs
**Goal**: Expand beyond just nixpkgs

**Options**:
- Add `flake-utils` for better multi-platform support
- Include `home-manager` for user configuration
- Add `nix-darwin` for system configuration

**Learning**: Input management, version pinning, and ecosystem integration

## Next Lessons Preview

### Lesson 2: Global System Configuration
- Setting up `nix-darwin` for macOS
- Managing system services and settings
- Understanding the relationship between flakes and system configs

### Lesson 3: User Environment Management
- Using `home-manager` for user configurations
- Setting up git, shell configurations, and user tools
- Managing dotfiles declaratively

### Lesson 4: Development Workflows
- Creating project-specific development environments
- Managing dependencies and build tools
- Integrating with IDEs and editors

### Lesson 5: Advanced Flake Patterns
- Overlays and package customization
- Cross-compilation and multi-system builds
- Flake composition and modularity

## Key Takeaways

1. **Minimal is Valid**: Even a simple flake that "does nothing" is a complete, working Nix configuration
2. **System Awareness**: Always consider your target architecture when building flakes
3. **Incremental Growth**: Start simple and add complexity as needed
4. **Command Familiarity**: Understanding basic flake commands is essential for debugging and development

## Reflection Questions

- What surprised you about how minimal a working flake can be?
- How does the declarative nature of Nix differ from traditional package management?
- What advantages do you see in having reproducible development environments?
- How might flakes change your approach to project setup and dependency management?

This foundation sets you up perfectly for exploring more advanced Nix concepts and building sophisticated system configurations! 
