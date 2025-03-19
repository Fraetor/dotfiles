#! /bin/sh
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# If running bash include .bashrc if it exists.
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
	  . "$HOME/.bashrc"
  fi
fi

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

# Include Haskell binaries if they exist.
if [ -f "$HOME/.ghcup/env" ]; then
  . "$HOME/.ghcup/env"
fi

export PATH
