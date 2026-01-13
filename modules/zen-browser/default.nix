{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.zen-browser;
in {
  options.modules.zen-browser = { enable = mkEnableOption "zen-browser"; };

  imports = [ inputs.zen-browser.homeModules.beta ];

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;

      profiles.managed = {
        id = 0;
        isDefault = true;
        name = "Managed by Nix";

        settings = { "extensions.autoDisableScopes" = 0; };

        extensions.packages =
          with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            clearurls
            sponsorblock
            darkreader
            # onepassword-password-manager
            privacy-badger
            return-youtube-dislikes
            # tweaks-for-youtube
            youtube-no-translation
            # languagetool
          ];
      };
    };
  };
}
