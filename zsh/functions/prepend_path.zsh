#!/usr/bin/env zsh

prepend_path() {
    [[ ! -d "$1" ]] && return

    path=(
        $1
        $path
    )
}