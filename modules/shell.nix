{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    
    # Enable useful features
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    # History and sourcing logic moved to dotfiles
    # sessionVariables kept for Nix-specific PATH
    sessionVariables = {
      PATH = "$HOME/.nix-profile/bin:$PATH";
    };

    # Source all zsh dotfiles via bootstrap.zsh
    initExtra = ''
      source ~/.config/zsh/bootstrap.zsh
    '';
  };

  # Import function files from repo
  home.file.".config/zsh/aliases.zsh".source = ../dotfiles/zsh/aliases.zsh;
  home.file.".config/zsh/bootstrap.zsh".source = ../dotfiles/zsh/bootstrap.zsh;
  home.file.".config/zsh/editor.zsh".source = ../dotfiles/zsh/editor.zsh;
  home.file.".config/zsh/git.zsh".source = ../dotfiles/zsh/git.zsh;
  home.file.".config/zsh/visual.zsh".source = ../dotfiles/zsh/visual.zsh;
} 