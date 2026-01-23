# ===============================
# Force truecolor
# ===============================
export COLORTERM=truecolor
export TERM=xterm-kitty


# ===============================
# Lines configured by zsh-newuser-install
# ===============================
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install


# ===============================
# Lines added by compinstall
# ===============================
zstyle :compinstall filename '$HOME/.zshrc'


# ===============================
# Enable Spaceship prompt
# ===============================
autoload -U promptinit; promptinit
prompt spaceship


# ===============================
# Spaceship config - NEON TIGER
# ===============================
SPACESHIP_PROMPT_ORDER=(
  user
  dir
  git
  exec_time
  line_sep
  char
)

SPACESHIP_CHAR_SYMBOL="▸"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_CHAR_COLOR="magenta"

SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_COLOR="cyan"

SPACESHIP_GIT_BRANCH_COLOR="yellow"
SPACESHIP_GIT_STATUS_COLOR="magenta"

SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR="magenta"
SPACESHIP_HOST_SHOW=false

SPACESHIP_EXEC_TIME_SHOW=true
SPACESHIP_EXEC_TIME_THRESHOLD=2
SPACESHIP_EXEC_TIME_COLOR="yellow"


autoload -Uz compinit
compinit
# End of lines added by compinstall


# ===============================
# Aliases
# ===============================
alias cmatrix='cmatrix -C magenta -a -b -u 6'


# ===============================
# Initialize syntax highlighting
# ===============================
ZSH_HIGHLIGHT_MAXLENGTH=512
typeset -gA ZSH_HIGHLIGHT_STYLES


# ===============================
# NEON TIGER zsh syntax highlighting
# ===============================
# Base/default text
ZSH_HIGHLIGHT_STYLES[default]='fg=#00ffff'

# Commands - bright cyan
ZSH_HIGHLIGHT_STYLES[command]='fg=#00ffff,bold'

# Builtins / aliases / functions - hot pink
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#ff1493'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ff1493'
ZSH_HIGHLIGHT_STYLES[function]='fg=#ff1493'

# Arguments - cyan
ZSH_HIGHLIGHT_STYLES[argument]='fg=#00ffff'

# Options / flags - electric yellow
ZSH_HIGHLIGHT_STYLES[options]='fg=#ffff00,bold'

# Paths - magenta underline
ZSH_HIGHLIGHT_STYLES[path]='fg=#ff00ff,underline'

# Globbing - bright magenta
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ff69b4'

# Quoted strings - electric yellow
ZSH_HIGHLIGHT_STYLES[quoted]='fg=#ffff00'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ffff00'

# Variables - hot pink
ZSH_HIGHLIGHT_STYLES[variable]='fg=#ff1493'

# Assignments - cyan
ZSH_HIGHLIGHT_STYLES[assign]='fg=#00ffff'

# Comments - dim magenta
ZSH_HIGHLIGHT_STYLES[comment]='fg=#8b008b'

# Unknown tokens - neon red on dark
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff0066,bg=#1a0a1a'

ZSH_HIGHLIGHT_STYLES[precommand]='fg=#ff00ff'

# ===============================
# Autosuggestions
# ===============================
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#8b008b'
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh


# ===============================
# Colored coreutils
# ===============================
eval "$(dircolors -b)"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'


# ===============================
# Syntax highlighting (must be last plugin)
# ===============================
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# ===============================
# Fastfetch (interactive only)
# ===============================
[[ $- == *i* ]] && fastfetch
