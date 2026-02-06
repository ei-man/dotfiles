# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Brew ---
if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi


# --- Zap itself ---
[ -f "$XDG_DATA_HOME/zap/zap.zsh" ] && source "$XDG_DATA_HOME/zap/zap.zsh" || zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1

function zvm_config() {
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
  ZVM_ESCAPE_KEYTIMEOUT=0.01
  ZVM_VI_SURROUND_BINDKEY="s-prefix"
}


# --- Plugins ---
plug "zsh-users/zsh-autosuggestions"
plug "romkatv/powerlevel10k"
plug "zdharma-continuum/fast-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"
plug "marlonrichert/zsh-autocomplete" "adfade3"

# --- p10k ---
source $XDG_CONFIG_HOME/zsh/.p10k.zsh

# --- aliases ---
source $XDG_CONFIG_HOME/zsh/aliases.zsh

# --- work stuff ---
source $HOME/.zsh-work.zsh

# --- Completion styling ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# --- FZF ---
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# setup preview
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}



# --- History ---
## Max number of history lines in memory
HISTSIZE=50000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
# share history between shell sessions
setopt SHARE_HISTORY
# don't save commands starting with a space
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_VERIFY

# Set up history file
if [[ ! -d "$XDG_DATA_HOME/zsh" ]]; then
  mkdir -p "$XDG_DATA_HOME/zsh"
fi
HISTFILE="$XDG_DATA_HOME/zsh/history"

## Max number of history lines saved in history file
SAVEHIST=200000


# ---- Zoxide (better cd) ----
eval "$(zoxide init --cmd cd zsh)"

zvm_after_init_commands+=("bindkey '^[[A' up-line-or-search" "bindkey '^[[B' down-line-or-search")
#zvm_after_init_commands+=("autoload -U up-line-or-beginning-search && bindkey '^[[A' up-line-or-beginning-search" "autoload -U down-line-or-beginning-search && bindkey '^[[B' down-line-or-beginning-search")


# local binaries
path+=("$HOME/bin")
# go binaries
path+=("$HOME/go/bin")

# JetBrains CLI shortcuts
path+=("$HOME/Library/Application Support/JetBrains")

# add direnv hook
eval "$(direnv hook zsh)"

