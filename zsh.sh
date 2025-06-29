#
# Basic setup.
#
export PATH="/opt/homebrew/bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH" # pipx binaries
export PATH="${HOME}/bin:${PATH}" # custom scripts
# export PATH="/usr/local/opt/ruby/bin:$PATH" # ruby installed with Homebrew

# Completion: https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  # Had to disable the owner check with '-u' because I have a multi-user system:
  # https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
  compinit -u
fi

bindkey \^U backward-kill-line


setopt HIST_IGNORE_SPACE      # Do not store commands prefixed with a space in history
setopt HIST_IGNORE_DUPS       # Ignores if the previous command is a duplicate
setopt HIST_FIND_NO_DUPS      # Prevents showing dups when using reverse search (Ctrl+R)

# Example prompt: `vita@host ~/some/dir %`
export PS1='%B%F{cyan}%n@%m%f %F{blue}%~%f %#%b '

# GPG
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# Duplicity wants this
ulimit -n 1024

# No need to share with other users by default
umask 077

alias espanso-config='code ~/Library/Application\ Support/espanso'

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
alias http='python3 -m http.server --bind 127.0.0.1'
alias b='bat'
alias vs='code' # VSCode
alias 'v.'='vs .'
alias k='kubectl'
alias itm='itermocil --here'


#
# Utilities.
#

autoload -Uz add-zsh-hook

# Set terminal title.
title() {
	title="$@"

    title_setter() {
		echo -ne "\e]1;$title\a"
    }

    title_setter
    add-zsh-hook precmd title_setter
}

# Print a yellow horizontal line.
hr() {
	COLS="$(tput cols)"
	if (( COLS <= 0 )) ; then
		COLS="${COLUMNS:-80}"
	fi
	local WORD='\/'
	local LINE=''
	while (( ${#LINE} < COLS )); do
		LINE="$LINE$WORD"
	done
	echo -e '\033[33m'
	echo "${LINE:0:$COLS}"
	echo -e '\033[39m'
}


#
# Git.
#

# Print the current branch and number of commits ahead/beind of upstream branch.
# Print working directory status.
# Example:
#
# main ↑1 ↓0
#  M requirements.txt
#  M setup.py
git_info() {
	branch=$(git symbolic-ref HEAD --short)
	origin_status=$(git rev-list --left-right $branch...origin/$branch --count 2>/dev/null | awk '{print "↑" $1 " ↓" $2}')
	if [ -z "$origin_status" ]; then
		origin_status='(no upstream)'
	fi

	echo -ne '\033[1;30m' # gray
	echo $branch $origin_status
	echo -ne '\033[0m' # reset
	git status --short
}

# Show git_info before each prompt. Set terminal title to the first argument (defaults to the basename of current directory).
GIT() {
	def=$(basename $(pwd))
	title ${1:-"$def"}
	add-zsh-hook precmd git_info
}

alias gs='git status'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
gd() { git diff --color $@ | diff-so-fancy | less -R; }
gdc() { git diff --cached --color $@ | diff-so-fancy | less -R; }
alias gc='git commit'
alias gca='git commit --amend'
alias gm='git merge --no-ff'
alias gpum='git fetch origin main:main'
alias ga='git add'
alias gb='git checkout'
alias gpo='git push origin'
alias gg="ag --pager='less -RFX' --case-sensitive --hidden --ignore .git"
alias upg='git fetch --prune && git fetch --tags' # update git
alias grv='git remote -v'
alias gpu='git pull'
alias guu='upg && gpu'
alias grb='git rebase'
alias gre1='git reset HEAD~1'

# Itemised commit messages on this branch from the given ref (defaults to main).
branchlog () {
	git log --format=format:'* %s' --reverse ${1:-main}..
}


#
# Python
#

#- Environment setup
eval "$(pyenv init --path)"
# This redundant-looking init was necessary to make `pyenv virtualenv activate` work: https://stackoverflow.com/a/70307478
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_VERBOSE_ACTIVATE=1
# 'pyenv-virtualenv: prompt changing will be removed from future release' so we implement the same functionality manually:
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
__pyenv_virtualenv_ps1 () {
	# From https://github.com/pyenv/pyenv-virtualenv/issues/153
    local ret=$?
    if [ -n "${PYENV_VIRTUAL_ENV}" ]; then
        echo -n "(${PYENV_VIRTUAL_ENV##*/}) "
    fi
    return $?
}
setopt PROMPT_SUBST
export PS1="\$(__pyenv_virtualenv_ps1)${PS1}"

#- Common aliases
alias ipy='ipython'
alias pyt='py.test -vs'
mkpak () { mkdir $1 && touch $1/__init__.py && tree $1; } # Create an empty Python package
alias st='open -a SourceTree'

# uv
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
# https://github.com/astral-sh/uv/issues/8432#issuecomment-2453494736
_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv
