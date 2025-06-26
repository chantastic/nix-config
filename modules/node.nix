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