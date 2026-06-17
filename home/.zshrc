# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '^ ' autosuggest-accept

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ehco='echo you typped echo wrong'
alias ls='ls --color'
alias ..='cd ..'
alias x='clear && printf "\e[H"'
alias ff='fastfetch'
alias j='jobs'
alias nv='cd ~/.config/nvim/'
alias hw='cd ~/.config/hypr/'
alias fucking='sudo'
alias py='python3'
alias lz='lazygit'
alias ls='eza  --icons=always'
alias ll='eza -l --icons=always'
alias lt='eza --tree --level=1 --icons=always'
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux ls'
alias battert='upower -i $(upower -e | grep BAT)'
alias dot='cd ~/dotfiles'
alias C='claude --continue'
alias cl='claude --resume'
alias op='opencode'
alias y='yazi'
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias bb='cd ~/workspace/balkanbaltic/'
alias bbd='cd ~/workspace/balkanbaltic/documentation'
alias bbs='cd ~/workspace/balkanbaltic/server/'
alias bbw='cd ~/workspace/balkanbaltic/web'
alias bba='cd ~/workspace/balkanbaltic/admin/'

sts() {
  case "$1" in                                                        
    l) sudo timeshift --list ;;
    c) sudo timeshift --create ;;
    g) sudo -E timeshift-gtk ;;
    d) sudo timeshift --delete --snapshot "$2" ;;                     
    D)
      local oldest
      oldest=$(sudo timeshift --list | awk '$2 == ">" {print $3; exit}')
      if [[ -n "$oldest" ]]; then
        echo "Deleting oldest snapshot: $oldest"
        sudo timeshift --delete --snapshot "$oldest"
      else
        echo "No snapshots found"
      fi
      ;;
  *) echo "Usage: sts {l|c|g|d <snapshot>|D}" ;;
  esac                                                                
}      

v() {
    if [[ $# -eq 0 ]]; then
      nvim .
      return
    fi

    nvim "$1"
  }

unalias g 2>/dev/null
g() {
    if [[ $# -eq 0 ]]; then
      git
      git --version
      return
    fi

    case "$1" in
      p) git pull ;;
      P) git push ;;
      b) git branch ;;
      S)
        if [[ -z "$2" ]]; then
          git switch -
        else
          git switch "$2"
        fi
        ;;
      s) git status ;;
      d) git diff ;;
      D) git diff --staged ;;
      st)
        case "$2" in
          "") git stash ;;
          p) git stash pop ;;
          a) git stash apply ;;
          l) git stash list ;;
          s)
            if [[ -z "$3" ]]; then
              git stash show
            else
              git stash show "$3"
            fi
            ;;
          *)
            shift
            git stash push -m "$*"
            ;;
        esac
        ;;
      a)
        if [[ -z "$2" ]]; then
          git add .
        else
          git add "$2"
        fi
        ;;
      A) git commit --amend ;;
      aA) git add . && git commit --amend ;;
      c)
        if [[ -z "$2" ]]; then
          git commit
        else
          shift
          git commit -m "$*"
        fi
        ;;
      C) git commit -a ;;
      l)
        if [[ -z "$2" ]]; then
          git log --oneline -10
        else
          git log --oneline -"$2"
        fi
        ;;
      L)
        if [[ -z "$2" ]]; then
          git log -10
        else
          git log -"$2"
        fi
        ;;
      R) git reset --soft HEAD~1 ;;
      r)
        if [[ -z "$2" ]]; then
          echo "g r requires an argument (number or commit id)" >&2
          return 1
        elif [[ "$2" =~ ^[0-9]+$ ]]; then
          git reset HEAD~"$2"
        else
          git reset "$2"
        fi
        ;;
      rP)
        local branch
        branch=$(git rev-parse --abbrev-ref HEAD) || return 1
        git reset --hard origin/"$branch"
        ;;
      *) git "$cmd" "$@" ;;
    esac
  }

# Shell integrations
eval "$(fzf --zsh)"
# eval "$(zoxide init --cmd cd zsh)"

export PATH=$PATH:$(go env GOPATH)/bin

# opencode
export PATH=/home/teo/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
