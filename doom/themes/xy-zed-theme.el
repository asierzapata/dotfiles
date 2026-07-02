;;; xy-zed-theme.el --- port of the Zed "XY-Zed" theme -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; A Doom-themes port of Daniel Zarifpour's "XY-Zed" theme for Zed.
;; Colors lifted verbatim from the upstream xy-zed.json. Requires doom-themes.
;;
;;; Code:

(require 'doom-themes)

(def-doom-theme xy-zed
  "A dark theme ported from the Zed \"XY-Zed\" theme."

  ;; name        default   256       16
  ((bg         '("#121212" "#121212" "black"       ))  ; editor.background (primary)
   (bg-alt     '("#1b1b1b" "#1b1b1b" "black"       ))  ; surface/panel (secondary)
   (base0      '("#0a0a0a" "#0a0a0a" "black"       ))  ; status/title bar (tertiary)
   (base1      '("#121212" "#121212" "brightblack" ))
   (base2      '("#1b1b1b" "#1b1b1b" "brightblack" ))
   (base3      '("#262933" "#262933" "brightblack" ))
   (base4      '("#3b3b3b" "#3b3b3b" "brightblack" ))  ; editor.line_number
   (base5      '("#6b6b73" "#6b6b73" "brightblack" ))  ; placeholder/disabled
   (base6      '("#87858c" "#87858c" "white"       ))
   (base7      '("#aca8ae" "#aca8ae" "white"       ))  ; text.muted
   (base8      '("#f7f7f8" "#f7f7f8" "brightwhite" ))
   (fg         '("#f7f7f8" "#f7f7f8" "brightwhite" ))  ; editor.foreground
   (fg-alt     '("#aca8ae" "#aca8ae" "white"       ))

   (grey       base4)
   (red        '("#FF5858" "#FF5858" "red"         ))  ; syntax constant / punctuation
   (orange     '("#CD9069" "#CD9069" "brightred"   ))  ; syntax string
   (green      '("#96df71" "#96df71" "green"       ))  ; created / success
   (teal       '("#7de486" "#7de486" "brightgreen" ))  ; accent green
   (yellow     '("#DCDCAA" "#DCDCAA" "yellow"      ))  ; syntax function
   (blue       '("#4cc2fb" "#4cc2fb" "brightblue"  ))  ; syntax variable
   (dark-blue  '("#4788CC" "#4788CC" "blue"        ))  ; attribute / embedded
   (magenta    '("#c678dd" "#c678dd" "magenta"     ))  ; syntax keyword
   (violet     '("#b477cf" "#b477cf" "brightmagenta"))
   (cyan       '("#08e7c5" "#08e7c5" "brightcyan"  ))  ; syntax type
   (dark-cyan  '("#10a793" "#10a793" "cyan"        ))  ; info

   ;; face categories -- required
   (highlight      teal)
   (vertical-bar   (doom-darken base1 0.1))
   (selection      '("#325135" "#325135" "green"))  ; opaque render of accent selection
   (builtin        magenta)
   (comments       '("#6A9955" "#6A9955" "green"))     ; syntax comment
   (doc-comments   '("#6A9955" "#6A9955" "green"))
   (constants      red)
   (functions      yellow)
   (keywords       magenta)
   (methods        yellow)
   (operators      '("#FFFF00" "#FFFF00" "yellow"))    ; syntax operator
   (type           cyan)
   (strings        orange)
   (variables      blue)
   (numbers        '("#B4CDA8" "#B4CDA8" "green"))     ; syntax number
   (region         '("#2c3a2c" "#2c3a2c" "green"))     ; opaque render of accent selection
   (error          '("#f82871" "#f82871" "red"))
   (warning        '("#fee56c" "#fee56c" "yellow"))
   (success        green)
   (vc-modified    '("#fee56c" "#fee56c" "yellow"))
   (vc-added       green)
   (vc-deleted     '("#f82871" "#f82871" "red"))

   ;; custom categories
   (hidden     base0)
   (-modeline-bright nil)
   (-modeline-pad 4)

   (modeline-fg     fg)
   (modeline-fg-alt base5)
   (modeline-bg     base0)
   (modeline-bg-alt base0)
   (modeline-bg-inactive     (doom-darken bg 0.1))
   (modeline-bg-inactive-alt (doom-darken bg 0.1)))

  ;;;; Base theme face overrides
  (((line-number &override) :foreground base4)
   ((line-number-current-line &override) :foreground teal :weight 'bold)
   ((hl-line &override) :background (doom-blend teal bg 0.06))
   (font-lock-comment-face
    :foreground comments
    :slant 'italic)
   (font-lock-doc-face :foreground doc-comments :slant 'italic)
   ((font-lock-type-face &override) :foreground type)
   ((font-lock-builtin-face &override) :foreground magenta)
   ;; property access (baby blue in XY-Zed)
   ((font-lock-property-use-face &override) :foreground "#9cdcfe")
   ((font-lock-property-name-face &override) :foreground "#9cdcfe")
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (when -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (when -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))

   ;;;; doom-modeline
   (doom-modeline-bar :background teal)
   (doom-modeline-project-dir :foreground teal :weight 'bold)
   (doom-modeline-buffer-modified :foreground warning)

   ;;;; magit
   (magit-diff-hunk-heading-highlight :foreground bg :background teal)

   ;;;; tree-sitter (if faces present)
   (tree-sitter-hl-face:function :foreground yellow)
   (tree-sitter-hl-face:variable :foreground blue :weight 'bold)
   (tree-sitter-hl-face:property :foreground "#9cdcfe")
   (tree-sitter-hl-face:type :foreground cyan)
   (tree-sitter-hl-face:tag :foreground "#7ce184")
   (tree-sitter-hl-face:constant :foreground red :weight 'semi-bold)
   (tree-sitter-hl-face:string :foreground orange)
   (tree-sitter-hl-face:keyword :foreground magenta)
   (tree-sitter-hl-face:operator :foreground operators)))

;;; xy-zed-theme.el ends here
