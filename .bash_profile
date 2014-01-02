for project in puppet facter; do
   export RUBYLIB="$HOME/dev/$project/lib:$RUBYLIB"
done

PATH=/usr/local/bin:$PATH

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

export CC=gcc-4.2

export EDITOR=vim

if which rvm &> /dev/null
then
  [[ -s "$HOME/.rvm/contrib/ps1_functions" ]] && source "$HOME/.rvm/contrib/ps1_functions"

  ps1_set --notime

  source ~/.rvm/scripts/rvm
else
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWSTASHSTATE=1
  #GIT_PS1_SHOWUNTRACKEDFILES=1
  #GIT_PS1_DESCRIBE_STYLE="branch"
  #GIT_PS1_SHOWUPSTREAM="auto git"

  get_sha() {
    git rev-parse --short HEAD 2>/dev/null
  }
  PS1='\u@\h:\w$(__git_ps1 " (%s:$(get_sha))")\$ '
fi

source ~/.git-completion.bash

if [ -f ~/.bashrc ]; then
       . ~/.bashrc
fi

export PATH

