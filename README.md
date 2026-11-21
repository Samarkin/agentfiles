# Agent files

Shared steering files (coding style, tool usage, and other instructions) for AI coding agents.

## Usage

### To install

1. Make sure `~/.agentfiles` does not exist.
2. Execute the following commands:
```
git clone https://github.com/Samarkin/agentfiles ~/.agentfiles
~/.agentfiles/install.sh
```

The script hardlinks every file from `~/.agentfiles/steering` into `~/.kiro/steering`
and `~/.claude/rules`. An agent whose config directory does not exist is skipped,
and existing files that are not already hardlinks are left untouched.

For Claude, it also hardlinks `settings/claude-statusline.sh` to `~/.claude/statusline-command.sh`
and, using `jq`, adds a `statusLine` entry that runs it to `~/.claude/settings.json`.
If `settings.json` already defines a different `statusLine`, the script leaves it as is
and reports an error.

### To update

```
cd ~/.agentfiles
git pull
./install.sh
```

Existing hardlinks pick up `git pull` changes automatically; re-running `install.sh`
only links files that were added since the last install.

### To uninstall

```
for d in ~/.kiro/steering ~/.claude/rules; do for f in ~/.agentfiles/steering/*; do [ "$f" -ef "$d/$(basename $f)" ] && rm "$d/$(basename $f)"; done; done
rm -rf ~/.agentfiles
```

This does not delete the Claude status line script.

## Compatibility

It currently supports Kiro and Claude.
