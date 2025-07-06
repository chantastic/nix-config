# Lesson 19: Managing Zsh Configuration with Nix and Dotfiles

## Overview
This lesson covers how to structure your Zsh configuration for maximum portability, maintainability, and reproducibility using Nix (Home Manager) and traditional dotfiles. We migrated most shell logic from `shell.nix` to standalone dotfiles, while keeping Nix-specific configuration in Nix.

## What We Did
- **Moved shell logic (aliases, functions, history settings) from `shell.nix` to dotfiles** in `dotfiles/zsh/`.
- **Created a `bootstrap.zsh`** that sources all other `.zsh` files in `~/.config/zsh/`, ensuring modular and portable config.
- **Configured Home Manager to symlink all dotfiles** into `~/.config/zsh/` using `home.file`.
- **Used `initExtra` in `shell.nix`** to source `bootstrap.zsh` automatically in every Zsh session.
- **Kept Nix-specific environment variables (like `$PATH` with `.nix-profile`) in `sessionVariables`** in `shell.nix` for clarity and reproducibility.

## Trade-offs and Reasoning
### Pros of this approach
- **Portability:** Dotfiles can be used on any system, not just Nix-based ones.
- **Syntax highlighting and editor support:** Editing shell logic in standalone files is easier and more robust.
- **Shareability:** Others can copy and remix your dotfiles without needing your Nix config.
- **Declarative management:** Home Manager ensures your dotfiles are always present and up-to-date.
- **No double-sourcing:** Using a single entry point (`bootstrap.zsh`) avoids redundant or recursive sourcing.

### Cons / Trade-offs
- **Slightly more indirection:** You need to maintain both Nix config and dotfiles, and ensure they stay in sync.
- **Nix-specific logic must stay in Nix:** Environment variables or settings that only make sense in a Nix context should not be in portable dotfiles.
- **Order of sourcing matters:** If you set the same environment variable in both Nix and dotfiles, the last one sourced wins (dotfiles override Nix for interactive shells).

## Best Practices
- **Keep Nix-specific config in `shell.nix`** (e.g., `sessionVariables` for `.nix-profile`).
- **Keep portable shell logic in dotfiles.**
- **Use a single entry point (`bootstrap.zsh`)** and source it via `initExtra` in your Nix config.
- **Let Home Manager manage symlinks** for all your dotfiles.
- **Avoid redundant sourcing** by not sourcing dotfiles directly in each other—let `bootstrap.zsh` handle it.

## Example `shell.nix` snippet
```nix
programs.zsh = {
  enable = true;
  autosuggestion.enable = true;
  enableCompletion = true;
  syntaxHighlighting.enable = true;
  sessionVariables = {
    PATH = "$HOME/.nix-profile/bin:$PATH";
  };
  initExtra = ''
    source ~/.config/zsh/bootstrap.zsh
  '';
};

home.file.".config/zsh/bootstrap.zsh".source = ../dotfiles/zsh/bootstrap.zsh;
home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;
home.file.".config/zsh/aliases.zsh".source = ../dotfiles/zsh/aliases.zsh;
home.file.".config/zsh/editor.zsh".source = ../dotfiles/zsh/editor.zsh;
home.file.".config/zsh/visual.zsh".source = ../dotfiles/zsh/visual.zsh;
```

---

This approach gives you the best of both worlds: Nix-powered reproducibility and the flexibility/portability of classic dotfiles.
