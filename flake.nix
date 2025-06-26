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
      packages.${system}.default = pkgs.home-manager;

      apps.${system} = {
        macos-settings = {
          type = "app";
          program = toString (pkgs.writeShellScript "macos-settings" (builtins.readFile ./scripts/macos-settings.sh));
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
            };
          }
          ./modules/git.nix
          ./modules/node.nix
        ];
      };
    };
}