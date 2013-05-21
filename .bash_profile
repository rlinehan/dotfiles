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
  export GIT_PS1_SHOWUPSTREAM="auto"
  PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
fi

source ~/.git-completion.bash

