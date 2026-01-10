source $HOME/.iterm2_shell_integration.zsh

# GPG
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Duplicity wants this
ulimit -n 1024

alias espanso-config='code ~/Library/Application\ Support/espanso'

alias itm='itermocil --here'
