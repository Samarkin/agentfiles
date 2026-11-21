#!/usr/bin/env bash
# Hardlink steering files into the Kiro and Claude config directories,
# and install the Claude status line.

set -euo pipefail
shopt -s nullglob

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src_dir="$repo_dir/steering"

link_file() {
    local src="$1" dst="$2"

    if [[ "$src" -ef "$dst" ]]; then
        echo "Already linked: $dst"
    elif [[ -e "$dst" || -L "$dst" ]]; then
        echo "WARNING: $dst exists and is not a hardlink of $src, skipping" >&2
    else
        ln "$src" "$dst"
        echo "Linked: $dst"
    fi
}

install_to() {
    local config_dir="$1" target_dir="$2"

    if [[ ! -d "$config_dir" ]]; then
        echo "Skipping $target_dir: $config_dir does not exist"
        return
    fi

    mkdir -p "$target_dir"

    local src
    for src in "$src_dir"/*; do
        [[ -f "$src" ]] || continue
        link_file "$src" "$target_dir/$(basename "$src")"
    done
}

install_claude_statusline() {
    local claude_dir="$HOME/.claude"
    local settings="$claude_dir/settings.json"
    local expected='{"type": "command", "command": "bash ~/.claude/statusline-command.sh"}'

    if [[ ! -d "$claude_dir" ]]; then
        echo "Skipping status line: $claude_dir does not exist"
        return
    fi

    link_file "$repo_dir/settings/claude-statusline.sh" "$claude_dir/statusline-command.sh"

    if ! command -v jq > /dev/null; then
        echo "ERROR: jq is not installed, cannot configure statusLine in $settings" >&2
        return
    fi

    [[ -s "$settings" ]] || echo '{}' > "$settings"
    if ! jq -e 'type == "object"' "$settings" > /dev/null; then
        echo "ERROR: $settings is not a JSON object, cannot configure statusLine" >&2
        return
    fi

    if ! jq -e 'has("statusLine")' "$settings" > /dev/null; then
        local updated
        updated="$(jq --argjson value "$expected" '.statusLine = $value' "$settings")"
        printf '%s\n' "$updated" > "$settings"
        echo "Configured: statusLine in $settings"
    elif jq -e --argjson value "$expected" '.statusLine == $value' "$settings" > /dev/null; then
        echo "Skipped: statusLine in $settings is already configured"
    else
        echo "ERROR: $settings defines a different statusLine; expected: $expected" >&2
    fi
}

install_to "$HOME/.kiro" "$HOME/.kiro/steering"
install_to "$HOME/.claude" "$HOME/.claude/rules"
install_claude_statusline
