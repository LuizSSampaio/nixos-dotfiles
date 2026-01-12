{ pkgs, lib, config, inputs, ... }:

with lib;
let cfg = config.modules.zen-browser;
in {
  options.modules.zen-browser = { enable = mkEnableOption "zen-browser"; };

  imports = [ inputs.zen-browser.homeModules.beta ];

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;

      profiles."*" = {
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

        search = {
          force = true;
          default = "@kg";
          engines = {
            kagi = {
              name = "Kagi Search";
              urls = {
                template = "https://kagi.com/search?q={searchTerms}";
                params = [{
                  name = "query";
                  value = "searchTerms";
                }];
              };
              icon = "https://kagi.com/favicon.ico";
              definedAliases = [ "@kg" ];
            };
          };
        };
      };
    };
  };
}
