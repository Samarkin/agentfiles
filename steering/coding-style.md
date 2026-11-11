# Coding Style

## Comments

Apply these rules regardless of the programming language.

Guiding principle: a comment must reduce the total effort to understand and
maintain the code. If it does not, do not write it. Every comment is technical
debt — it can drift out of sync with the code, so each one must earn its place.

### When to write a comment

Only write a comment in one of these cases:

1. **The code is not self-explanatory.** Add a short, single-line comment in
   the imperative mood that states the code's intent or purpose rather than its
   mechanism.
   Requires a comment:
   ```vimrc
   " enable focus reporting when entering Vim
   let &t_fe="\e[?1004h"
   ```
   Reads like English, needs NO comment:
   ```python
   dir = dir.rstrip("/")
   ```
2. **A block has grown long.** Separate logically-independent parts with an
   empty line, each preceded by a single-line comment that titles the part
   without describing its internal mechanism.
   ```c++
   // Get all entities
   std::vector<fs::path> entities = ...;

   // Process directories
   for (const auto& entry : entities) {
       if (entry.is_directory()) {
           . . .
       }
   }

   // Process files
   for (const auto& entry : entities) {
       if (!entry.is_directory()) {
           . . .
       }
   }
   ```
3. **The code looks contradictory or unnecessary.** Explain *why* it was
   written that way. Be concise and prefer single-line comments where possible.
   Explain the code, not the bug. Do not include the entire reasoning chain.
   Prefer linking to a ticket, spec, or bug report when one justifies the code.
   ```javascript
   const result = externalLibrary.getValue();

   // getValue is documented never to return null, but has returned it in production
   if (result == null) {
       return;
   }
   ```
4. **A public API surface needs documentation.** Exported functions, types, and
   modules may carry doc comments describing behavior, parameters, and contracts
   even when the body is self-explanatory — the audience is callers who read the
   signature and doc, not the implementation.

Do NOT write a comment that restates what the code already spells out
(`i += 1  // increment i`) or narrates control flow the syntax makes obvious.

Never turn these into comments — a comment describes the code as it stands now,
not the process that produced it:

- **No history.** Describe only the current code, never how it used to be or
  how it changed. When you modify or delete code, do not explain what the old
  code did or why you replaced it. Historical and change-rationale information
  belongs in the git commit message, not in the source.
- **No discarded alternatives.** Do not list approaches you considered and
  rejected. When the chosen solution is one a reader would plausibly arrive at
  first, say nothing about the options you did not take. (The one exception is
  case 3 above: when the code looks contradictory or unnecessary, explain why —
  but keep it to the specific surprising decision, not a survey of rejected
  designs.)

### How to write a comment

- **Keep it local and independent.** Describe what the code does and guarantees
  on its own terms, so it stays correct when surrounding code evolves. Do not
  reference current callers ("called by the checkout flow") or assume how the
  code is used today — those break silently when usage changes.
- **Tie comments to stable facts.** Prefer intent, rationale, and contracts
  over volatile details (exact values, counts, line references). When a comment
  must mention something mutable, anchor it to a checkable source of truth
  ("keep in sync with `Config.MAX_RETRIES`") so drift is detectable.
- **Place and prune deliberately.** Keep a comment adjacent to the exact code
  it describes, so a change sits next to the comment it may invalidate. Delete
  comments that no longer hold rather than leaving them stale.
- **Never leave commented-out code.** Delete it — version control remembers.
  Mark deferred work with `TODO` plus enough context to act on it later.
