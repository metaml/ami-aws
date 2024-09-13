#!/usr/bin/env sh

mv -f /etc/nixos/configuration.nix /etc/nixos/configuration.nix-

cat > /etc/nixos/configuration.nix <<EOF
{ modulesPath, pkgs, ... }: {
  imports = [ "\${modulesPath}/virtualisation/amazon-image.nix" ];
  nix.extraOptions = "trusted-users = root";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 8000 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };
  nixpkgs.config = {
    allowUnfree = true; # Allow "unfree" packages.
    # firefox.enableAdobeFlash = true;
    # chromium.enablePepperFlash = true;
  };
  system.stateVersion = "24.05";
  documentation.doc.enable = false;

  environment.variables = { AWS_DEFAULT_REGION = "us-east-2"; };
  environment.systemPackages = with pkgs; [
    git
    awscli2
    bashInteractive
    coreutils
    dateutils
    dig
    docker
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

  # this works
  # users.users.root.packages = [
  #   pkgs.python311
  #   pkgs.python311Packages.asyncpg
  #   pkgs.python311Packages.boto3
  #   pkgs.python311Packages.environs
  #   pkgs.python311Packages.fastapi
  #   pkgs.python311Packages.gradio
  #   #pkgs.python311Packages.jinja2
  #   pkgs.python311Packages.openai
  #   pkgs.python311Packages.passlib
  #   pkgs.python311Packages.pydantic-core
  #   pkgs.python311Packages.pyjwt
  #   pkgs.python311Packages.uvicorn
  # ];

  systemd.services.dockerd = {
    enable = true;
    wantedBy      = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart  = "\${pkgs.docker}/bin/dockerd";
      Restart    = "always";
      RestartSec = 1;
    };
    description   = "dockerd";
  };

  systemd.services."ami-rest" = {
    description = "ami rest service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      KillMode = "mixed";
      Restart = "always";

      ExecStartPre = "[ -d /static ] || cd / \
&& aws s3 \
cp s3://ami-recomune-us-east2/static.tar.gz && \
tar xzf static.tar.gz";

      ExecStart = "docker run \
--env AWS_DEFAULT_REGIONS=us-east-2 \
--read-only \
--volume /static:/static \
--workdir / \
--publish 8000:8000 \
 975050288432.dkr.ecr.us-east-2.amazonaws.com/ami-rest";
    };
  };
}
EOF

nixos-rebuild switch
nix-channel --update
nix-collect-garbage --delete-old
