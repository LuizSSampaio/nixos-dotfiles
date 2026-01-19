{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.zed-editor;
in {
  options.modules.zed-editor = { enable = mkEnableOption "zed-edirtor"; };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [ "java" "lua" "zig" "nix" "neocmake" "make" "typst" "mcp-server-context7" "mcp-server-github" "charmed-icons"];
      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };

        scrollbar = {
          show = "never";
        };

        tab_bar = {
          show = false;
        };

        status_bar = {
          experimental.show = false;
        };

        base_keymap = "VSCode";
        vim_mode = true;
        vim.enable_vim_sneak = true;

        relative_line_numbers = true;

        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };

        inlay_hints.enabled = true;

        load_direnv = "shell_hook";
      };
    };
  };
}
