{
  description = "A minimal Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.runCommand "empty" {} "echo 'Doing nothing' > $out";

      homeConfigurations.chan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {
            home = {
              username = "chan";
              homeDirectory = "/Users/chan";
              stateVersion = "23.11";
            };
            
            home.packages = with pkgs; [
              git
            ];

            programs.git = {
              enable = true;
              
              userName = "Michael Chan";
              userEmail = "mijoch@gmail.com";
              
              extraConfig = {
                core.editor = "nvim";
                credential.helper = "osxkeychain";
                diff = {
                  compactionHeuristic = true;
                  colorMoved = "zebra";
                };
                fetch.prune = true;
                format.pretty = "oneline";
                help.autocorrect = 1;
                init.defaultBranch = "main";
                log = {
                  abbrevCommit = true;
                  date = "relative";
                  decorate = "short";
                  pretty = "oneline";
                };
                pull.rebase = true;
                push = {
                  autoSetupRemote = true;
                  followTags = true;
                  default = "current";
                };
                rebase.autosquash = true;
                ui.color = true;
                "filter \"lfs\"" = {
                  clean = "git-lfs clean -- %f";
                  smudge = "git-lfs smudge -- %f";
                  process = "git-lfs filter-process";
                  required = true;
                };
              };
              
              # Aliases
              aliases = {
                a = "add";
                b = "branch";
                c = "commit";
                d = "diff";
                e = "reset";
                f = "fetch";
                g = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset'";
                h = "cherry-pick";
                i = "init";
                l = "pull";
                m = "merge";
                n = "config";
                o = "checkout";
                p = "push";
                r = "rebase";
                s = "status";
                t = "tag";
                u = "prune";
                w = "switch";
                branches = "for-each-ref --sort=-committerdate --format='\"%(color:blue)%(authordate:relative)\t%(color:red)%(authorname)\t%(color:white)%(color:bold)%(refname:short)\"' refs/remotes";
              };
            };
          }
        ];
      };
    };
}