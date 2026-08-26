(setq doom-theme 'doom-gruvbox)
(setq display-line-numbers-type 'relative)


(setq org-directory "~/org/")

(use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :hook ((typst-ts-mode . lsp-deferred))  ;; start LSP automatically
  :config
  ;; Optional: use typst watch for super fast previews
  ;; `typst-ts-watch-mode` and `typst-ts-preview` are provided by typst-ts-mode.
  (setq typst-ts-mode-watch-options "--open"))  ;; e.g. `typst watch --open` [optional]

;; Register Typst grammar and install it if missing
(with-eval-after-load 'treesit
  (add-to-list 'treesit-language-source-alist
               '(typst "https://github.com/uben0/tree-sitter-typst"))

  ;; Install automatically if the shared library is not present
  (unless (treesit-language-available-p 'typst)
    (message "Installing tree-sitter grammar for Typst...")
    (treesit-install-language-grammar 'typst)))


(use-package! typst-preview
  :after (typst-ts-mode websocket)
  :config
  ;; Use default browser; change to "xwidget" if you want an Emacs xwidget preview.
  (setq typst-preview-browser "default")
  ;; Example keybinding inside typst-preview-mode
  (map! :map typst-preview-mode-map
        "C-c C-j" #'typst-preview-send-position))

(after! lsp-mode
  ;; Tell lsp-mode how to treat typst-ts-mode
  (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))

  ;; Choose ONE of these backends by setting this variable
  (defvar my/typst-lsp-executable "tinymist"
    "Typst LSP executable: e.g. \"tinymist\" or \"typst-lsp\".")

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection (lambda () (list my/typst-lsp-executable)))
    :activation-fn (lsp-activate-on "typst")
    :server-id 'typst-lsp)))

(after! typst-ts-mode
  (map! :map typst-ts-mode-map
        :localleader
        "w" #'typst-ts-watch-mode   ;; start/stop typst watch
        "p" #'typst-ts-preview      ;; open preview from typst watch
        "P" #'typst-preview-mode))  ;; start typst-preview live preview

(after! eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode)
                 . ("clangd"
                    "--query-driver=/nix/store/**,/run/current-system/sw/bin/**,/run/wrappers/bin/**"
                    "--header-insertion-decorators=0"
                    "--clang-tidy"))))

(after! file-templates
  (set-file-template! "\\.h\\'"
    :mode '(c-mode c++-mode)
    :template "#pragma once\n\n")

  (set-file-template! "\\.hpp\\'"
    :mode 'c++-mode
    :template "#pragma once\n\n"))

(use-package! meson-mode
  :mode (("/meson\\.build\\'" . meson-mode)
         ("/meson_options\\.txt\\'" . meson-mode)))

(after! eglot
  (add-to-list 'eglot-server-programs
               '(meson-mode . ("mesonlsp" "--lsp"))))

(use-package! slang-ts-mode
  :mode (("\\.slang\\'"  . slang-ts-mode)
         ("\\.sl\\'"     . slang-ts-mode)
         ("\\.slangh\\'" . slang-ts-mode))
  :hook (slang-ts-mode . eglot-ensure)  ;; start LSP automatically (slangd)
  :config
  ;; Disable Doom's format-on-save for Slang buffers only.
  ;; Adds the major mode to `+format-on-save-disabled-modes', which Doom's
  ;; `+format-maybe-inhibit-h' consults via `apheleia-inhibit-functions'.
  (add-to-list '+format-on-save-disabled-modes 'slang-ts-mode)
  ;; slang-ts-mode's top-level `add-to-list' installs an entry of the form
  ;;   (slang URL :commit HASH)
  ;; which is invalid on Emacs 30.x: `treesit-language-source-alist' expects a
  ;; positional list `(URL REVISION SOURCE-DIR CC C++)' and `:commit' is not a
  ;; recognized key (it only exists on Emacs 31.1+). On 30.2 it reaches
  ;; `git clone -b :commit ...', which fails with
  ;; `(wrong-type-argument stringp :commit)' and aborts the grammar lookup.
  ;; The Slang grammar ships a `parser.c' in `src', so override the entry with
  ;; the correct positional form. With the Nix-provided grammar in
  ;; `extraPackages', `treesit-ensure-installed' short-circuits before reaching
  ;; this path, but keeping it sane guards against Emacs upgrades or stale deps.
  (setf (alist-get 'slang treesit-language-source-alist)
        (list "https://github.com/tree-sitter-grammars/tree-sitter-slang"
              "1dbcc4abc7b3cdd663eb03d93031167d6ed19f56"
              "src"))
  ;; Register slangd with eglot for slang-ts-mode buffers. slangd is expected
  ;; to be on PATH (e.g. provided per-project via direnv + envrc-mode).
  (after! eglot
    (add-to-list 'eglot-server-programs
                 '((slang-ts-mode) . ("slangd")))))

(use-package wakatime-mode
  :ensure t
  :config
  (global-wakatime-mode 1))
