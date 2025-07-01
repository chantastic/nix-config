{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python runtime
    python312
    
    # Speech recognition packages can be added here as needed
    
    # Add other Python packages here as needed
  ];

  # Set up Python environment variables
  home.sessionVariables = {
    PYTHONPATH = "$HOME/.local/lib/python3.12/site-packages:$PYTHONPATH";
  };

  # Add Python user bin to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
} 