{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.emacs;
in {
  options.modules.emacs = { enable = mkEnableOption "emacs"; };

  imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      doomDir = "./doom.d";
    };

    services.emacs.enable = true;
  };
}
