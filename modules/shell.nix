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

  # Configure fzf for better integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    defaultOptions = ["--height 40%" "--border"];
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = ["--preview 'bat --style=numbers --color=always --line-range :500 {}'"];
  };

  # Configure zoxide for smart directory navigation
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Import function files from repo
  home.file.".config/zsh/aliases.zsh".source = ../dotfiles/zsh/aliases.zsh;
  home.file.".config/zsh/bootstrap.zsh".source = ../dotfiles/zsh/bootstrap.zsh;
  home.file.".config/zsh/editor.zsh".source = ../dotfiles/zsh/editor.zsh;
} 