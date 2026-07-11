# Pipe my public key to the clipboard. Uses pbcopy, so macOS-only.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
