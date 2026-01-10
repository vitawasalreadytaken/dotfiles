export PATH="/opt/homebrew/bin:$PATH"

# Completion: https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  # -u needed because of https://github.com/docker/for-mac/issues/7711
  compinit -u
fi
