{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

with lib;
let
  cfg = config.modules.emacs;
in
{
  options.modules.emacs = {
    enable = mkEnableOption "emacs";
  };

  imports = [ inputs.nix-doom-emacs-unstraightened.homeModule ];

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ispell
      gcc
    ];

    programs.doom-emacs = {
      enable = true;
      doomDir = ./doom.d;

      # Pre-build the tree-sitter-slang grammar so slang-ts-mode finds
      # `lib/libtree-sitter-slang.so` under the wrapped Emacs'
      # `emacs-packages-deps/lib/` (already on `treesit-extra-load-path`).
      # This avoids relying on `slang-ts-mode`'s built-in `treesit-install-language-grammar`
      # auto-install at first use (which is buggy on Emacs 30.2 due to a
      # malformed `:commit` recipe key) and removes the need for git + a C
      # toolchain at runtime.
      extraPackages = epkgs: [
        (epkgs.treesit-grammars.with-grammars (p: [ p.tree-sitter-slang ]))
      ];
    };

    services.emacs.enable = true;
  };
}
