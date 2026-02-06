alias cdtemp="cd $(mktemp -d)"

alias gbc="git branch --show-current | tee >(tr -d '\n' | pbcopy)" # copy the current branch name to the clipboard (and still print it)

# prettier ls
alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"

alias vim="nvim"
alias vi="vim"

