{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.starship;
in {
  options.modules.starship = { enable = mkEnableOption "starship"; };

  config = mkIf cfg.enable { programs.starship = { enable = true; }; };
}
