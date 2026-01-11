{ config, pkgs, ... }:

{
  imports = [ ./fonts.nix ./greetd.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  environment.systemPackages = with pkgs; [ neovim git ];

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
    packages = with pkgs; [ ];
  };

  environment.pathsToLink =
    [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "2:00";
  };

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

  networking = {
    wireless.iwd.enable = true;
    firewall.enable = true;
  };

  system.stateVersion = "25.11";
}
