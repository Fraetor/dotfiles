#! /bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# Uncomment to profile bashrc startup speed.
# PS4='+ $EPOCHREALTIME\011 '
# exec 5> bashrc_trace.txt
# BASH_XTRACEFD="5"
# set -x

# If not running interactively, don't do anything further.
if [[ $- != *i* ]]; then
  return
fi

# Source global definitions.
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi


# === BASH OPTIONS ===
# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options.
HISTCONTROL=ignoreboth
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=1000
HISTFILESIZE=2000
# Append to the history file, don't overwrite it.
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Expand out environment variables on tab completion, rather than
# escaping them.
shopt -s direxpand

# Disable Ctrl-S stopping terminal output; I'm not using a teletype...
stty -ixon


# === TERMINAL PROMPT ===
# Source shell function for git prompt.
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  . /usr/share/git-core/contrib/completion/git-prompt.sh
  # Setup git prompt variables.
  GIT_PS1_SHOWDIRTYSTATE="y"
  GIT_PS1_STATESEPARATOR=""
  export GIT_PS1_SHOWDIRTYSTAT GIT_PS1_STATESEPARATOR
else
  # If we don't have the git prompt available, use a dummy version.
  __git_ps1 () {
    return
  }
fi

# Set a fancy prompt if we have colour support.
if [[ "$TERM" == *color* ]] ||
   [[ -n "$TERMCOLOR" ]] ||
   [[ "$(tput colors)" -ge 256 ]] ;
   then
  #      Bold Green.        Reset..     Bold Blue     Olive                       Red.....                                                      Reset..
  PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\033[38;5;3m$(__git_ps1)\n\[\033[91m\]$(ret=$?; if [ $ret -ne 0 ]; then echo "$ret"; fi)\[\033[0m\]❯ '
else
  # For really basic terminals.
  PS1='\u@\h:\w\$ '
fi
export PS1

# Limit the number of directories in the prompt to stop it growing too long.
PROMPT_DIRTRIM=3

# === CUSTOM BINARIES ===
# Set PATH so it includes user's private bin if it exists, and is not already on PATH.
if [ -d "$HOME/.local/bin" ] &&
   # Affix colons on either side of $PATH to simplify matching.
   [[ ":${PATH}:" != *:"$HOME"/.local/bin:* ]];
   then
  # Prepending path to allow overwriting old versions.
  PATH="$HOME/.local/bin:$PATH"
fi

# Include cargo binaries if they exist.
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Include pixi global binaries if they exist.
if [ -d "$HOME/.pixi/bin" ] &&
   [[ ":${PATH}:" != *:"$HOME"/.pixi/bin:* ]];
   then
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

# Prevent python leaving __pycache__ files everywhere.
PYTHONDONTWRITEBYTECODE=y
export PYTHONDONTWRITEBYTECODE

# === MET OFFICE ===
# Needed to make VER work apparently
# Suggested by Stephen Gallagher
if command -v ver-profile > /dev/null; then
  . ver-profile
fi

# Use pre-production versions of Cylc for testing.
export CYLC_VERSION=8-next
export CYLC_UISERVER_VERSION=8-next

# Show useful SLURM job information.
export SACCT_FORMAT="user,jobname%40,jobid%12,elapsed,totalcpu,reqcpus%4,ncpus%4,reqmem,maxrss, state, nodelist"

# === ALIASES ===
# Flatpak aliases.
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

# Dotfile manipulation command.
alias dotfile='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Open all the things.
alias open=xdg-open

# Remove gaudy colours from run0.
alias run0='run0 --background="" --shell-prompt-prefix=""'

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
