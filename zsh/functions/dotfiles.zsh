#!/usr/bin/env zsh

# Inspired by
# https://github.com/ohmyzsh/ohmyzsh/blob/f21e646ce6c09198f7f625c597f08af49551fdb0/lib/cli.zsh

function dotfiles {
  [[ $# -gt 0 ]] || {
    _dotfiles::help
    return 1
  }

  local command="$1"
  shift

  # Subcommand functions start with _ so that they don't
  # appear as completion entries when looking for `dotfiles`
  (( $+functions[_dotfiles::$command] )) || {
    _dotfiles::help
    return 1
  }

  _dotfiles::$command "$@"
}

function _dotfiles {
  local -a cmds subcmds
  cmds=(
    'help:Usage information'
    'update:Update dotfiles'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  fi

  return 0
}

function _dotfiles::update {
  $DOTFILES/tools/update
}

# _dotfiles::help() {
#     echo -e "Hello from dotfiles::help command"
# }

function _dotfiles::help {
  cat <<EOF
Usage: dotfiles <command> [options]
Available commands:
  help                Print this help message
  update              Update dotfiles
EOF
}