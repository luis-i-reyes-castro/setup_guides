# Git Fixup Guide

# Before Pushing: Commit Editing

### Scenario
* Had 3 local commits with a typo in the second commit message.
* Needed to fix the typo before pushing to remote.

### Solution Used: Interactive Rebase

```bash
# Start interactive rebase for the last 3 commits
git rebase -i HEAD~3

# Alternative: rebase from a specific commit hash
git rebase -i <commit-hash-before-typo-commit>
```

### Step-by-Step Process

1. **Identify the target commit** using `git log`:
   ```bash
   git log --oneline
   ```

2. **Start interactive rebase**:
   ```bash
   git rebase -i HEAD~3
   ```

3. **In Vim editor**:
   - Navigate with `h`, `j`, `k`, `l` or arrow keys
   - Press `i` to enter Insert mode
   - Change `pick` to `edit` for the commit with the typo
   - Press `Esc` to exit Insert mode
   - Type `:wq` and press `Enter` to save and exit

4. **Edit the commit message**:
   ```bash
   git commit --amend
   ```
   - Fix the typo in the editor
   - Save and exit (`:wq` in Vim)

5. **Continue the rebase**:
   ```bash
   git rebase --continue
   ```

### Safety Notes

| | | |
|---|---|---|
| ✅ | Safe when | You haven't pushed yet (local commits only) |
| ✅ | What changes | Commit hashes for edited commit and all subsequent commits |
| ✅ | Preserved | All your actual code changes  |
| ❌ | Avoid when | Commits are already pushed to remote (use with caution)  |
| | | |

### Verification

After rebase, always verify:
```bash
git log
git status
```

### When to Use Each Method

- **`git commit --amend`**: Only most recent commit, no other commits after it
- **`git rebase -i`**: Any commit in history, multiple commits, reordering, squashing

*Pro tip: Always review your commit messages with* `git log` *before pushing!*

## Key Commands Summary

| Command | Purpose |
|---------|---------|
| `git rebase -i HEAD~N` | Interactive rebase for last N commits |
| `git commit --amend` | Edit the most recent commit |
| `git rebase --continue` | Continue after resolving conflicts |
| `git log --oneline` | Compact commit history view |

## Vim Basics for Git Operations

| Action | Vim Command |
|--------|-------------|
| Enter Insert mode | `i` |
| Exit Insert mode | `Esc` |
| Save and quit | `:wq` + `Enter` |
| Quit without saving | `:q!` + `Enter` |
| Navigation | `h`(left), `j`(down), `k`(up), `l`(right) |

### Alternative: Change Default Editor

```bash
# Temporary change for one command
GIT_EDITOR=nano git rebase -i HEAD~3

# Permanent change (add to ~/.bashrc or ~/.zshrc)
export GIT_EDITOR=nano
```

# After Pushing: Soft Reset and Push-force with Lease

### Scenario
* Last 3 commits were already pushed.
* Needed to replace them with a single commit.

### Commands Used

```bash
git reset --soft HEAD~3
git commit -m "Docs: add local /docs chatbot examples and remove private repo references"
git push --force-with-lease origin main
```

### What Each Command Does

1. `git reset --soft HEAD~3`
   - Moves `HEAD` back 3 commits.
   - Keeps all changes from those commits staged.
   - No file content is lost.

2. `git commit -m "..."`
   - Creates one new commit from the staged combined changes.

3. `git push --force-with-lease origin main`
   - Rewrites remote `main` to match your new local history.
   - Safer than `--force`: it aborts if remote changed unexpectedly.

### Note on Single-Developer Repos

In a single-developer repo, plain `--force` can work and `--force-with-lease`
may feel unnecessary. Still, `--force-with-lease` is usually recommended as a
safe default because it protects you from accidentally overwriting remote
changes (for example, commits made from another machine/session).
