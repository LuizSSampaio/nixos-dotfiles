{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.opencode;

  secretPath = name: "${config.home.homeDirectory}/.config/sops-nix/secrets/${name}";

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    mcp = {
      context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
        headers.CONTEXT7_API_KEY = "{file:${secretPath "context7_api_key"}}";
        enabled = true;
      };
      github = {
        type = "remote";
        url = "https://api.githubcopilot.com/mcp/";
        headers.Authorization = "Bearer {file:${secretPath "github_mcp_token"}}";
        enabled = true;
      };
      gh_grep = {
        type = "remote";
        url = "https://mcp.grep.app";
      };
    };
  };
in
{
  options.modules.opencode = {
    enable = lib.mkEnableOption "declarative opencode configuration with sops-nix secrets";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.modules.sops.enable;
        message = "modules.opencode requires modules.sops to be enabled";
      }
    ];

    sops.secrets = {
      context7_api_key.sopsFile = ../../secrets/opencode.yaml;
      github_mcp_token.sopsFile = ../../secrets/opencode.yaml;
    };

    xdg.configFile."opencode/opencode.json".source =
      (pkgs.formats.json { }).generate "opencode.json"
        opencodeConfig;
  };
}
