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

Just in case, we start by updating both branches:
```bash
git checkout dev
git pull origin dev
git checkout main
git pull origin main
```

### Option 1: Merge without Fast-Forward

Merge `dev` into `main` without fast-forwarding to force a merge commit:
```bash
git checkout main
git merge --no-ff dev
```

### Option 2: Rebase

In case we need to rewrite history:
```bash
git checkout main
git merge dev
```

### Push to production and clean up

```bash
git push origin main
```

Finally, we have the option (but not the need) to delete dev branch:
```bash
git branch -d dev            # local
git push origin --delete dev # remote
```

## Key Differences: Merge vs Rebase

| Operation | Command | Effect | When to use |
|-----------|---------|--------|-------------|
| **Merge with No-fast-forward** | `git merge <BRANCH> --no-ff` | Always creates merge commit | Team environments, feature branches |
| **Merge with Fast-forward** | `git merge <BRANCH> --ff-only` | Only merges if no divergence | When you want linear history |
| **Rebase** | `git rebase <BRANCH>` | Rewrites history, linear timeline | Local/solo branches before merging |

## Common Pitfalls to Avoid

- ❌ Don't rebase shared branches (dev that others use)
- ❌ Don't merge main into dev without pulling latest main first
- ❌ Don't forget to stash uncommitted changes before switching branches
- ✅ Do pull latest changes before starting new work
- ✅ Do test thoroughly before merging to main
