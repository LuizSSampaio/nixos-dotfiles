(define-module (conf homes luiz)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages file)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages text-editors)
  #:use-module (conf homes)
  #:export (%luiz-home-environment))

;; ---------------------------------------------------------------------------
;; Home packages
;; ---------------------------------------------------------------------------
(define %home-packages
  (append
   (list
    ;; Version control
    git

    ;; Shell
    zsh

    ;; CLI utilities
    curl
    wget
    file
    unzip
    zip)
   %conf-home-packages))

;; ---------------------------------------------------------------------------
;; Zsh configuration
;;
;; Uses XDG-flavoured paths so Zsh reads its config from
;; $XDG_CONFIG_HOME/zsh/.zshrc rather than ~/.zshrc.
;; ---------------------------------------------------------------------------
(define %home-zsh-config
  (home-zsh-configuration
   ;; Store zsh config under $XDG_CONFIG_HOME/zsh.
   (xdg-flavor? #t)

   (zshrc
    (list
     (plain-file "zshrc"
                 "\
# --- History ---
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# --- Completion ---
autoload -Uz compinit && compinit

# --- Prompt (minimal) ---
autoload -Uz promptinit && promptinit
prompt walters
")))))

;; ---------------------------------------------------------------------------
;; Home services
;; ---------------------------------------------------------------------------
(define %home-services
  (list
   ;; Zsh is the user's login shell; configure it here.
   (service home-zsh-service-type %home-zsh-config)

   ;; Persist common environment variables across all sessions.
   (service home-environment-variables-service-type
            '(;; Prefer XDG locations for tools that support it.
              ("EDITOR"  . "vi")
              ("VISUAL"  . "vi")
              ;; Coloured output for common tools.
              ("CLICOLOR" . "1")))))

;; ---------------------------------------------------------------------------
;; Home environment declaration
;; ---------------------------------------------------------------------------
(define-public %luiz-home-environment
  (home-environment
   (inherit %conf-initial-home)
   (packages %home-packages)
   (services
    (append
     %home-services
     ;; Keep the XDG base-directory service declared in the base skeleton.
     (home-environment-services %conf-initial-home)))))

;; Allow this file to be passed directly to `guix home reconfigure`.
%luiz-home-environment
