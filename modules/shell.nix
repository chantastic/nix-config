{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    # Enable useful features
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    # Source external function files
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
  home.file.".config/zsh/aliases.zsh".source = ../dotfiles/zsh/aliases.zsh;
  home.file.".config/zsh/editor.zsh".source = ../dotfiles/zsh/editor.zsh;
  home.file.".config/zsh/visual.zsh".source = ../dotfiles/zsh/vi.zsh;
} 