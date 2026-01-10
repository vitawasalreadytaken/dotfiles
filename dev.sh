alias vs='code' # VSCode
alias 'v.'='vs .'
alias k='kubectl'
alias st='open -a SourceTree'
alias http='python3 -m http.server --bind 127.0.0.1'

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

#- Common aliases
alias ipy='uvx ipython'
alias pyt='uv run pytest -vs'
mkpak () { mkdir $1 && touch $1/__init__.py && tree $1; } # Create an empty Python package

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
