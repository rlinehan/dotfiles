[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# set path
PATH=/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH

# Configure homebrew if it exists
if [ -d "/opt/homebrew" ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# Configure rbenv if it exists
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Configure jenv if it exists
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# Add $GOPATH to $PATH if go is installed
if which go > /dev/null; then PATH=$PATH:$HOME/go/bin; fi

# Configure nodenv if it exists
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

# Configure rustup if it exists
if [ -d "$HOME/.cargo/bin" ]; then
  . "$HOME/.cargo/env"
fi

if [ -d "$HOME/.momento/bin" ]; then
  PATH=$PATH:$HOME/.momento/bin
fi

# for secure, machine usable tokens
if [ -f "$HOME/.profile.local" ]; then . "$HOME/.profile.local"; fi

#### history ####

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# append to history
setopt APPEND_HISTORY
# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# do not store duplications
setopt HIST_IGNORE_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS
# show the substituted command in the prompt before execution
setopt HIST_VERIFY

#### end history ####

# turn on command correction
setopt CORRECT

# emacs mode
bindkey -e

#### search ####
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
#### end search ####

#### prompt ####
setopt PROMPT_SUBST

[ -f ~/.git-prompt.sh ] && source ~/.git-prompt.sh

NEWLINE=$'\n'
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
    echo "$(__git_ps1 "(git:%s$(ps1_git_status):$(ps1_git_sha))")"

  fi
}

# ruth@griddle:~/dotfiles (git:main+*:50f08eac1)
# $
# user(green/red for superuser)@host(cyan):directory(magenta) (git(blue))
PROMPT='%(!.%F{red}%n%f.%F{green}%n%f)@%F{cyan}%m%f:%F{magenta}%~%f %F{blue}$(ps1_git)%f ${NEWLINE}$ '

#### end prompt ####

[ -f ~/.bash_aliases ] && source ~/.bash_aliases
export EDITOR=vim
export PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
