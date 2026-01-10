{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.modules.walker;
in {
  options.modules.walker = {
    enable = mkEnableOption "walker launcher";
  };

  imports = [ inputs.walker.homeManagerModules.default ];

  config = mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;

      # Configuration options
      config = {
        theme = "default";
        placeholders.default = {
          input = "Search";
          list = "No Results";
        };
        providers.prefixes = [
          { provider = "websearch"; prefix = "+"; }
          { provider = "providerlist"; prefix = "_"; }
        ];
        keybinds.quick_activate = ["F1" "F2" "F3"];
      };

      # Custom theme
      themes = {
        "my-theme" = {
          style = ''
            /* Your CSS here */
          '';
          layouts = {
            "layout" = ''<!-- Your XML layout -->'';
          };
        };
      };
    };
  };
}
