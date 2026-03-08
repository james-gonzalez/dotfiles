# Deduplicate PATH entries (set early, before any PATH modifications)
typeset -U PATH
PATH=$PATH:/opt/homebrew/bin:$HOME/go/bin:$HOME/.local/bin

## ZSH OPTIONS ##
HISTFILE=~/.zhistory
HISTSIZE=10000000
SAVEHIST=10000000
setopt extended_history append_history hist_ignore_dups hist_ignore_space

# error when glob doesnt match anything
setopt no_match

# cd into a directory by typing the path
setopt auto_cd

# save comments in history
setopt interactive_comments

# report when background job finishes
setopt notify

# long format for jobs
setopt long_list_jobs

# dont match dotfiles
setopt no_globdots

# better globs
setopt extendedglob
setopt no_caseglob

# disable history expansion (anything after !)
setopt no_banghist

# nicer tab completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# compinit must be loaded before zsh syntax highlighting
autoload -Uz compinit

# generate compinit only every 8 hours
for _ in ~/.zcompdump(N.mh+8); do
   compinit
done

compinit -C

# show dotfiles with tab completion
_comp_options+=(globdots)

## PLUGIN CONFIG (set before loading plugins) ##
# modify comment highlighting so it's visible with dracula theme
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272a4'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta,underline'

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(backward-delete-char)

## ZINIT SETUP ##
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load annexes (required for annexes, no Turbo)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit load wfxr/forgit
zinit light mollifier/cd-gitroot

# OMZ core library (provides git_current_branch and other functions used by plugins)
zinit snippet OMZ::lib/git.zsh

# OMZ plugin snippets
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/lxd/lxd.plugin.zsh
zinit snippet OMZ::plugins/brew/brew.plugin.zsh
zinit snippet OMZ::plugins/aws/aws.plugin.zsh
zinit snippet OMZ::plugins/cp/cp.plugin.zsh
zinit snippet OMZ::plugins/git-auto-fetch/git-auto-fetch.plugin.zsh
zinit snippet OMZ::plugins/git-commit/git-commit.plugin.zsh
zinit snippet OMZ::plugins/jump/jump.plugin.zsh
zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh
zinit snippet OMZ::plugins/autojump/autojump.plugin.zsh

## TOOLS ##
source <(fzf --zsh)
eval "$(oh-my-posh init zsh --config $HOME/omp.yaml)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Only set TERM inside tmux
[[ -n "$TMUX" ]] && export TERM=tmux-256color

export FUNCNEST=1000

# Google Cloud SDK
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

export PATH

## ALIASES ##
alias vim='nvim'
alias cat='bat'
alias ls='eza'
alias l='eza --git-ignore'
alias ll='eza --all --header --long -sold'
alias llm='eza --all --header --long --sort=modified'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'

## FUNCTIONS ##
# Transmission remote functions
_tr() {
  local pw
  pw=$(security find-generic-password -a "$USER" -s "TRANSMISSION_PASSWORD" -w login.keychain-db 2>/dev/null)
  transmission-remote transmission:9091 --auth "transmission:${pw}" "$@"
}

tlist() { _tr --list; }
tstat() { _tr --session-info; }
tadd()  { _tr --add "$1"; }
trem()  { _tr --torrent "$1" --remove; }
tinfo() { _tr --torrent "$1" --info; }

## SECRETS (API keys, tokens — never commit this file) ##
[[ -f ~/.zsh_secrets ]] && source ~/.zsh_secrets
