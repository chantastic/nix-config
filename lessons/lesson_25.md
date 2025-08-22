Lesson 25 — Installing global npm packages not in nixpkgs

Problem
- Nixpkgs doesn't always include every npm package you want to install globally (for CLI tools, language servers, etc.). You still want reproducible setup and to avoid installing things into the system node that Nix manages.

Solution overview
- Create a user-level npm prefix (e.g. `$HOME/.npm-global`) and ensure it's on your `PATH`.
- Use a Nix home activation to create the directory and run `npm install -g` for packages missing from nixpkgs.
- Keep the command idempotent and tolerant of failures (e.g. `|| true`) so activation doesn't fail builds if npm install transiently fails.

Example: `modules/node.nix` activation

```nix
{
  # ... existing attrs ...
  home.packages = with pkgs; [ nodejs_22 pnpm typescript ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.activation = {
    createNpmGlobalDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG $HOME/.npm-global
    '';

    installCustomGlobalNpm = lib.hm.dag.entryAfter ["createNpmGlobalDir"] ''
      $DRY_RUN_CMD $VERBOSE_ARG $HOME/.npm-global/bin/npm install -g @anthropic-ai/claude-code@latest || true
    '';
  };
}
```

Notes and best practices
- Prefer packaging into nixpkgs if the package is important to your environment or organization — that makes installs reproducible and auditable.
- Use a separate global prefix under your home to avoid conflicts with Nix-managed node installs.
- Consider pinning the package version instead of `@latest` for stability.
- Only use `|| true` if you accept that activation may silently skip installs on failure; otherwise fail fast and surface the error.

Tasks
- Add package installs to `home.activation` as shown.
- Add documentation to your dotfiles repo so others follow the same pattern.


