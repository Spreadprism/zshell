# ------------------------------------------------------------
# profiler
# ------------------------------------------------------------
zmodload zsh/zprof
# ------------------------------------------------------------
# Zinit
# ------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  echo "Installing zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
# ------------------------------------------------------------
# Plugins
# ------------------------------------------------------------
zinit_program () {
  zi ice from"gh-r" as"program"
  zi light $1
}

zinit_completion () {
  zi ice as"completion"
  zinit snippet $1
}
# ------------------------------------------------------------
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
DIRECTORY_STYLE="bold cyan"
zinit light starship/starship
# zinit ice depth=1; zinit light romkatv/powerlevel10k
# ------------------------------------------------------------
zinit ice wait lucid
zinit_program junegunn/fzf
zinit ice wait lucid
zinit_program ajeetdsouza/zoxide
zinit ice wait lucid
zinit_program jesseduffield/lazygit
zinit ice wait lucid
zinit_program eza-community/eza
zinit light zsh-users/zsh-syntax-highlighting # INFO: Adds a % if loaded async
zinit light zsh-users/zsh-completions
# ------------------------------------------------------------
ZVM_VI_ESCAPE_BINDKEY=';;'
ZVM_VI_SURROUND_BINDKEY='s-prefix'
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_VI_HIGHLIGHT_BACKGROUND=#283457
ZVM_VI_HIGHLIGHT_FOREGROUND=#c0caf5
ZVM_VI_EDITOR='nvim'
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
# ------------------------------------------------------------
export FZF\_DEFAULT\_OPTS='--bind=shift-tab:up,tab:down'
zinit ice wait lucid
zinit_program junegunn/fzf
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
# ------------------------------------------------------------
zinit light qoomon/zsh-lazyload # INFO: Cannot be lazyloaded
zinit ice wait lucid
zinit snippet OMZP::sudo
# ------------------------------------------------------------
if [[ $(cat /etc/*-release | grep -i '^ID=' | cut -d'=' -f2) = 'arch' ]]
then
  zinit snippet OMZP::archlinux
fi
# ------------------------------------------------------------
zinit ice wait lucid
zinit light joshskidmore/zsh-fzf-history-search
zinit ice wait lucid
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::command-not-found
zinit ice wait lucid
zinit snippet OMZP::dirhistory
zinit ice wait lucid
zinit_completion OMZP::poetry
zinit ice wait lucid
zinit_completion OMZP::docker
zinit ice wait lucid
zinit_completion OMZP::docker-compose
zinit ice wait lucid
zinit_completion OMZP::kubectl
# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------
autoload -Uz compinit && compinit
zinit cdreplay -q
eval "$(dircolors -b)" # Enables LS_COLORS
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# ------------------------------------------------------------
# Command history
# ------------------------------------------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
# ------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------
conda_activate_current_dir () {
  env_dir=$HOME/miniconda3/envs/
  current_directory_name="${PWD##*/}"
  if [ -d "$env_dir/$current_directory_name"_env ]; then
    source ~/miniconda3/bin/activate "$current_directory_name"_env
  elif [ -d "$env_dir/$current_directory_name" ]; then
    source ~/miniconda3/bin/activate "$current_directory_name"
  fi
}
previous_dir () {
  dirhistory_back
  zle .accept-line
}
next_dir () {
  dirhistory_forward
  zle .accept-line
}

# The plugin will auto execute this zvm_after_select_vi_mode function
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      # Something you want to do...
    ;;
    $ZVM_MODE_INSERT)
      # Something you want to do...
    ;;
    $ZVM_MODE_VISUAL)
      # Something you want to do...
    ;;
    $ZVM_MODE_VISUAL_LINE)
      # Something you want to do...
    ;;
    $ZVM_MODE_REPLACE)
      # Something you want to do...
    ;;
  esac
}
# ------------------------------------------------------------
# zsh widgets
# ------------------------------------------------------------
zle -N previous_dir
zle -N next_dir
# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
alias zz='cd -'
alias ls='eza'
alias lg='lazygit'
alias activate='conda_activate_current_dir'
alias deactivate='conda deactivate'
# ------------------------------------------------------------
# Keybinds
# ------------------------------------------------------------
function zvm_after_lazy_keybindings() {
  # INFO: These keybindings are set only in normal mode
  zvm_bindkey vicmd 'H' beginning-of-line
  zvm_bindkey vicmd 'L' end-of-line
}
function zvm_after_init() {
  # INFO: These keybindings are set for insert mode
  bindkey '^A' autosuggest-execute
  bindkey '^O' previous_dir
  bindkey '^P' next_dir
}
# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
export PATH="$PATH:$HOME/.dotfiles/bin"
if command -v pnpm &> /dev/null
then
  export PNPM_HOME="/home/avalon/.local/share/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
# ------------------------------------------------------------
if command -v pipx &> /dev/null
then
  export PATH="$PATH:$HOME/.local/bin"
fi
# ------------------------------------------------------------
if command -v gem &> /dev/null
then
  export PATH="$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin/"
fi
# ------------------------------------------------------------
if command -v go &> /dev/null
then
  export GOPATH="$HOME/.go"
  export GOBIN="$GOPATH/bin"
fi
# ------------------------------------------------------------
if command -v cargo &> /dev/null
then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
# ------------------------------------------------------------
if command -v nvim &> /dev/null
then
  export NVIM_LISTEN_ADDRESS='/tmp/nvim.socket'
fi
# ------------------------------------------------------------
# conda
# ------------------------------------------------------------
init_conda() {
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
          . "$HOME/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="$HOME/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
}
init_nvm() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}
# ------------------------------------------------------------
# Lazy loading
# ------------------------------------------------------------
lazyload nvm -- 'init_nvm'
lazyload conda -- 'init_conda'
# ------------------------------------------------------------
# WSL
# ------------------------------------------------------------
if [[ $(grep -i Microsoft /proc/version) ]]; then
  export IN_WSL="true"
  export BROWSER=wslview
  alias wsl='wsl.exe'
  alias explorer='explorer.exe .'
  alias pws='powershell.exe'
fi
# ------------------------------------------------------------
# Shell init
# ------------------------------------------------------------
eval "$(zoxide init --cmd cd zsh)"
conda_activate_current_dir # Activate conda env if present
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ------------------------------------------------------------
# Tmux
# ------------------------------------------------------------
if command -v tmux &> /dev/null
then
  source ~/.shell/tmux.zsh
fi
