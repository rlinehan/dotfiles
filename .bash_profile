export BASH_SILENCE_DEPRECATION_WARNING=1

PATH=/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH

# Configure homebrew if it exists
if [ -d "/opt/homebrew" ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# Configure RVM if it exists
if [ -d "$HOME/.rvm/bin"  ]; then
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" && PATH=$PATH:$HOME/.rvm/bin
fi

# Configure rbenv if it exists
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Configure jenv if it exists
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# Add $GOPATH to $PATH if go is installed
if which go > /dev/null; then PATH=$PATH:$HOME/go/bin; fi

# Configure nodenv if it exists
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

# Configure pyenv if it exists
# see docs at https://github.com/pyenv/pyenv#basic-github-checkout - need to
# set up .profile and .bashrc as well, currently not checked into dotfiles
# repo
if which pyenv > /dev/null;
then
  eval "$(pyenv init --path)"
fi

# Configure rustup if it exists
if [ -d "$HOME/.cargo/bin" ]; then
  . "$HOME/.cargo/env"
fi


if [ -d "$HOME/.momento/bin" ]; then
  PATH=$PATH:$HOME/.momento/bin
fi

#export CC=gcc-4.2
#export CC=gcc

export EDITOR=vim

stty quit undef

# source:
# http://vvv.tobiassjosten.net/bash/dynamic-prompt-with-git-and-ansi-colors/
# and RVM contrib ps1_functions
# (https://github.com/wayneeseguin/rvm/blob/master/contrib/ps1_functions)
#
# Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  c_reset='\[\e[0m\]'
  c_user_root='\[\033[31m\]'
  c_user='\[\033[32m\]'
  c_host='\[\033[36m\]'
  c_git_branch='\[\033[5;34m\]'
  c_path='\[\033[35m\]'
  c_venv='\[\033[95m\]'
else
  c_reset=
  c_user_root=
  c_user=
  c_host=
  c_git_branch=
  c_path=
fi

GIT_PS1_SHOWDIRTYSTATE=
GIT_PS1_STATESEPARATOR=''

ps1_git_sha() {
  git rev-parse --short HEAD 2>/dev/null
}

# This is taken directly out of the RVM ps1_functions
# (https://github.com/wayneeseguin/rvm/blob/master/contrib/ps1_functions), because I prefer it
# over the __git_ps1 SHOWDIRTYSTATE symbols - I like that this tells you
# what was deleted in addition to added.
ps1_git_status()
{
  local git_status="$(git status 2>/dev/null)"

  [[ "${git_status}" = *deleted* ]]                    && printf "%s" "-"
  [[ "${git_status}" = *Untracked[[:space:]]files:* ]] && printf "%s" "+"
  [[ "${git_status}" = *modified:* ]]                  && printf "%s" "*"
}

ps1_git()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  else
    printf "%s" '$(__git_ps1 " (git:%s$(ps1_git_status):$(ps1_git_sha))")'
  fi
}

ps1_identity()
{
  if (( $UID == 0 )) ; then
    user_color="$c_user_root"
  else
    user_color="$c_user"
  fi

  echo "$user_color\u${c_reset}"
}

# from https://stackoverflow.com/a/20026992
ps1_virtualenv()
{
  # Get Virtual Env
  if [[ -n "$VIRTUAL_ENV" ]]; then
    # Strip out the path and just leave the env name
    venv="${VIRTUAL_ENV##*/}"
  else
    # In case you don't have one activated
    venv=''
  fi
  [[ -n "$venv" ]] && echo " (venv:$venv) "
}

# from https://coderwall.com/p/ba8afa/git-branch-fuzzy-search-checkout
gco() {
#  git fetch
  local branches branch
  branches=$(git branch -a) &&
  branch=$(echo "$branches" | fzf +s +m -e) &&
  git checkout $(echo "$branch" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1
PROMPT_COMMAND='PS1="$(ps1_identity)@${c_host}\h${c_reset}:${c_path}\w${c_reset}${c_git_branch}$(ps1_git)${c_reset}${c_venv}$(ps1_virtualenv)${c_reset}\n\$ "'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# for secure, machine usable tokens
if [ -f "$HOME/.profile.local" ]; then . "$HOME/.profile.local"; fi

source ~/.bash_aliases

source ~/.lein-completion.bash
source ~/.git-completion.bash
source ~/.git-prompt.sh
export PATH

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
