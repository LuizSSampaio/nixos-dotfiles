{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./greetd.nix
    ./nvidia.nix
    ./steam.nix
    ./plymouth.nix
  ];

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "intl";
    };

    flatpak.enable = true;
    gvfs.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    power-profiles-daemon.enable = true;
    resolved.enable = true;
    tailscale.enable = true;
  };

  console.keyMap = "us-acentos";

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  users.users.luiz = {
    isNormalUser = true;
    description = "Luiz Henrique Silva Sampaio";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "2:00";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
      };
    };
  };

  programs.dconf.enable = true;
  programs.zsh.enable = true;

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  networking = {
    wireless.iwd.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [53317];
      allowedUDPPorts = [53317 config.services.tailscale.port];
    };
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  system.stateVersion = "25.11";
}
