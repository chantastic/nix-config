# Lesson 10: Managing Dotfiles with Nix and Home Manager

## What We Learned

In this lesson, we explored different approaches to managing shell functions and dotfiles using Nix and Home Manager, ultimately arriving at a clean, modular solution that balances reproducibility with maintainability.

### Key Concepts Covered

1. **Dotfile Management Strategies**: Different approaches to organizing and managing shell functions
2. **Home Manager File Management**: Using `home.file` to manage dotfiles declaratively
3. **Source vs Text Management**: Choosing between importing files vs inline definitions
4. **Shell Integration**: Properly sourcing function files in zsh configuration
5. **Project Organization**: Structuring a nix-config repository for dotfiles

## The Journey: From Simple to Optimal

### Initial Goal
We wanted to set up zsh functions like this:
```bash
# No arguments: `git status -sb`
# With arguments: acts like `git`
g() {
  if [[ $# -gt 0 ]]; then
    git $@
  else
    git status -sb
  fi
}
```

### Approach 1: Direct in Nix (Simple but Limited)
```nix
programs.zsh.initExtra = ''
  g() {
    if [[ $# -gt 0 ]]; then
      git $@
    else
      git status -sb
    fi
  }
'';
```

**Pros:**
- Simple and direct
- Fast (no file I/O)
- Everything in one place

**Cons:**
- Functions mixed with Nix config
- Harder to edit for non-Nix users
- Less modular

### Approach 2: External Files with Activation Scripts (Overly Complex)
```nix
home.activation = {
  createFunctionsFile = lib.hm.dag.entryAfter ["createZshConfigDir"] ''
    $DRY_RUN_CMD cat > $VERBOSE_ARG "$HOME/.config/zsh/functions.zsh" << 'EOF'
    # Functions here...
EOF
  '';
};
```

**Challenges Encountered:**
- Complex heredoc syntax with `$VERBOSE_ARG` caused errors
- Activation scripts are harder to debug
- More complex than necessary

### Approach 3: Multiple Nix-Managed Files (Redundant)
```nix
home.file.".config/zsh/functions.zsh".text = '...';
home.file.".config/zsh/git.zsh".text = '...';
home.file.".config/zsh/utils.zsh".text = '...';
```

**Problems:**
- Functions defined in Nix strings, then written to files, then sourced
- Overly complex for the benefit gained
- Redundant file management

### Approach 4: Import from Repo Files (Optimal)
```nix
home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;
home.file.".config/zsh/utils.zsh".source = ../dotfiles/zsh/utils.zsh;
```

**Benefits:**
- Functions in separate, editable files
- Version controlled in git
- Clean separation of concerns
- Reproducible and maintainable

## Final Implementation

### Project Structure
```
nix-config/
├── modules/           # Nix modules only
│   ├── shell.nix     # Nix config that sources dotfiles
│   ├── git.nix
│   └── node.nix
├── dotfiles/         # Actual dotfiles
│   └── zsh/
│       ├── git.zsh   # Git functions
│       └── utils.zsh # Utility functions
└── scripts/          # Other scripts
```

### Shell Configuration (`modules/shell.nix`)
```nix
{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    # Enable useful features
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    # Source all .zsh files in ~/.config/zsh
    initExtra = ''
      for f in ~/.config/zsh/*.zsh; do
        source "$f"
      done
    '';
    
    # History configuration
    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    
    # Set PATH as in previous .zshrc
    sessionVariables = {
      PATH = "$HOME/.nix-profile/bin:$PATH";
    };
  };

  # Import function files from repo
  home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;
  home.file.".config/zsh/utils.zsh".source = ../dotfiles/zsh/utils.zsh;
}
```

### Function Files

**`dotfiles/zsh/git.zsh`:**
```bash
# Git functions
# No arguments: `git status -sb`
# With arguments: acts like `git`
g() {
  if [[ $# -gt 0 ]]; then
    git $@
  else
    git status -sb
  fi
}
```

**`dotfiles/zsh/utils.zsh`:**
```bash
# Utility functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

## Challenges and Caveats

### Challenge 1: File Path Resolution
**Problem:** Initial source paths were incorrect
```nix
# Wrong - relative to modules/shell.nix
home.file.".config/zsh/git.zsh".source = ./modules/zsh/git.zsh;

# Correct - relative to modules/shell.nix
home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;
```

**Solution:** Understand that paths in `home.file.source` are relative to the Nix file location, not the flake root.

### Challenge 2: Shell Sourcing Issues
**Problem:** Functions not loading in new shells
```bash
# This doesn't work - doesn't source .zshrc
zsh -c "type g"

