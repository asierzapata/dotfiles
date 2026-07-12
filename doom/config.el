;;; config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Asier Zapata"
      user-mail-address "asier.zapata@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; Monaspace (Neon), matching my Zed buffer font. The "Mono" nerd-font variant
;; keeps glyphs monospaced; the "Propo" variant is used for prose/UI.
(setq doom-font (font-spec :family "MonaspiceNe Nerd Font Mono" :size 18)
      doom-variable-pitch-font (font-spec :family "MonaspiceNe Nerd Font Propo" :size 18))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; Make my custom themes in ./themes/ loadable (xy-zed lives there).
(add-to-list 'custom-theme-load-path (expand-file-name "themes/" doom-user-dir))
;; Trust my own themes so `load-theme'/auto-dark don't reject them via the
;; `custom-safe-themes' prompt (Doom only auto-trusts its bundled themes).
(setq custom-safe-themes t)

;; Themes follow the macOS system appearance, mirroring my Zed setup:
;;   light -> doom-one-light  (Zed's "One Light")
;;   dark  -> xy-zed          (my port of Zed's "XY-Zed")
;; `doom-theme' is the fallback used before auto-dark kicks in.
(setq doom-theme 'xy-zed)

(use-package! auto-dark
  :config
  ;; `auto-dark-themes' is (DARK-THEMES LIGHT-THEMES); first of each wins.
  (setq auto-dark-themes '((xy-zed) (doom-one-light)))
  (auto-dark-mode 1))

;; Relative line numbers, matching my Zed `relative_line_numbers: enabled`.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;;
;; Editor behaviour mirrored from my Zed config
;;

;; `autosave: "on_focus_change"' in Zed -> save file-visiting buffers on idle
;; and whenever focus leaves the current buffer.
(defun +my/save-buffer-if-file ()
  "Save the current buffer if it is visiting a real file and is modified."
  (when (and buffer-file-name (buffer-modified-p))
    (save-buffer)))
(setq auto-save-visited-interval 1)
(auto-save-visited-mode +1)
(add-hook 'doom-switch-buffer-hook #'+my/save-buffer-if-file)

;; `source.fixAll.eslint' on save in Zed -> apply ESLint autofixes before the
;; prettier/rustfmt formatter (`format +onsave') runs. Needs the ESLint LSP
;; server, which lsp-mode fetches automatically on first use.
(after! lsp-mode
  (defun +my/eslint-fix-on-save-h ()
    (when (bound-and-true-p lsp-mode)
      (add-hook 'before-save-hook #'lsp-eslint-fix-all -10 t)))
  (dolist (hook '(js-mode-hook
                  js2-mode-hook
                  typescript-mode-hook
                  typescript-tsx-mode-hook
                  tsx-ts-mode-hook
                  typescript-ts-mode-hook
                  web-mode-hook
                  rjsx-mode-hook))
    (add-hook hook #'+my/eslint-fix-on-save-h)))
