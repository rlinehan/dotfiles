[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#### prompt stuff ####
setopt PROMPT_SUBST

source ~/.git-prompt.sh

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


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
