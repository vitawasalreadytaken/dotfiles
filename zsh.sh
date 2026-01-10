# Requirements:
#   - fzf
#   - eza
#   - bat

export PATH="${HOME}/bin:${PATH}" # custom scripts
# export PATH="${HOME}/.local/bin:$PATH" # pipx binaries
# export PATH="/usr/local/opt/ruby/bin:$PATH" # ruby installed with Homebrew


bindkey \^U backward-kill-line

setopt HIST_IGNORE_SPACE      # Do not store commands prefixed with a space in history
setopt HIST_IGNORE_DUPS       # Ignores if the previous command is a duplicate
setopt HIST_FIND_NO_DUPS      # Prevents showing dups when using reverse search (Ctrl+R)

# fzf
source <(fzf --zsh)

# Example prompt: `vita@host ~/some/dir %`
export PS1='%B%F{cyan}%n@%m%f %F{blue}%~%f %#%b '


# No need to share with other users by default
umask 077


#
# Essential commands.
#
alias ..='cd ..'
alias ...='cd ../..'
alias egrep='egrep --color'
alias fgrep='fgrep --color=auto'
alias grep='grep --color'
alias ll='eza --long --all --group --git --time-style=long-iso'
alias tree='ll --tree'
mkcd () { mkdir "$1" && cd "$1"; }
alias b='bat'
