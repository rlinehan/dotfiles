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

# Hint: list options set with `set -o`

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
# the number of items for the internal history list
export HISTSIZE=1000000
# maximum number of items for the history file
export SAVEHIST=1000000
# share history across multiple zsh sessions
setopt SHARE_HISTORY
# do not save duplicated command
setopt HIST_IGNORE_ALL_DUPS
# removes blank lines from history
setopt HIST_REDUCE_BLANKS
# show command with history expansion to user before running it
setopt HIST_VERIFY
# record command start time
setopt EXTENDED_HISTORY
# show all the history stored. - from https://jdhao.github.io/2021/03/24/zsh_history_setup/
#alias history="fc -l 1"

# use up and down arrows to search with characters typed
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

#### end history ####

#### misc ####

# turn on command correction
setopt CORRECT

# emacs mode
bindkey -e
# default editor vim
export EDITOR=vim

# source bash aliases... these should just work?
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

#### end misc ####

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
    echo "$(__git_ps1 " (git:%s$(ps1_git_status):$(ps1_git_sha))")"

  fi
}

# ruth@griddle:~/dotfiles (git:main+*:50f08eac1)
# $
# user(green/red for superuser)@host(cyan):directory(magenta) ?exit code(purple) (git(blue))
PROMPT='%(!.%F{red}%n%f.%F{green}%n%f)@%F{cyan}%m%f:%F{magenta}%~%f%F{blue}$(ps1_git)%f %F{098}?%?%f ${NEWLINE}$ '

#### end prompt ####

export PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
