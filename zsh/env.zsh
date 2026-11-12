export EDITOR="zed --wait"
export VISUAL="zed --wait"

# your project folder that we can `c [tab]` to
export PROJECTS=~/Documents/Projects

[[ ! -o interactive && ( -n $CLAUDECODE || -n $CODEX_THREAD_ID ) ]] && setopt sh_word_split no_nomatch no_equals
