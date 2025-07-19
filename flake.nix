{
  description = "A minimal Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        default = pkgs.home-manager;
        mysides = pkgs.mysides;
        dockutil = pkgs.dockutil;
      };

      apps.${system} = {
        macos-settings = {
          type = "app";
          program = toString (pkgs.writeShellScript "macos-settings" (builtins.readFile ./scripts/macos-settings.sh));
        };
        configure-finder-sidebar = {
          type = "app";
          program = toString (pkgs.writeShellScript "configure-finder-sidebar" (builtins.readFile ./scripts/configure-finder-sidebar.sh));
        };
        configure-dock = {
          type = "app";
          program = toString (pkgs.writeShellScript "configure-dock" (builtins.readFile ./scripts/configure-dock.sh));
        };
        itt-to-srt = {
          type = "app";
          program = toString (pkgs.writeShellScript "itt-to-srt" ''
            exec ${pkgs.python312}/bin/python ${./scripts/itt-to-srt.py} "$@"
          '');
        };
        
        activate = {
          type = "app";
          program = toString (pkgs.writeShellScript "activate" ''
            exec ${pkgs.home-manager}/bin/home-manager switch --flake ${self}#chan
          '');
        };
      };

      homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home = {
              username = "chan";
              homeDirectory = "/Users/chan";
              stateVersion = "23.11";
              packages = with pkgs; [
                mysides
                dockutil
                gh
                fzf
                fd
                bat
                zoxide
                ripgrep
                eza
              ];
            };
          }
          ./modules/git.nix
          ./modules/node.nix
          ./modules/shell.nix
          ./modules/media.nix
          ./modules/python.nix
          ./modules/php.nix
        ];
      };
    };
}