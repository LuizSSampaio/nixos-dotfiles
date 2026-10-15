(setq doom-theme 'doom-gruvbox)
(setq display-line-numbers-type 'relative)


(setq org-directory "~/org/")

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

(require 'acp)
(require 'agent-shell)

(use-package! agent-shell
  :config
  ;; Integrate with Google Antigravity account (login-based authentication)
  (setq agent-shell-antigravity-authentication
        (agent-shell-antigravity-make-authentication :login t))

  ;; Integrate with Google Gemini CLI (login-based authentication)
  (setq agent-shell-google-authentication
        (agent-shell-google-make-authentication :login t))

  ;; Evil state-specific RET behavior: insert mode = newline, normal mode = send
  (after! evil
    (evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
    (evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input)

    ;; Configure *agent-shell-diff* buffers to start in Emacs state
    (add-hook 'diff-mode-hook
              (lambda ()
                (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                  (evil-emacs-state)))))

  ;; Convenient Doom leader keybindings under SPC a
  (map! :leader
        (:prefix-map ("a" . "agent-shell")
         :desc "Agent shell (dwim)" "a" #'agent-shell
         :desc "Antigravity agent"  "g" #'agent-shell-antigravity-start-agent
         :desc "Gemini agent"       "m" #'agent-shell-google-start-gemini)))
