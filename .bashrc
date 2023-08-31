#! /bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# === BASH COMPLETIONS ===
# enable programmable completion features (you don't need to enable
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
prompt_nonzero_return() {
  return_val=$?
  if [ $return_val -ne 0 ]; then
    printf "\001\033[48;2;207;73;34m\002\001\033[38;2;196;233;12m\002\001\033[38;2;255;255;255m\002 $return_val \001\033[0m\002\001\033[38;2;207;73;34m\002\001\033[0m\002"
  else
    printf "\001\033[38;2;196;233;12m\002\001\033[0m\002"
  fi
}
if [ "$color_prompt" = yes ]; then
  PS1="\[\033[1m\]\[\033[48;2;42;42;42m\]\[\033[38;2;196;233;12m\] \u \[\033[48;2;196;233;12m\]\[\033[38;2;42;42;42m\] \w \[\033[0m\]\$(prompt_nonzero_return) "
else
  PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
export PS1

# enable color support of ls and also add handy aliases
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
# Set PATH so it includes user's private bin if it exists.
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

# Needed to get Android studio emulator working without booking the full IDE.
if [ -d "$HOME/.local/share/Android/Sdk/" ]; then
  export ANDROID_HOME=/home/james/.local/share/Android/Sdk/
fi


# === MET OFFICE ===

# Needed to make VER work apparently
# Suggested by Stephen Gallagher
. ver-profile

# Only needed until Cylc 8 is the default.
export CYLC_VERSION=8

# As much as I love it, I mistype too much.
alias sl=false


# === ALIASES ===
# Running on local temp space really speeds up tox.
alias tox="tox --workdir /tmp/persistent/tox"

# Flatpak aliases
if command -v flatpak > /dev/null; then
  if command -v inkscape > /dev/null; then
    alias inkscape='flatpak run org.inkscape.Inkscape'
  fi
  if command -v gimp > /dev/null; then
    alias gimp='flatpak run org.gimp.GIMP'
  fi
fi

# Activates a python venv with a short command.
venv() {
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

# Dotfile manipulation command
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Open all the things.
alias open=xdg-open
