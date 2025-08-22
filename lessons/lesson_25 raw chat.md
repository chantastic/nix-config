# Add npm package @Commit
_Exported on 8/21/2025 at 17:19:40 PDT from Cursor (1.4.5)_

---

**User**

i'd like to add the npm package '@anthropic-ai/claude-code'

---

**Cursor**

I'll open `modules/node.nix` to see how packages are declared so I can add `@anthropic-ai/claude-code`.

I'll create two todos, then add an activation entry in `modules/node.nix` to install `@anthropic-ai/claude-code` into the existing npm global prefix, then run lints and mark the todos done.

I'll reconcile the todo list, apply the edit to `modules/node.nix` to add an activation that installs `@anthropic-ai/claude-code`, then run lints on that file. I'll start by updating the todo list.

```plaintext
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
    # Install global npm packages that aren't in nixpkgs via npm
    installAnthropicClaudeCode = lib.hm.dag.entryAfter ["createNpmGlobalDir"] ''
      $DRY_RUN_CMD $VERBOSE_ARG $HOME/.npm-global/bin/npm install -g @anthropic-ai/claude-code@latest || true
    '';
  };
} 

```

Done — I added an activation entry that installs `@anthropic-ai/claude-code` globally and ran lints. Summary:

- Edited `modules/node.nix` to add `installAnthropicClaudeCode` activation that runs:
  - `$HOME/.npm-global/bin/npm install -g @anthropic-ai/claude-code@latest || true`
- Verified no linter errors.

Next steps or changes?

---

**User**

add /lesson/lesson_25.md lesson on ading global packages not in nix-packages

---

**Cursor**

I'll create two todos, add `lessons/lesson_25.md` with a concise lesson and example `node.nix` activation, run lints, then mark the todos done. I'll start by writing the todos.

```markdown
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


```

Done — I added `lessons/lesson_25.md` with a concise guide and example activation snippet, and ran lints. Summary:

- Added `lessons/lesson_25.md` explaining how to install npm packages globally when they're not in nixpkgs, including an example `home.activation` snippet.
- Verified no linter errors.

Anything to adjust (tone, length, examples, pinning versions)?

