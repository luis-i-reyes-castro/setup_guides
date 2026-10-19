# GitHub Credentials for Private Submodules

This guide documents how `sofia-server` uses the same `.gitmodules` file for local development and deployment while giving each environment different permissions:

- the development machine authenticates as the personal GitHub account and can push;
- the droplet uses a separate read-only deploy key for each private repository.

The committed submodule URLs contain stable SSH aliases. Each machine maps those aliases to its own credentials in `~/.ssh/config`. There are no Git URL rewrites and no repository-local URL overrides to remember.

## Repository configuration

`sofia-server/.gitmodules` contains:

```ini
# Public repos (access via HTTPS)

[submodule "backend/case_handlers/da-assistant"]
	path   = backend/case_handlers/da_assistant
	url    = https://github.com/luis-i-reyes-castro/da-assistant.git
	branch = main

# Private repos (access via SSH)

[submodule "backend/case_handlers/ieced"]
	path   = backend/case_handlers/ieced
	url    = git@github-ieced:luis-i-reyes-castro/ieced.git
	branch = main
[submodule "backend/case_handlers/tia_chatbots"]
	path   = backend/case_handlers/tia_chatbots
	url    = git@github-tia-chatbots:luis-i-reyes-castro/tia-chatbots.git
	branch = main
```

The aliases `github-ieced` and `github-tia-chatbots` deliberately do not encode an access level. The SSH configuration on each machine determines which key is used and therefore which permissions GitHub grants.

## Development machine: personal write access

Use an SSH key registered under the personal GitHub account. If the machine already has `~/.ssh/id_ed25519`, display its public half:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add that public key in GitHub under **Settings -> SSH and GPG keys -> New SSH key** as an authentication key. Never upload or copy the private file `~/.ssh/id_ed25519`.

Map both aliases to the personal key in `~/.ssh/config`:

```sshconfig
Host github-ieced github-tia-chatbots
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Protect the files and test both aliases:

```bash
chmod 600 ~/.ssh/config ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

ssh -T github-ieced
ssh -T github-tia-chatbots
```

Both tests should identify the personal account:

```text
Hi luis-i-reyes-castro! You've successfully authenticated, but GitHub does not provide shell access.
```

This identity can push because the GitHub account has write access to both repositories. The alias itself does not make a connection read-only or write-capable.

## Droplet: repository-specific read-only access

A GitHub deploy key grants access to only one repository, so each private submodule needs its own key pair. Generate the keys on the droplet:

```bash
ssh-keygen -t ed25519 \
  -C "droplet:ieced" \
  -f /root/.ssh/ieced_deploy \
  -N ""

ssh-keygen -t ed25519 \
  -C "droplet:tia-chatbots" \
  -f /root/.ssh/tia_chatbots_deploy \
  -N ""
```

For each repository, display the corresponding `.pub` file and add it under **Repository Settings -> Deploy keys**. Leave **Allow write access** unchecked:

```bash
cat /root/.ssh/ieced_deploy.pub
cat /root/.ssh/tia_chatbots_deploy.pub
```

Configure `/root/.ssh/config`:

```sshconfig
Host github-ieced
    HostName github.com
    User git
    IdentityFile /root/.ssh/ieced_deploy
    IdentitiesOnly yes

Host github-tia-chatbots
    HostName github.com
    User git
    IdentityFile /root/.ssh/tia_chatbots_deploy
    IdentitiesOnly yes
```

Set permissions:

```bash
chmod 600 \
  /root/.ssh/config \
  /root/.ssh/ieced_deploy \
  /root/.ssh/tia_chatbots_deploy
chmod 644 \
  /root/.ssh/ieced_deploy.pub \
  /root/.ssh/tia_chatbots_deploy.pub
```

Test the aliases:

```bash
ssh -T github-ieced
ssh -T github-tia-chatbots
```

GitHub should identify a different repository for each alias:

```text
Hi luis-i-reyes-castro/ieced! You've successfully authenticated, but GitHub does not provide shell access.
Hi luis-i-reyes-castro/tia-chatbots! You've successfully authenticated, but GitHub does not provide shell access.
```

GitHub's SSH test returns a nonzero status because it does not provide shell access. The successful-authentication message is the important result.

Verify read access without changing either repository:

```bash
git ls-remote git@github-ieced:luis-i-reyes-castro/ieced.git HEAD
git ls-remote git@github-tia-chatbots:luis-i-reyes-castro/tia-chatbots.git HEAD
```

## Synchronize existing clones

After changing URLs in `.gitmodules`, synchronize any existing clone before updating its submodules:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

`git submodule sync` copies the committed URLs into the clone's local Git configuration. `sofia-server/deploy_now.sh` runs it before every submodule update so that `.gitmodules` remains authoritative.

Verify the effective configuration and checked-out submodules with:

```bash
git config --show-origin --get-regexp '^submodule\..*\.url$'
git submodule status --recursive
```

## Developing inside a submodule

An ordinary submodule update checks out the commit recorded by `sofia-server`, usually with a detached `HEAD`. Before making changes, switch to the submodule's branch:

```bash
git -C backend/case_handlers/ieced switch main
git -C backend/case_handlers/ieced pull --rebase
```

Commit and push inside the submodule first. Then return to `sofia-server` and commit its updated submodule reference.

Use a dry run to verify write authorization without pushing:

```bash
git -C backend/case_handlers/ieced push --dry-run
git -C backend/case_handlers/tia_chatbots push --dry-run
```

## Troubleshooting

### Git asks for a GitHub username and password

The effective URL is HTTPS rather than the intended SSH alias. Inspect both the committed and cached values:

```bash
git config -f .gitmodules --get-regexp '^submodule\..*\.url$'
git config --show-origin --get-regexp '^submodule\..*\.url$'
```

Then synchronize and retry:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

### SSH cannot resolve an alias

The alias is missing from that machine's `~/.ssh/config`. Inspect its effective SSH configuration:

```bash
ssh -G github-ieced | grep -E '^(hostname|user|identityfile|identitiesonly) '
```

### GitHub reports `Permission denied (publickey)`

Confirm that `IdentityFile` names the intended private key and that its public half was added to the correct place:

- personal GitHub **SSH and GPG keys** for development access;
- the individual repository's **Deploy keys** for deployment access.

### GitHub identifies the wrong repository

Force SSH to test one key and no others:

```bash
ssh -T \
  -o IdentitiesOnly=yes \
  -i /root/.ssh/ieced_deploy \
  git@github.com
```

An answer such as `Hi OWNER/REPOSITORY!` identifies the repository to which that deploy key is attached.

## Why this design

- `.gitmodules` is the single source of truth for submodule URLs.
- Development and deployment use the same committed configuration.
- Per-machine SSH configuration handles the legitimate credential difference.
- The droplet receives least-privilege, read-only access to each private repo.
- Developers retain normal account-level write access.
- There are no invisible `insteadOf` rewrites or local URL overrides that can be lost after a fresh clone or `git submodule sync`.
