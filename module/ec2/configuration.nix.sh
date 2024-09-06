#!/usr/bin/env sh

mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix-

cat > /etc/nixos/configuration.nix <<EOF
{ modulesPath, pkgs, ... }: {
  imports = [ "\${modulesPath}/virtualisation/amazon-image.nix" ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs; [
    git
    awscli2
    bashInteractive
    coreutils
    dateutils
    dig
    emacs
    fetchutils
    findutils
    gawk
    gnugrep
    gnumake
    gnused
    idutils
    inetutils
    jq
    less
    openssl
    tree
    unzip
    vim
    zip
    zlib.dev    
  ];
  system.stateVersion = "24.05";
}
EOF

nixos-rebuild switch
nix-channel --update
nix-collect-garbage --delete-old

