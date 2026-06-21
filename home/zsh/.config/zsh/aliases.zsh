cdtemp() { cd "$(mktemp -d)" }

# copy the current branch name to the clipboard (and still print it)
if command -v pbcopy &>/dev/null; then
  alias gbc="git branch --show-current | tee >(tr -d '\n' | pbcopy)"
elif command -v wl-copy &>/dev/null; then
  alias gbc="git branch --show-current | tee >(tr -d '\n' | wl-copy)"
elif command -v xclip &>/dev/null; then
  alias gbc="git branch --show-current | tee >(tr -d '\n' | xclip -selection clipboard)"
fi

# prettier ls
alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"

alias vim="nvim"
alias vi="vim"

