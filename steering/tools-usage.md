# Tools Usage

## JSON

Use `jq` for JSON parsing, querying, and validation — not Python or other
ad-hoc scripts. For example, validate a file with `jq empty file.json`.

## Search

Do not run recursive filesystem operations (`find`, `grep -r`, `ls -R`, etc.)
outside the specific codebase or package you are working in, unless you have
been explicitly instructed to do so. In particular, never recurse from the
user's home directory: it contains multiple unrelated codebases that are large
in both size and number of files, and traversing them is slow and rarely
relevant to your task.
