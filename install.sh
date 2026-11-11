#!/usr/bin/env bash
# Hardlink steering files into the Kiro and Claude config directories.

set -euo pipefail
shopt -s nullglob

src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steering"

install_to() {
    local config_dir="$1" target_dir="$2"

    if [[ ! -d "$config_dir" ]]; then
        echo "Skipping $target_dir: $config_dir does not exist"
        return
    fi

    mkdir -p "$target_dir"

    local src dst
    for src in "$src_dir"/*; do
        [[ -f "$src" ]] || continue
        dst="$target_dir/$(basename "$src")"

        if [[ "$src" -ef "$dst" ]]; then
            echo "Already linked: $dst"
        elif [[ -e "$dst" || -L "$dst" ]]; then
            echo "WARNING: $dst exists and is not a hardlink of $src, skipping" >&2
        else
            ln "$src" "$dst"
            echo "Linked: $dst"
        fi
    done
}

install_to "$HOME/.kiro" "$HOME/.kiro/steering"
install_to "$HOME/.claude" "$HOME/.claude/rules"
