{ config, lib, pkgs, ... }:

let
  # Define your custom fonts here
  customFonts = with pkgs; [
    # Add your custom font packages here
    # Example: jetbrains-mono
    # Example: fira-code
    # Example: source-code-pro
  ];

  # For system-wide fonts (requires sudo)
  systemFonts = with pkgs; [
    # Add system fonts here
    # Example: noto-fonts
    # Example: liberation-fonts
  ];

in {
  # User-specific fonts (installed to ~/.nix-profile/share/fonts)
  home.packages = customFonts;

  # System-wide fonts (requires sudo nixos-rebuild)
  # Uncomment if you want system fonts
  # fonts.fonts = systemFonts;

  # Font configuration for applications
  fonts.fontconfig = {
    enable = true;
    # Enable subpixel rendering for better font rendering
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
    # Enable antialiasing
    antialias = true;
    # Enable hinting
    hinting = {
      enable = true;
      style = "slight";
    };
  };
} 