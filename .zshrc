# ---- Tabs (8 -> 4)
tabs -4

# ---- Colors
autoload -U colors && colors

# ---- Git info with zsh (vcs_info)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
precmd() { vcs_info }

# ---- Prompt (user, git branch, directory)
setopt prompt_subst
PROMPT='%F{cyan}%n%f %F{yellow}${vcs_info_msg_0_}%f %F{green}%1~%f %# '

# ---- Python venv
if [[ -f ~/pe/bin/activate ]]; then
  source ~/pe/bin/activate
fi

# ---- Completion (zsh + Homebrew)
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
# Cache speeds things up on repeated sessions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# Friendly matching & UI
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|=*' 'l:|=*'
zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
compinit

# Add alias to completely clear terminal (including scrollback)
# Equivalent to Command + K
alias cclear='clear && printf "\033[3J"'
