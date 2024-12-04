{ modulesPath, pkgs, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
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
  # 1. allow return traffic for outgoing connections initiated by the server itself
  # 2. allow outgoing traffic of all established connections
  networking.firewall.extraStopCommands = ''
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
    iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT        || true
  '';
  nixpkgs.config = {
    allowUnfree = true; # Allow "unfree" packages.
    # firefox.enableAdobeFlash = true;
    # chromium.enablePepperFlash = true;
  };
  system.stateVersion = "24.05";
  documentation.doc.enable = false;

  environment.variables = { AWS_DEFAULT_REGION = "us-east-2"; };
  environment.systemPackages = with pkgs; [
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
    git
    gnugrep
    gnumake
    gnused
    idutils
    inetutils
    jq
    less
    openssl
    python3
    tree
    unzip
    vim
    zip
    zlib.dev
  ];

  systemd.services.dockerd = {
    enable = true;
    wantedBy      = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart  = "${pkgs.docker}/bin/dockerd";
      Restart    = "always";
      RestartSec = 1;
    };
    description   = "dockerd";
  };

  systemd.services."ami" = {
    description = "ami rest service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart    = "/root/.nix-profile/bin/ami.py";
      KillMode     = "mixed";
      Restart      = "always";
      RestartSec   = 8;
      StandardError  = "journal";
      StandardOutput = "journal";
      StandardInput  = "null";
    };
  };
  
  users.users.murtza = {
    isNormalUser  = true;
    home  = "/home/murtza";
    description  = "Shamoun Murtza";
    extraGroups  = [ "wheel" ];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+LM44yKrSyxJnB3+uyamM5IljHimftI/iTdmRP6wrFvmOWfKSYBFaVrt8Xc8ecwk2L0md3xZDk/6X+5m0IiwWjY+SzdpsthvpNASwA7w3jY370xsCixf+vyhkyYSw0Yo5A1ua9hSkCQpY51AdHE7VCq/5YD7C7K03ondY7Ix9eogFwW9cuWzZBKavAFRj3OsZz1DeurrXEWDHnRQOyzhK9FnIDMZ671U1+uchpX8LUHAKKrIcpeh5typOQMZdkU5mPqvo/Z8utqlsCWHe5YYHlUBFQL68mcLA1HUuAHTIX0X7WXTWC9SzggId/bdWZz0m6vJ9wx0iLryqCVghXyjugvRYVRpuf3oACl5bOl2xh65O+mqrPmyFKwODIlrIHM8K4+OyechIZJ0WLVJ4e2PwxUAV+SJI5RrNr2cmeAtTHn+C+MVGU72nNzMw+tyecmYh2dHhXbhde4jkPJJqBZd1e/cWG1eGxS58Dn7VCds36/wRwfk1l234LuUYC7YeEM977VTikXoKUdy5XPy4GSLQxVA651NmC/5WDYg25t4SNadffseVplZ/wR92l8BMMDiZASeElXZR25bJDfwgPOuksSd1CXqN+lhT7WlyPbgdBEttQJVXUOXjrP2UiS3i03Y5NHm87R5m+9YMlD13VCryGngbG+GG7d7bU/yD2zzxFw== murtza@Shamoun-90GB.local"];
  };
}
