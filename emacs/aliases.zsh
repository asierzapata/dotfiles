# Emacs daemon + client.
# The daemon loads Doom once and stays resident; clients attach instantly.
# `-a ""` auto-starts a daemon if none is running, so these never fail.

alias e='emacsclient -c -n -a ""'      # open a GUI frame (returns immediately)
alias et='emacsclient -t -a ""'        # open a frame in the current terminal
alias ec='emacsclient -c -a ""'        # open a GUI frame and block until closed

alias emacs-start='emacs --daemon'
alias emacs-stop='emacsclient -e "(save-buffers-kill-emacs)"'
alias emacs-restart='emacs-stop 2>/dev/null; emacs --daemon'
