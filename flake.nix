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
        python = pkgs.python311;
        python-pkgs = pkgs.python311Packages;
        postgresql = pkgs.postgresql_16;
        postgresql-pkgs = pkgs.postgresql16Packages;
        name = "ami-lambda";
        version = "0.1.0";
        revision = "${self.lastModifiedDate}-${self.shortRev or "dirty"}";
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            awscli2
            bashInteractive
            cacert
            gawk
            gnumake
            postgresql
            python
            python-pkgs.asyncpg
            python-pkgs.boto3
            python-pkgs.environs
            python-pkgs.openai
            python-pkgs.passlib
            python-pkgs.pydantic
            python-pkgs.pydantic-core
            python-pkgs.setuptools
            sqitchPg
            terraform
          ];
          shellHook = ''
            export LANG=en_US.UTF-8
            export SHELL=$BASH
            export PYTHONPATH=$(pwd)/src:$PYTHONPATH
            export PS1="ami-aws|$PS1"
          '';
        };
      }
    );
}
