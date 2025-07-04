{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python runtime and package manager
    python312
    python312Packages.pip
  ];

  # Add Python user bin to PATH for pip-installed packages
  # (Python automatically includes ~/.local/lib/python3.12/site-packages in sys.path)
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
} 