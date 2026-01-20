{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
  cfg = config.modules.zed-editor;
in
{
  options.modules.zed-editor = {
    enable = mkEnableOption "zed-edirtor";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "java"
        "lua"
        "zig"
        "nix"
        "neocmake"
        "make"
        "typst"
        "mcp-server-context7"
        "mcp-server-github"
        "charmed-icons"
      ];

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
        file_finder = {
          modal_width = "medium";
        };

        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
        };

        inlay_hints.enabled = true;

        auto_install_extensions = true;
        load_direnv = "shell_hook";
      };

      userKeymaps = [
        {
          context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
          bindings = {
            "space t i" = "editor::ToggleInlayHints";

            "space u w" = "editor::ToggleSoftWrap";

            "space m p" = "markdown::OpenPreview";
            "space m P" = "markdown::OpenPreviewToTheSide";

            "space f p" = "projects::OpenRecent";

            "space a a" = "assistant::ToggleFocus";
            "g f" = "editor::OpenExcerpts";
          };
        }
        {
          context = "Editor && vim_mode == normal && !VimWaiting && !menu";
          bindings = {
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";

            "space ." = "editor::ToggleCodeActions";
            "g d" = "editor::GoToDefinition";
            "g D" = "editor::GoToDefinitionSplit";
            "g i" = "editor::GoToImplementation";
            "g I" = "editor::GoToImplementationSplit";
            "g t" = "editor::GoToTypeDefinition";
            "g T" = "editor::GoToTypeDefinitionSplit";
            "g r" = "editor::FindAllReferences";
            "] d" = "editor::GoToDiagnostic";
            "[ d" = "editor::GoToPreviousDiagnostic";

            "] e" = "editor::GoToDiagnostic";
            "[ e" = "editor::GoToPreviousDiagnostic";

            "s s" = "outline::Toggle";
            "s S" = "project_symbols::Toggle";

            "space x x" = "diagnostics::Deploy";

            "space e" = "project_panel::ToggleFocus";
            "ctrl-/" = "workspace::ToggleBottomDock";
            "space p" = "editor::Format";
            "space space" = "file_finder::Toggle";
            "shift-l" = "pane::ActivateNextItem";
            "shift-h" = "pane::ActivatePreviousItem";
            "space v" = "pane::SplitRight";
            "space h" = "workspace::ActivateNextPane";
            "space l" = "workspace::ActivatePreviousPane";
            "space c a" = "editor::ToggleCodeActions";
            "q" = "pane::CloseActiveItem";
            "shift-q" = "pane::CloseInactiveItems";
            "space c r" = "editor::Rename";
          };
        }
        {
          context = "EmptyPane || SharedScreen";
          bindings = {
            "space space" = "file_finder::Toggle";

            "space f p" = "projects::OpenRecent";
          };
        }
        {
          context = "Editor && vim_mode == visual && !VimWaiting && !men";
          bindings = {
            "g c" = "editor::ToggleComments";
          };
        }
        {
          context = "Editor && vim_mode == visual";
          bindings = {
            "shift-j" = "editor::MoveLineDown";
            "shift-k" = "editor::MoveLineUp";
          };
        }
        {
          context = "ProjectPanel && not_editing";
          bindings = {
            "space e" = "workspace::ToggleLeftDock";
            "a" = "project_panel::NewFile";
            "n" = "project_panel::NewFile";
            "shift-n" = "project_panel::NewDirectory";
            "d" = "project_panel::Trash";
            "l" = "project_panel::Open";
            "r" = "project_panel::Rename";
            "x" = "project_panel::Cut";
            "c" = "project_panel::Copy";
            "p" = "project_panel::Paste";
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";
          };
        }
        {
          context = "Dock";
          bindings = {
            "ctrl-w h" = "workspace::ActivatePaneLeft";
            "ctrl-w l" = "workspace::ActivatePaneRight";
            "ctrl-w k" = "workspace::ActivatePaneUp";
            "ctrl-w j" = "workspace::ActivatePaneDown";
          };
        }
        {
          context = "Terminal";
          bindings = {
            "ctrl-/" = "workspace::ToggleBottomDock";
            "ctrl-h" = "workspace::ActivatePaneLeft";
            "ctrl-l" = "workspace::ActivatePaneRight";
            "ctrl-k" = "workspace::ActivatePaneUp";
            "ctrl-j" = "workspace::ActivatePaneDown";
            "ctrl-shift-l" = "pane::ActivateNextItem";
            "ctrl-shift-h" = "pane::ActivatePreviousItem";
          };
        }
      ];
    };
  };
}
