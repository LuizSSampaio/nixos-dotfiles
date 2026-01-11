{ config, pkgs, ... }:

{
  imports = [ ./greetd.nix ./nvidia.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  environment.systemPackages = with pkgs; [ neovim ];

  nixpkgs.config.allowUnfree = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  console.keyMap = "us-acentos";

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
