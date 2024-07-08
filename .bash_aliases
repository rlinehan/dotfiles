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
alias myrusttest='cargo fmt -- --check && cargo clippy --all-targets --all-features -- -D warnings -W clippy::unwrap_used -W clippy::todo -W clippy::panic_in_result_fn -W clippy::expect_used && cargo build --frozen && cargo test -- --nocapture'
