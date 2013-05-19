for project in puppet facter; do
   export RUBYLIB="$HOME/Development/$project/lib:$RUBYLIB"
done
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=/usr/local/bin:$PATH

export CC=/usr/bin/gcc-4.2

[[ -s "$HOME/.rvm/contrib/ps1_functions" ]] && source "$HOME/.rvm/contrib/ps1_functions"

ps1_set --notime

source ~/.git-completion.bash

source ~/.rvm/scripts/rvm
