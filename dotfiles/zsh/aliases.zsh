# =============================================================================
# NAVIGATION ALIASES
# =============================================================================
alias ..="cd .."

# =============================================================================
# NIX CONFIG COMMANDS
# =============================================================================
alias nix-activate="nix run ~/nix-config#activate"
alias nix-macos-settings="nix run ~/nix-config#macos-settings"
alias nix-configure-dock="nix run ~/nix-config#configure-dock"
alias nix-configure-finder="nix run ~/nix-config#configure-finder-sidebar"
alias itt-to-srt="nix run ~/nix-config#itt-to-srt"

# =============================================================================
# FILE MANAGEMENT FUNCTIONS
# =============================================================================

# Modern ls with fallback
ls() {
    if command -v eza >/dev/null 2>&1; then
        eza "$@"
    else
        command ls "$@"
    fi
}

# Tree view with additional options
lt() {
    if command -v eza >/dev/null 2>&1; then
        eza --tree "$@"
    else
        echo "Tree view requires eza to be installed"
        return 1
    fi
}

# =============================================================================
# FUZZY FINDER FUNCTIONS
# =============================================================================

# Fuzzy finder function alias
ff() {
    fzf "$@"
}

# =============================================================================
# NODE PACKAGE MANAGEMENT FUNCTIONS
# =============================================================================

# Node package manager wrapper
# determine package manager and run command with it
p() {
  if [[ -f bun.lockb ]]; then
    command bun "$@"
  elif [[ -f pnpm-lock.yaml ]]; then
    command pnpm "$@"
  elif [[ -f yarn.lock ]]; then
    command yarn "$@"
  elif [[ -f package-lock.json ]]; then
    command npm "$@"
  else
    command pnpm "$@"
  fi
}

# =============================================================================
# GIT FUNCTIONS
# =============================================================================

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
compdef g=git

# =============================================================================
# EDITOR FUNCTIONS
# =============================================================================

# Override $VISUAL with most modern installed program
if command -v nvim >/dev/null 2>&1; then
  export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
  export VISUAL="vim"
else
  export VISUAL="vi"
fi 

# Override vi with the most modern installed program
vi() {
  if [[ -z "$VISUAL" ]]; then
    echo "Error: $VISUAL is not set" >&2
    return 1
  fi
  "$VISUAL" "$@"
}

compdef _command vi