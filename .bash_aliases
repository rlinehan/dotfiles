alias zeus="OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES bin/zeus start"
alias dbupdate="bin/rake db:migrate db:test:prepare"
alias nbrt="notify bin/rails test $@"
alias cdspcs="ghcs ssh --profile github-codespaces"
alias ibrew="arch -x86_64 /usr/local/bin/brew"
alias mbrew="arch -arm64 /opt/homebrew/bin/brew"
alias udate='date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s"'
alias composite_ks='ln -s ~/momento/kotlin-kitchensink/ ./composites/momento.kitchensink'
alias composite_client='ln -s ~/momento/client-protos/kotlin-messages ./composites/momento.client_protos'
alias install_ts='cd infrastructure/common && npm install && npm run build && cd ../.. && cd infrastructure/aws && npm install && npm run build && cd ../.. && cd infrastructure/gcp && npm install && npm run build && cd ../..'
alias myclippy='cargo fmt && cargo clippy --all-targets --all-features -- -D warnings -W clippy::unwrap_used -W clippy::todo -W clippy::panic_in_result_fn -W clippy::expect_used 2>&1 >/dev/null | less'
alias mmclippy='cargo fmt && cargo clippy --all-targets --all-features -- -D warnings -W clippy::unwrap_used -A clippy::enum-variant-names -A clippy::expect_fun_call'
alias dockerddb='docker run -p 8000:8000 amazon/dynamodb-local'
# from https://stackoverflow.com/questions/43489303/how-can-i-delete-all-git-branches-which-have-been-squash-and-merge-via-github
alias ghprunesquashmergeddryrun='git checkout -q main && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base main $branch) && [[ $(git cherry main $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] && echo "$branch is merged into main and can be deleted"; done'
alias ghprunesquashmerged='git checkout -q main && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base main $branch) && [[ $(git cherry main $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done'
alias mga_prod_accountid='function _prodaccountid(){AWS_PROFILE=prod-global-cell-registry-operator mm ops mga get-accounts-by-legacy-customer-id --legacy-customer-ids "$1" | jq -r .account_id; };_prodaccountid'
alias mga_preprod_accountid='function _preprodaccountid(){AWS_PROFILE=preprod-global-cell-registry-operator mm ops mga get-accounts-by-legacy-customer-id --legacy-customer-ids "$1" | jq -r .account_id; };_preprodaccountid'
