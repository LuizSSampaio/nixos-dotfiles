{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.emacs;
in
{
  options.modules.emacs = {
    enable = mkEnableOption "emacs";
  };

  imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ispell
    ];

    programs.doom-emacs = {
      enable = true;
      doomDir = ./doom.d;
    };

    services.emacs.enable = true;
  };
}
