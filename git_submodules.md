# Git Submodules Guide

Assume we want:

- `outer_repo` to contain `inner_repo`
- while keeping them as separate repositories.

> **Example directory structure:** `outer_repo/dir_1/dir_2/inner_repo`.

## Add the submodule for the first time

From the root of `outer_repo`, run:

```bash
git submodule add -b main https://github.com/username/inner_repo.git dir_1/dir_2/inner_repo
```

This command:

- clones `inner_repo` into the requested path;
- creates or updates `.gitmodules`; and
- stages both `.gitmodules` and the submodule's commit reference (the gitlink).

If the path already contains a valid Git repository, `git submodule add` reuses
it instead of cloning it. Authentication, when required, is handled by the
configured credential helper or SSH setup.

The resulting `.gitmodules` entry will resemble:

```ini
[submodule "dir_1/dir_2/inner_repo"]
	path = dir_1/dir_2/inner_repo
	url = https://github.com/username/inner_repo.git
	branch = main
```

Use `git submodule add` rather than creating `.gitmodules` by hand. The outer
repository must record both the configuration and the submodule commit as a
gitlink.

The `branch = main` setting is consulted by `git submodule update --remote`. It
does not make an ordinary submodule checkout follow `main`, nor does it prevent a
detached `HEAD`.

For reproducible deployments, omit `update` from `.gitmodules`. The default
`checkout` behavior places the submodule at the exact commit recorded by
`outer_repo`. Setting `update = merge` instead merges that commit into the
submodule's current branch and is more appropriate for a deliberately
branch-based workflow.

Initialization copies an `update` setting from `.gitmodules` into the clone's
local `.git/config`. Removing it from `.gitmodules` later affects new clones but
does not clear the copied setting from existing clones. Restore the default in an
existing clone with:

```bash
git config --unset-all submodule.dir_1/dir_2/inner_repo.update
```

Commit the addition in `outer_repo` after reviewing it:

```bash
git status
git commit -m "Add inner_repo submodule"
```

## Initialize an already-registered submodule

After cloning or pulling an `outer_repo` commit that already contains both
`.gitmodules` and the gitlink, run:

```bash
git submodule update --init --recursive
```

`--init` registers uninitialized submodules in the clone's local configuration.
`update` clones missing repositories and checks out their recorded commits, and
`--recursive` applies the process to nested submodules.

Alternatively, clone the outer repository and its submodules in one command:

```bash
git clone --recurse-submodules https://github.com/username/outer_repo.git
```

A detached `HEAD` inside the submodule is expected here: it ensures the checkout
matches the exact commit pinned by `outer_repo`.

## Develop inside the submodule

To make commits in `inner_repo`, attach its working tree to a branch and update
that branch normally:

```bash
cd dir_1/dir_2/inner_repo
git switch main
git pull --rebase
```

After committing and pushing changes in `inner_repo`, return to `outer_repo` and
commit its updated submodule reference. Otherwise, other clones will continue to
use the previously pinned commit.

To fetch the branch configured by `branch = main` from the outer repository and
merge it into the submodule's currently checked-out branch, use:

```bash
git submodule update --remote --merge dir_1/dir_2/inner_repo
```

Then review and commit the changed submodule reference in `outer_repo`.

## Private submodules on a deployment server

If `git submodule update --init --recursive` prompts for a GitHub username,
compare the outer repository's remote with the submodule URL:

```bash
git remote -v
git config -f .gitmodules --get-regexp '^submodule\..*\.(path|url)$'
```

An outer repository using SSH does not authenticate a submodule whose URL uses
HTTPS. SSH keys and HTTPS personal access tokens are separate credentials. A
public submodule may also clone anonymously, which can make it look as though one
credential is working across repositories when it is not.

A GitHub deploy key belongs to one repository and cannot be reused for a
different private repository. For a least-privilege deployment, create one
read-only deploy key per private repository:

```bash
ssh-keygen -t ed25519 \
  -C "droplet:inner-repo" \
  -f ~/.ssh/inner_repo_deploy \
  -N ""
```

Add the contents of `~/.ssh/inner_repo_deploy.pub` under the repository's
**Settings → Deploy keys**, leaving **Allow write access** unchecked.

When a server uses multiple deploy keys, select the correct key through an SSH
host alias in `~/.ssh/config`:

```sshconfig
Host github-inner-repo
    HostName github.com
    User git
    IdentityFile ~/.ssh/inner_repo_deploy
    IdentitiesOnly yes
```

Then override the submodule URL in that clone of `outer_repo` without changing
the shared `.gitmodules` file:

```bash
git config --local submodule.dir_1/dir_2/inner_repo.url \
  git@github-inner-repo:username/inner_repo.git
```

The name after `submodule.` must match the section name in `.gitmodules`; it is
not necessarily identical to the path. Verify the key and initialize the
submodule:

```bash
ssh -T git@github-inner-repo
GIT_TERMINAL_PROMPT=0 git submodule update --init --recursive
git submodule status --recursive
```

The local URL override keeps deployment-specific SSH aliases out of the shared
repository. Be aware that `git submodule sync` copies URLs from `.gitmodules`
back into local configuration, so the override must be reapplied after a sync.
