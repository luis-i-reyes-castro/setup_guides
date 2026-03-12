# Git Branching Guide

## Moving WIP to a new `dev` branch

We start by assuming you are in branch `main` with WIP.

### Updating main and stashing changes

```bash
git checkout main
git pull origin main
git stash
```

### Checking out and updating the branch

If branch did not exist before:
```bash
git checkout -b dev
```

If branch existed before:
```bash
git checkout dev
git pull origin dev
```

If, in addition, the branch needs updating:
* Linear history option for single-dev branches:
  ```bash
  git rebase main
  ```
* Safe option for teams of devs sharing the branch:
  ```bash
  git merge --ff-only main
  ```

### Retrieving stashed changes and commiting

```bash
git stash pop
git status
git add ...
git commit -m "Your commit message"
```

### Pushing

If the previous commit is the first one of this branch:
```bash
git push -u origin dev
```

Else, i.e., if the branch existed before:
```bash
git push origin dev
```

## Dev to Production

We start by assuming you have been working on branch `dev`, which is now ahead of `main`. You have committed and pushed your good code to the `dev` branch and it is time to bring it to production.

### Option 1: Update `dev` first (ensures clean integration)

Update dev with latest main changes:
```bash
git checkout dev
git rebase main
```

Switch to main and merge:
```bash
git checkout main
git merge dev
```

### Option 2: Merge directly (simpler)

Switch to main and ensure it's up to date:
```bash
# Switch to main and ensure it's up to date
git checkout main
git pull origin main
```

Merge `dev` into `main` according to team size:
* If you are the only dev using the `dev` branch:
  ```bash
  git merge dev
  ```
* Else, if you are part of a team using the branch:
  ```bash
  git merge --no-ff main
  ```

### Push to production and clean up

```bash
git push origin main

# Optional: delete dev branch if no longer needed
git branch -d dev            # local
git push origin --delete dev # remote
```
## Key Differences: Merge vs Rebase

| Operation | Command | Effect | When to use |
|-----------|---------|--------|-------------|
| **Merge** | `git merge branch` | Creates merge commit, preserves history | Team branches, shared work |
| **Rebase** | `git rebase branch` | Rewrites history, linear timeline | Local/solo branches before merging |
| **Fast-forward** | `git merge --ff-only` | Only merges if no divergence | When you want linear history |
| **No-fast-forward** | `git merge --no-ff` | Always creates merge commit | Team environments, feature branches |

## Common Pitfalls to Avoid

- ❌ Don't rebase shared branches (dev that others use)
- ❌ Don't merge main into dev without pulling latest main first
- ❌ Don't forget to stash uncommitted changes before switching branches
- ✅ Do pull latest changes before starting new work
- ✅ Do test thoroughly before merging to main
