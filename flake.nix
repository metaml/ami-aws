{
  description = "Terraform Cloud AWS";

  inputs = {
    nixpkgs.url        = "github:nixos/nixpkgs";
    flake-utils.url    = "github:numtide/flake-utils";
    flake-compat.url   = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312;
        python-pkgs = pkgs.python312Packages
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            awscli2
            gawk
            gnumake
            terraform
          ];
          shellHook = ''
            export SHELL=$BASH
            export LANG=en_US.UTF-8
            export PS1="aip-aws|$PS1"
          '';
        };
      }
    );
}
