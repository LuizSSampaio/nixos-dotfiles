{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.zen-browser;
in {
  options.modules.zen-browser = {enable = mkEnableOption "zen-browser";};

  imports = [inputs.zen-browser.homeModules.beta];

  config = mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;

      policies = let
        mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
          installation_mode = "force_installed";
        });
      in {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

        ExtensionSettings = mkExtensionSettings {
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password-x-password-manager";
          "languagetool-webextension@languagetool.org" = "languagetool";
          "enhancerforyoutube@maximerf.addons.mozilla.org" = "enhancer-for-youtube";
          "myallychou@gmail.com" = "youtube-recommended-videos";
        };
      };

      profiles.managed = {
        id = 0;
        isDefault = true;
        name = "Managed by Nix";

        spacesForce = true;
        spaces = {
          "Personal" = {
            id = "4d929899-3c7c-44e3-be00-e1e850836b6f";
            icon = "🏠";
            position = 1000;
          };
          "Work" = {
            id = "1aa8cdd7-cf7b-4523-a2aa-20d3f085dfd3";
            icon = "💻";
            position = 2000;
          };
          "Study" = {
            id = "cdd10fab-4fc5-494b-9041-325e5759195b";
            icon = "📕";
            position = 3000;
          };
        };

        pinsForce = true;
        pins = {
          "GitHub" = {
            id = "f6f117f5-8c5d-42f5-b8db-ded620fc2de2";
            url = "https://github.com/LuizSSampaio";
            isEssential = true;
            position = 0;
          };
          "Perplexity" = {
            id = "fbe8aca9-6962-45eb-a099-0e7e18e9f25d";
            url = "https://www.perplexity.ai/";
            isEssential = true;
            position = 1;
          };
        };

        settings = {
          "extensions.autoDisableScopes" = 0;

          "zen.workspaces.continue-where-left-off" = true;
          "zen.view.compact.enable-at-startup" = true;
          "zen.view.compact.hide-tabbar" = true;
          "zen.view.compact.hide-toolbar" = true;
          "zen.view.compact.animate-sidebar" = true;
          "zen.view.experimental-no-window-controls" = true;
          "zen.view.sidebar-expanded" = true;
          "zen.view.use-single-toolbar" = true;
          "zen.urlbar.behavior" = "float";
          "zen.urlbar.replace-newtab" = true;
          "zen.welcome-screen.seen" = true;
        };

        extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
          kagi-search
          ublock-origin
          clearurls
          sponsorblock
          darkreader
          privacy-badger
          return-youtube-dislikes
          youtube-no-translation
        ];
      };
    };
  };
}
