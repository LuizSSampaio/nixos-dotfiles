{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.emacs;
in {
  options.modules.emacs = { enable = mkEnableOption "emacs"; };

  imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ./doom.d ];

  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      doomDir = "./modules/emacs/doom.d";
    };

    services.emacs.enable = true;
  };
}
