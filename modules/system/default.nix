{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./fonts.nix
    ./greetd.nix
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "2:00";
  };

  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "luiz" ];

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
}
