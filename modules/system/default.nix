{ config, pkgs, ... }:

{
  imports = [ ./greetd.nix ./nvidia.nix ./steam.nix ./plymouth.nix ];

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  services.flatpak.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  environment.pathsToLink =
    [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "2:00";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    config = { hyprland = { default = [ "hyprland" "gtk" ]; }; };
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
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.resolved.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  networking = {
    wireless.iwd.enable = true;
    firewall.enable = true;
  };

  system.stateVersion = "25.11";
}