# This works - sources .zshrc
zsh -i -c "type g"
```

**Solution:** Use `zsh -i` for interactive mode when testing, or open new terminal windows.

### Challenge 3: Existing .zshrc Conflicts
**Problem:** Home Manager couldn't manage `.zshrc` because existing file was in the way
```
Existing file '/Users/chan/.zshrc' is in the way of '/nix/store/.../.zshrc'
```

**Solution:** 
```bash
# Backup existing .zshrc
mv ~/.zshrc ~/.zshrc.backup

# Let Home Manager take over
nix run .#activate
```

### Challenge 4: PATH Preservation
**Problem:** Need to preserve existing PATH modifications
**Solution:** Use `sessionVariables` in Nix config:
```nix
sessionVariables = {
  PATH = "$HOME/.nix-profile/bin:$PATH";
};
```

### Challenge 5: Activation Script Complexity
**Problem:** Complex activation scripts with heredoc syntax
```nix
# This failed due to $VERBOSE_ARG conflicts
createFunctionsFile = lib.hm.dag.entryAfter ["createZshConfigDir"] ''
  $DRY_RUN_CMD cat > $VERBOSE_ARG "$HOME/.config/zsh/functions.zsh" << 'EOF'
  # Functions...
EOF
'';
```

**Solution:** Use `home.file.source` instead of activation scripts for file management.

## Testing Your Setup

### Verify File Creation
```bash
# Delete existing files
rm -rf ~/.config/zsh

# Activate configuration
nix run .#activate

# Check files were recreated
ls -la ~/.config/zsh/
```

### Test Function Availability
```bash
# Test in new interactive shell
zsh -i -c "type g && type mkcd"
```

### Verify Sourcing
```bash
# Check that functions load from correct files
zsh -i -c "type g"
# Should show: g is a shell function from /Users/chan/.config/zsh/git.zsh
```

## Best Practices

### 1. Organize by Purpose
- Keep Nix modules in `modules/`
- Keep actual dotfiles in `dotfiles/`
- Use descriptive subdirectories (`zsh/`, `vim/`, `git/`)

### 2. Use Source for Editable Files
```nix
# For files you want to edit directly
home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;

# For generated files
home.file.".config/zsh/config.zsh".text = ''
  # Generated content
'';
```

### 3. Test Thoroughly
- Always test after configuration changes
- Use `zsh -i -c` for proper shell testing
- Verify file recreation after deletion

### 4. Version Control Everything
- Commit both Nix config and dotfiles
- Use descriptive commit messages
- Keep dotfiles in sync with Nix config

## Extending the Setup

### Adding New Function Categories
1. Create new file: `dotfiles/zsh/docker.zsh`
2. Add to `modules/shell.nix`:
```nix
home.file.".config/zsh/docker.zsh".source = ../dotfiles/zsh/docker.zsh;
```

### Adding Other Dotfile Types
```nix
# Vim configuration
home.file.".vimrc".source = ../dotfiles/vim/vimrc;

# Git configuration
home.file.".gitconfig".source = ../dotfiles/git/gitconfig;
```

## Troubleshooting

### Functions Not Loading
1. Check file exists: `ls -la ~/.config/zsh/`
2. Verify sourcing: `grep -n "source.*zsh" ~/.zshrc`
3. Test manually: `source ~/.config/zsh/git.zsh && type g`

### File Not Recreated
1. Check source path in Nix config
2. Verify file exists in repo
3. Run activation: `nix run .#activate`

### Permission Issues
1. Check file ownership: `ls -la ~/.config/zsh/`
2. Verify symlinks point to Nix store
3. Check Home Manager generation

## Key Takeaways

1. **Choose the Right Approach**: Source files for editable content, text for generated content
2. **Organize Logically**: Separate Nix config from actual dotfiles
3. **Test Thoroughly**: Always verify file recreation and function loading
4. **Keep It Simple**: Avoid complex activation scripts when simpler solutions exist
5. **Version Control**: Track both configuration and dotfiles together

## Reflection Questions

- How does this approach compare to traditional dotfile management?
- What advantages do you see in having dotfiles version controlled with Nix config?
- How might this scale to managing other types of configuration files?
- What challenges do you anticipate when adding more complex shell functions?

This approach provides a clean, maintainable way to manage dotfiles while maintaining the reproducibility benefits of Nix!
