{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.nvim;
in {
  options.modules.nvim = {
    enable = mkEnableOption "nvim";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      settings.vim = {
        options = {
          shiftwidth = 2;
          tabstop = 2;
          scrolloff = 5;
        };

        keymaps = [
          {
            key = "<leader>e";
            mode = "n";
            action = "<Cmd>Neotree toggle<CR>";
            silent = true;
            desc = "File Tree [Neotree]";
          }
          {
            key = "<leader>bd";
            mode = "n";
            action = "<Cmd>Bdelet<CR>";
            silent = true;
            desc = "Close buffer";
          }
          {
            key = "H";
            mode = "n";
            action = "<Cmd>BufferLineCyclePrev<CR>";
            silent = true;
            desc = "Previous buffer";
          }
          {
            key = "L";
            mode = "n";
            action = "<Cmd>BufferLineCycleNext<CR>";
            silent = true;
            desc = "Next buffer";
          }
        ];

        spellcheck = {
          enable = true;
          programmingWordlist.enable = true;
        };

        lsp = {
          enable = true;

          formatOnSave = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
          harper-ls.enable = true;
        };

        diagnostics = {
          enable = true;
          config = {
            signs = true;
            update_in_insert = true;
            virtual_text = true;
          };
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        languages = {
          enableDAP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          markdown.enable = true;
          bash.enable = true;
          clang.enable = true;
          json.enable = true;
          lua.enable = true;
          zig.enable = true;
          typst.enable = true;
          ts.enable = true;
          just.enable = true;
          java.enable = true;
          qml.enable = true;
          rust = {
            enable = true;
            extensions.crates-nvim.enable = true;
          };
          toml.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          indent-blankline = {
            enable = true;
            setupOpts = {
              scope.enabled = true;
              indent.char = "│";
            };
          };
        };

        statusline.lualine = {
          enable = true;
          componentSeparator = {
            left = "";
            right = "";
          };
          sectionSeparator = {
            left = "";
            right = "";
          };
        };

        theme.enable = true;

        autopairs.nvim-autopairs.enable = true;

        autocomplete.blink-cmp.enable = true;

        snippets.luasnip.enable = true;

        filetree = {
          neo-tree = {
            enable = true;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
          neogit.enable = false;
        };

        dashboard = {
          alpha.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        projects = {
          project-nvim.enable = true;
        };

        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };

        utility = {
          ccc.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim = {
            enable = true;
            setupOpts.ring.storage = "sqlite";
          };
          icon-picker.enable = true;
          surround.enable = true;
          multicursors.enable = true;
          smart-splits.enable = true;
          undotree.enable = true;
          # Issues with treesitter
          # nvim-biscuits.enable = true;
          direnv.enable = true;

          preview.glow.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
        };

        notes = {
          mind-nvim.enable = true;
          todo-comments.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
          };
          fastaction.enable = true;
        };

        assistant = {
          chatgpt.enable = false;
          copilot = {
            enable = true;
            cmp.enable = false;
          };
          codecompanion-nvim.enable = true;
          avante-nvim = {
            enable = false;
            setupOpts = {
              provider = "copilot";
            };
          };
        };

        comments = {
          comment-nvim.enable = true;
        };
      };
    };
  };
}
