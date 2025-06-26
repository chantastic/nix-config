# Lesson 6: Node.js Setup - From Complex to Clean

## Overview
This lesson chronicles our journey from a complex Node.js setup with multiple package managers to a clean, reliable configuration. We'll explore the challenges of using corepack, signature verification issues, and the benefits of a simplified approach.

## The Initial Goal
We wanted to set up a Node.js development environment with:
- Latest Node.js and npm
- TypeScript compiler (`tsc`)
- Cloudflare Wrangler CLI
- Latest yarn (v4.x) via corepack
- pnpm package manager

## Step 1: The Complex Approach (What Didn't Work)

### Attempting Corepack for All Package Managers
Our first approach tried to use corepack for both yarn and pnpm:

```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22
    typescript
    wrangler
  ];

  home.sessionPath = [
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"  # For corepack-managed tools
  ];

  home.activation = {
    enableCorepack = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.nodejs_22}/bin/corepack enable --install-directory $HOME/.local/bin
      ${pkgs.nodejs_22}/bin/corepack prepare yarn@latest --activate
      ${pkgs.nodejs_22}/bin/corepack prepare pnpm@latest --activate
    '';
  };
}
```

### The Problems We Encountered

1. **Signature Verification Errors**: Corepack 0.29.4 with Node.js 22.10.0 had signature verification issues:
   ```
   Error: Cannot find matching keyid: {"signatures":[...]}
   ```

2. **Permission Issues**: Corepack tried to create symlinks in the Nix store (read-only):
   ```
   EACCES: permission denied, symlink '...' -> '/nix/store/.../bin/yarn'
   ```

3. **Symlink Confusion**: Corepack created `yarnpkg` but not `yarn`, requiring manual symlink creation

4. **Activation Script Complexity**: The activation scripts ran before PATH updates, requiring full paths to binaries

## Step 2: The Hybrid Approach (Partial Success)

### What Worked for Yarn
We successfully set up yarn via corepack by:
- Using `--install-directory $HOME/.local/bin` to avoid Nix store permissions
- Creating the missing `yarn` symlink manually
- Adding `~/.local/bin` to PATH

### What Failed for pnpm
The signature verification bug prevented pnpm from working via corepack, so we kept it as a Nix package.

## Step 3: The Clean Solution (What Works)

### Why We Simplified
After encountering multiple issues with corepack, we realized that:
- **Reliability beats complexity**: Nix packages are more reliable than corepack
- **Simplicity wins**: Fewer moving parts means fewer failure points
- **Ephemeral needs**: When you need the latest yarn, you can use it temporarily

### The Final Clean Configuration

```nix
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs_22  # Latest version
    # Global packages
    typescript  # TypeScript compiler (tsc)
    wrangler    # Cloudflare Wrangler CLI (includes TypeScript support)
    pnpm        # Fast package manager
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

## Key Lessons Learned

### 1. Corepack Limitations
- **Signature verification bugs**: Can prevent package manager installation
- **Permission issues**: Nix store is read-only, requiring alternative directories
- **Version compatibility**: Specific Node.js/corepack combinations may not work
- **Symlink complexity**: Corepack doesn't always create expected symlinks

### 2. Nix Package Advantages
- **Reliability**: No signature verification issues
- **Simplicity**: No complex activation scripts needed
- **Consistency**: Same behavior across all systems
- **Reproducibility**: Guaranteed to work on any machine

### 3. When to Use Corepack
- **Temporary needs**: For specific projects requiring latest versions
- **Stable combinations**: When you know the Node.js/corepack version works
- **Alternative approach**: Use `npx yarn@latest` for one-off needs

## The Final Working Setup

### What We Have
- **Node.js v22.10.0** - Latest LTS version
- **npm v10.9.0** - Package manager
- **TypeScript v5.4.5** - TypeScript compiler (`tsc`)
- **Wrangler v3.34.2** - Cloudflare Workers CLI
- **pnpm v9.7.0** - Fast package manager

### What We Removed
- ❌ **yarn** - No longer available via corepack
- ❌ **corepack** - No longer used
- ❌ **~/.local/bin** - Removed from PATH
- ❌ **Complex activation scripts** - Simplified

## For Ephemeral Yarn Needs

When you need yarn for a specific project:

```bash
# Use npx to run yarn without installing it globally
npx yarn@latest

# Or use corepack temporarily
npx corepack prepare yarn@latest --activate
```

## Troubleshooting Common Issues

### Corepack Signature Verification
**Problem**: `Error: Cannot find matching keyid`
**Solution**: Use Nix packages instead, or try different Node.js/corepack versions

### Permission Denied in Nix Store
**Problem**: `EACCES: permission denied, symlink`
**Solution**: Use `--install-directory $HOME/.local/bin` with corepack

### Missing Symlinks
**Problem**: Corepack creates `yarnpkg` but not `yarn`
**Solution**: Manually create symlinks or use Nix packages

### Activation Script Failures
**Problem**: Commands not found during activation
**Solution**: Use full paths to binaries in activation scripts

## Best Practices

1. **Start Simple**: Begin with Nix packages before adding complexity
2. **Test Thoroughly**: Verify each addition works before moving on
3. **Keep It Reproducible**: Ensure your setup works on fresh machines
4. **Document Issues**: Track what doesn't work for future reference
5. **Embrace Simplicity**: Sometimes the simpler solution is better

## Reflection Questions

- What surprised you about the complexity of corepack setup?
- How does the reliability of Nix packages compare to other package managers?
- When would you choose to use corepack vs Nix packages?
- How does this experience change your approach to tool selection?

## Key Takeaways

1. **Complexity has costs**: More moving parts mean more potential failure points
2. **Nix packages are reliable**: They work consistently across environments
3. **Corepack has limitations**: Signature verification and permission issues can be problematic
4. **Simplicity wins**: A clean, simple setup is often better than a complex one
5. **Ephemeral tools have their place**: Use temporary solutions for specific needs

This lesson demonstrates the importance of choosing the right tools for the job and the value of simplicity in system configuration!
