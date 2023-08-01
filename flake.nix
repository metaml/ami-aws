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

        pkg-name = "aws";
        aws = pkgs.runCommand
          "aws"
          { preferLocalBuild = true; buildInputs = [ pkg-name ]; }
          '''';

        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";
      in {
        defaultPackage = self.packages.${system}.${pkg-name};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            awscli2
            gnumake
            terraform
          ];
          shellHook = ''
            export SHELL=/run/current-system/sw/bin/bash
            export LANG=en_US.UTF-8
            export PS1="aws|$PS1"
          '';
        };
      });
}
