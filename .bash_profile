for project in puppet facter; do
   export RUBYLIB="$HOME/dev/$project/lib:$RUBYLIB"
done

PATH=/usr/local/bin:$PATH

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

export CC=gcc-4.2

export EDITOR=vim

# source:
# http://vvv.tobiassjosten.net/bash/dynamic-prompt-with-git-and-ansi-colors/
# and RVM contrib whatever thing
#
# Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  c_reset='\[\e[0m\]'
  c_user_root='\[\033[31m\]'
  c_user='\[\033[32m\]'
  c_host='\[\033[36m\]'
  c_git_branch='\[\033[5;34m\]'
  c_git_clean='\[\e[0;36m\]'
  c_git_dirty='\[\e[0;35m\]'
  c_path='\[\033[35m\]'
else
  c_reset=
  c_user=
  c_path=
  c_git_clean=
  c_git_dirty=
fi

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM="auto git"

get_sha() {
  git rev-parse --short HEAD 2>/dev/null
}

ps1_git()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    return 0
  else
    printf "%s" '$(__git_ps1 " (git:%s:$(get_sha))")'
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

PROMPT_COMMAND='PS1="$(ps1_identity)@${c_host}\h${c_reset}:${c_path}\w${c_reset}${c_git_branch}$(ps1_git)${c_reset}\n\$ "'


if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

source /Users/ruth/.git-completion.bash
export PATH

