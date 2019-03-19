#
# Basic setup.
#
export PATH="${HOME}/.local/bin:$PATH" # pipx binaries
export PATH="${HOME}/bin:${PATH}" # custom scripts
# Example prompt: `vita@host ~/some/dir $`
export PS1='\[\033[1;36m\]\u@\h\[\033[00m\] \[\033[1;34m\]\w \$\[\033[00m\] '
export GPG_TTY=$(tty)


#
# Essential commands.
#
alias ..='cd ..'
alias ...='cd ../..'
alias egrep='egrep --color'
alias fgrep='fgrep --color=auto'
alias grep='grep --color'
alias ll='exa --long --all --group'
alias tree='tree -h'
mkcd () { mkdir "$1" && cd "$1"; }
alias http='python3 -m http.server --bind 127.0.0.1'
alias b='bat'
alias vs='code' # VSCode



#
# Utilities.
#

# Set terminal title. Call `title --reset` to set it back to default.
title() {
	if [ "x$@" = 'x--reset' ]; then
		T='${PWD/#$HOME/~} (${USER}@${HOSTNAME%%.*})'
	else
		T="$@"
	fi
	export PROMPT_COMMAND='echo -ne "\033]0;'"$T"'\007"'
	echo -ne "\033]0;${T}\007"
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

if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

# Print the current branch and number of commits ahead/beind of upstream branch.
# Print working directory status.
# Example:
#
# develop ↑1 ↓0
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
	export PROMPT_COMMAND=git_info
}

alias gs='git status'
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ad)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an %G?[%GK]%C(reset)%C(bold yellow)%d%C(reset)'"
gd() { git diff --color $@ | diff-so-fancy | less -R; }
gdc() { git diff --cached --color $@ | diff-so-fancy | less -R; }
alias gc='git commit'
alias gm='git merge --no-ff'
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
# Fix autocomplete for aliases
__git_complete gb _git_checkout
__git_complete gm _git_merge
__git_complete grb _git_rebase



#
# Python & development.
#
alias ipy='ipython'
alias partest='(pip freeze 2>/dev/null | grep pytest-xdist >/dev/null) || pip install pytest-xdist; py.test -n2 -vs' # Parallel test run; installs pytest-xdist if necessary.
alias pyt='py.test -vs'
mkpak () { mkdir $1 && touch $1/__init__.py && tree $1; } # Create an empty Python package
alias flk='pyflakes-ext'

_here="${BASH_SOURCE%/*}"
source "${_here}/virtualenvwrapper_setup.sh"

vg () {
	# Run commands inside Vagrant.
	vagrant ssh -c "$*"
}

alias st='open -a SourceTree'
