#
# Basic setup.
#
export PATH="${HOME}/bin:/usr/local/bin:${PATH}"
export PS1='\[\033[1;36m\]\u@\h\[\033[00m\] \[\033[1;34m\]\w \$\[\033[00m\] '



#
# Essential commands.
#
alias ..='cd ..'
alias ...='cd ../..'
alias egrep='egrep --color'
alias fgrep='fgrep --color=auto'
alias grep='grep --color'
alias ll='ls -lhFG'
alias la='ll -A'
alias tree='tree -h'
mkcd () { mkdir "$1" && cd "$1"; }
# Screen
alias sl='screen -ls'
alias sr='screen -dr'



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
gitInfo() {
	branch=$(git symbolic-ref HEAD --short)
	originStatus=$(git rev-list --left-right $branch...origin/$branch --count 2>/dev/null | awk '{print "↑" $1 " ↓" $2}')
	if [ -z "$originStatus" ]; then
		originStatus='(no upstream)'
	fi

	echo -ne '\033[1;30m' # gray
	echo $branch $originStatus
	echo -ne '\033[0m' # reset
	git status --short
}

# Show gitInfo before each prompt. Set terminal title to the first argument (defaults to the basename of current directory).
GIT() {
	def=$(basename $(pwd))
	title ${1:-"$def"}
	export PROMPT_COMMAND=gitInfo
}

alias gs='git status'
alias gl='git log'
gd() { git diff --color $@ | diff-so-fancy | less -R; }
gdc() { git diff --cached --color $@ | diff-so-fancy | less -R; }
alias gc='git commit'
alias gm='git merge --no-ff'
alias ga='git add'
alias gb='git checkout'
alias gp='git push'
alias gpo='git push origin'
alias gg='git grep -npE --break'
alias upg='git fetch --prune && git fetch --tags' # update git
alias grv='git remote -v'
alias gpu='git pull'
# Fix autocomplete for aliases
__git_complete gb _git_checkout
__git_complete gm _git_merge



#
# Python.
#
alias act='source env/bin/activate'
alias ipy='ipython'
alias newe='virtualenv -p $(which python3) env && act && pip install pip-accel'
alias pipa='pip-accel'
alias atenv='atom env/lib/python*/site-packages' # Open virtualenv packages in Atom
alias reset-env='deactivate; rm -rf env && newe && pipa install -r requirements.txt'
alias partest='py.test -n2 --ignore env' # Parallel test run; requires pytest-xdist
