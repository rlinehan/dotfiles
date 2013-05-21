for project in puppet facter; do
   export RUBYLIB="$HOME/Development/$project/lib:$RUBYLIB"
done
PATH=/usr/local/bin:$PATH

export CC=/usr/bin/gcc-4.2

if which rvm &> /dev/null
then
  [[ -s "$HOME/.rvm/contrib/ps1_functions" ]] && source "$HOME/.rvm/contrib/ps1_functions"

  PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

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

