#! /bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Uncomment to profile bashrc startup speed.
# PS4='+ $EPOCHREALTIME\011 '
# exec 5> bashrc_trace.txt
# BASH_XTRACEFD="5"
# set -x

# If not running interactively, don't do anything further.
case $- in
  *i*) ;;
    *) return;;
esac

# Source global definitions.
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


# === BASH HISTORY ===
# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options.
HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it.
shopt -s histappend
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Expand out environment variables on tab completion, rather than
# escaping them.
shopt -s direxpand

# === BASH COMPLETIONS ===
# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  # Source local completions
  if [ -d "$HOME/.local/lib/bash_completions/" ]; then
    . "$HOME"/.local/lib/bash_completions/*
  fi
fi


# === TERMINAL COLOUR ===
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac
# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
  else
  color_prompt=
  fi
fi


# === TERMINAL PROMPT ===
# Source shell function for git prompt.
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  . /usr/share/git-core/contrib/completion/git-prompt.sh
  # Setup git prompt variables.
  export GIT_PS1_SHOWDIRTYSTATE="y"
  export GIT_PS1_STATESEPARATOR=""
else
  # If we don't have the git prompt available, use a dummy version.
  __git_ps1 () {
    return
  }
fi

if [ "$color_prompt" = yes ]; then
  #      Bold Green.        Reset..     Bold Blue     Olive                       Red.....                                                      Reset..
  PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\033[38;5;3m$(__git_ps1)\n\[\033[91m\]$(ret=$?; if [ $ret -ne 0 ]; then echo "$ret"; fi)\[\033[0m\]❯ '
else
  # For really basic terminals.
  PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
export PS1
# Limit the number of directories in the prompt to stop it growing too long.
PROMPT_DIRTRIM=3

# Enable color support of ls and also add handy aliases.
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# === CUSTOM BINARIES ===
# Set PATH so it includes user's private bin if it exists, and is not already on PATH.
if [ -d "$HOME/.local/bin" ] ; then
  # Affix colons on either side of $PATH to simplify matching.
  case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
      ;;
    *)
    # Prepending path to allow overwriting old versions.
    PATH="$HOME/.local/bin:$PATH"
    ;;
  esac
fi

# Set PATH so it includes user's private bin if it exists.
if [ -d "$HOME/bin" ] ; then
  case ":${PATH}:" in
    *:"$HOME/bin":*)
      ;;
    *)
    PATH="$HOME/bin:$PATH"
    ;;
  esac
fi

# Include cargo binaries if they exist.
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Include Haskell binaries if they exist.
if [ -f "$HOME/.ghcup/env" ]; then
  . "$HOME/.ghcup/env"
fi

# Include pixi global binaries if they exist.
if [ -d "$HOME/.pixi/bin" ]; then
  PATH="$HOME/.pixi/bin:$PATH"
  # Also include command line completions.
  eval "$(pixi completion --shell bash)"
fi

export PATH


# === SET PREFERED EDITOR ===
# Use local nano if it exists rather than crusty system version.
VISUAL="$(command -v nano)"
EDITOR="$VISUAL"
export VISUAL
export EDITOR


# == RANDOM FIXES ==
# Fix for Debian not sourcing vte.sh.
# See https://gnunn1.github.io/tilix-web/manual/vteconfig/
if [ -f /etc/debian-version ]; then
  if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
    . /etc/profile.d/vte.sh
  fi
fi

# === MET OFFICE ===
# Needed to make VER work apparently
# Suggested by Stephen Gallagher
if command -v ver-profile > /dev/null; then
  . ver-profile
fi

# Only needed until Cylc 8 is the default.
export CYLC_VERSION=8-next

# Fix GPG pinentry when not running a GUI session.
export GPG_TTY=$(tty)

# Show useful SLURM job information.
export SACCT_FORMAT="user,jobname%40,jobid%12,elapsed,totalcpu,reqcpus%4,ncpus%4,reqmem,maxrss, state, nodelist"

# === ALIASES ===
# Flatpak aliases
if command -v flatpak > /dev/null; then
  if ! command -v inkscape > /dev/null; then
    alias inkscape='flatpak run org.inkscape.Inkscape'
  fi
  if ! command -v gimp > /dev/null; then
    alias gimp='flatpak run org.gimp.GIMP'
  fi
  if ! command -v thunderbird > /dev/null; then
    alias thunderbird='flatpak run org.mozilla.Thunderbird'
  fi
fi

# Dotfile manipulation command
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Open all the things.
alias open=xdg-open

# Use bat over cat if installed.
if command -v bat > /dev/null; then
  alias cat='bat -p'
fi

# Activates or creates a python venv with a short command.
venv() {
  activate_venv() {
    if [ -f venv/bin/activate ]; then
      . venv/bin/activate
    elif [ -f .venv/bin/activate ]; then
      . .venv/bin/activate
    elif [ -f env/bin/activate ]; then
      . env/bin/activate
    else
      echo "venv not found"
      return 1
    fi
  }

  if ! activate_venv; then
    echo "Creating venv..."
    python3 -m venv .venv
    activate_venv
    python3 -m pip install --upgrade pip --quiet
  fi
}
