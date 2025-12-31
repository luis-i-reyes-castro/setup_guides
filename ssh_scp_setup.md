# SSH + SCP Setup between Ubuntu and macOS in Home Network

This guide documents how to set up **reliable, passwordless, IP-independent SSH connections** between:
* **Ubuntu desktop** (e.g. 24.04)
* **macOS laptop** (e.g. macOS 15+)

Primary use cases:
* Securely copying `.env` files
* Syncing project folders with `rsync`
* Bidirectional transfers
* No dependency on static IPs or router admin access

## 0. Preconditions

* Both machines are on the **same home LAN**
* You have **terminal access** on both
* User account exists on both machines (e.g. `luis`)
* Router admin access is **NOT required**

## 1. Enable SSH servers

### Ubuntu (receiver or sender)

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
```

Verify:
```bash
systemctl status ssh
```

### macOS (receiver or sender)

Enable **Remote Login**:

**System Settings → General → Sharing → Remote Login → ON**

or via terminal:

```bash
sudo systemsetup -setremotelogin on
```

## 2. Generate SSH keys (on BOTH machines)

Check if a key already exists:
```bash
ls ~/.ssh/id_ed25519.pub
```

If missing, generate:
```bash
ssh-keygen -t ed25519 -C "<machine-name>"
```

Accept defaults (press Enter).


## 3. Copy SSH keys (passwordless login)

### Ubuntu → macOS

```bash
ssh-copy-id luis@macbook-air.local
```

(or IP if `.local` not ready yet)

### macOS → Ubuntu

```bash
ssh-copy-id luis@ubuntu-desktop.local
```

After this, both directions should allow:
```bash
ssh luis@<other-machine>
```

with **no password prompt**.

## 4. Set stable hostnames (IMPORTANT)

This avoids IP changes breaking SSH.

### macOS hostname

Check:
```bash
scutil --get HostName
scutil --get LocalHostName
```

Set if needed:
```bash
sudo scutil --set HostName macbook-air
sudo scutil --set LocalHostName macbook-air
```

Reboot or reconnect Wi-Fi once.

### Ubuntu hostname

```bash
sudo hostnamectl set-hostname ubuntu-desktop
```

Restart hostname + mDNS:
```bash
sudo systemctl restart systemd-hostnamed avahi-daemon
```

## 5. Ensure mDNS (`.local`) works

### Ubuntu side (Avahi)

```bash
sudo apt install avahi-daemon avahi-utils libnss-mdns
sudo systemctl enable --now avahi-daemon
```

Verify:
```bash
ping ubuntu-desktop.local
```

### macOS cache reset (after hostname changes)

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### Cross-check

From **Ubuntu**:
```bash
ping macbook-air.local
```

From **macOS**:
```bash
ping ubuntu-desktop.local
```

## 6. SSH aliases (quality-of-life)

### On Ubuntu: `~/.ssh/config`

```ssh
Host macbook
    HostName macbook-air.local
    User luis
```

### On macOS: `~/.ssh/config`

```ssh
Host ubuntu
    HostName ubuntu-desktop.local
    User luis
```

> ⚠️ SSH aliases apply **only** to `ssh`, `scp`, `rsync` — not `ping`.

## 7. Copy `.env` files with `scp`

### Ubuntu → Mac

```bash
scp .env macbook:~/projects/myapp/.env
```

### Mac → Ubuntu

```bash
scp .env ubuntu:~/projects/myapp/.env
```

## 8. Sync folders with `rsync` (recommended)

### Ubuntu → Mac

```bash
rsync -av \
  --exclude ".git" \
  --exclude ".venv" \
  --exclude "__pycache__" \
  ./ macbook:~/projects/myapp/
```

### Mac → Ubuntu

```bash
rsync -av \
  ./ ubuntu:~/projects/myapp/
```

### Safe preview

```bash
rsync -av --dry-run ./ macbook:~/projects/myapp/
```

## 9. Optional: project-level `.env` sync script

```bash
#!/usr/bin/env bash
set -e

PROJECT=$(basename "$PWD")
scp .env macbook:~/projects/$PROJECT/.env
echo "✅ .env synced"
```

```bash
chmod +x sync-env.sh
```

Run:
```bash
./sync-env.sh
```

## 10. Common pitfalls & fixes

| Issue                                      | Cause               | Fix                               |
| ------------------------------------------ | ------------------- | --------------------------------- |
| `ping macbook` fails                       | SSH alias ≠ DNS     | Use `ping macbook.local`          |
| `.local` not resolving                     | Avahi not restarted | Restart `avahi-daemon`            |
| Password prompt                            | Key not copied      | Re-run `ssh-copy-id`              |
| Worked before, broke after hostname change | mDNS cache          | Restart Avahi + flush macOS cache |

## 11. Mental model (remember this)

* `~/.ssh/config` → SSH **nicknames only**
* `.local` → LAN device discovery (mDNS)
* `scp` and `rsync` → SSH under the hood
* IPs are fragile → **hostnames are not**
