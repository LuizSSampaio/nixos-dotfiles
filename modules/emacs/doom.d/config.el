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
