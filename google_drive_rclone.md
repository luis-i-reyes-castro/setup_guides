# Google Drive mounts with rclone

This guide mounts Google Drive as a normal filesystem on Ubuntu or macOS, including a specific folder from **Shared with me**. The resulting directories work with ordinary shell tools such as `ls`, `cp`, and scripts.

The setup uses rclone's shared Google OAuth client, so it does not require creating or publishing a Google Cloud application. This is currently a temporary convenience: rclone has announced that its shared Google Drive client ID will stop working during 2026. See the caveat at the end of this guide.

## Why rclone?

On Ubuntu, GNOME Online Accounts mounts Drive successfully and works well in the Files application. However, its GVfs filesystem exposes Google object IDs rather than human-readable names to ordinary shell tools. Google does not provide Drive for desktop on Linux.

On macOS, Google Drive for desktop is another option, but rclone gives the same remote names, command-line workflow, and explicit mount configuration used on Ubuntu.

## Ubuntu: install rclone and FUSE

These instructions were tested on Ubuntu 24.04 with FUSE 3:

```bash
sudo apt install fuse3 curl unzip
```

Ubuntu's standard `~/.profile` adds `~/.local/bin` to `PATH` when the directory exists. Log out and back in after creating it, or add it to the current shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

The setup used rclone 1.75.2. Check the [rclone downloads page](https://rclone.org/downloads/) and replace the version below when installing a newer release.

```bash
version=1.75.2
workdir=$(mktemp -d)
archive="rclone-v${version}-linux-amd64.zip"

curl -fsSLo "$workdir/$archive" \
  "https://downloads.rclone.org/v${version}/$archive"
curl -fsSLo "$workdir/SHA256SUMS" \
  "https://downloads.rclone.org/v${version}/SHA256SUMS"

expected=$(awk -v file="$archive" '$2 == file {print $1}' \
  "$workdir/SHA256SUMS")
actual=$(sha256sum "$workdir/$archive" | awk '{print $1}')
test -n "$expected" && test "$expected" = "$actual"

unzip -q "$workdir/$archive" -d "$workdir"
mkdir -p "$HOME/.local/bin"
install -m 0755 \
  "$workdir/rclone-v${version}-linux-amd64/rclone" \
  "$HOME/.local/bin/rclone"

rclone version
```

## macOS: install rclone

Install rclone with Homebrew:

```bash
brew install rclone
mkdir -p "$HOME/.local/bin"
ln -sf "$(brew --prefix)/bin/rclone" "$HOME/.local/bin/rclone"
"$HOME/.local/bin/rclone" version
"$HOME/.local/bin/rclone" nfsmount --help
```

Homebrew's macOS build intentionally omits the FUSE-based `rclone mount` command. Use `rclone nfsmount` as shown below instead. It uses macOS's built-in NFS client, is the method recommended by rclone for macOS, and does not require macFUSE.

If `nfsmount` is missing, update Homebrew and rclone:

```bash
brew update
brew upgrade rclone
"$HOME/.local/bin/rclone" nfsmount --help
```

## Authorize Google Drive on either operating system

Run:

```bash
rclone config
```

Use these answers:

1. Create a new remote and name it `gdrive`.
2. Select `drive` (Google Drive) as the storage type.
3. Leave the client ID and client secret blank.
4. Confirm that the shared rclone client ID should be used.
5. Select full Drive access.
6. Leave the service-account file blank.
7. Allow rclone to open a local browser and approve access in Google.
8. Do not configure it as a Shared Drive unless the target is an actual Google Workspace Shared Drive.

Verify the remote before mounting it:

```bash
rclone listremotes
rclone lsd gdrive:
rclone lsf "gdrive:LBB-simulations" \
  --drive-shared-with-me --max-depth 1
```

The token is stored in `~/.config/rclone/rclone.conf`. Treat that file as a secret and do not commit or share it.

## Ubuntu: mount My Drive automatically

Create the mount and state directories:

```bash
mkdir -p "$HOME/GoogleDrive" "$HOME/.cache/rclone"
mkdir -p "$HOME/.local/state/rclone" "$HOME/.config/systemd/user"
```

Create `~/.config/systemd/user/rclone-gdrive.service`:

```ini
[Unit]
Description=Mount Google Drive with rclone
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
ExecStart=%h/.local/bin/rclone mount gdrive: %h/GoogleDrive \
    --vfs-cache-mode=writes --cache-dir=%h/.cache/rclone \
    --dir-cache-time=5m --poll-interval=1m \
    --log-file=%h/.local/state/rclone/gdrive.log --log-level=INFO
ExecStop=/bin/fusermount3 -u %h/GoogleDrive
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

Enable and test it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
systemctl --user status rclone-gdrive.service
findmnt -T "$HOME/GoogleDrive"
ls -lah "$HOME/GoogleDrive"
```

## Ubuntu: mount LBB-simulations automatically

Items under **Shared with me** are not part of My Drive. Create a separate mountpoint and cache. A separate mount avoids creating a fake directory in My Drive and prevents the two mounts from sharing a VFS cache:

```bash
mkdir -p "$HOME/LBB-simulations" "$HOME/.cache/rclone-lbb"
```

Create `~/.config/systemd/user/rclone-gdrive-lbb.service`:

```ini
[Unit]
Description=Mount shared Google Drive folder LBB-simulations with rclone
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
ExecStart=%h/.local/bin/rclone mount gdrive:LBB-simulations \
    %h/LBB-simulations --drive-shared-with-me \
    --vfs-cache-mode=writes --cache-dir=%h/.cache/rclone-lbb \
    --dir-cache-time=5m --poll-interval=1m \
    --log-file=%h/.local/state/rclone/gdrive-lbb.log --log-level=INFO
ExecStop=/bin/fusermount3 -u %h/LBB-simulations
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

Enable and verify it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive-lbb.service
systemctl --user status rclone-gdrive-lbb.service
findmnt -T "$HOME/LBB-simulations"
ls -lah "$HOME/LBB-simulations"
```

The mount can only write when the folder owner granted edit permission.

## macOS: create mount scripts

The launch agents in the next section keep rclone in the foreground so `launchd` can monitor and restart it. Create the directories first:

```bash
mkdir -p "$HOME/.local/bin" "$HOME/GoogleDrive" "$HOME/LBB-simulations"
mkdir -p "$HOME/Library/Caches/rclone"
mkdir -p "$HOME/Library/Caches/rclone-lbb"
mkdir -p "$HOME/Library/Logs/rclone"
mkdir -p "$HOME/Library/LaunchAgents"
```

Create `~/.local/bin/rclone-mount-gdrive`:

```zsh
#!/bin/zsh
set -eu

exec "$HOME/.local/bin/rclone" nfsmount gdrive: "$HOME/GoogleDrive" \
  --vfs-cache-mode=writes \
  --cache-dir="$HOME/Library/Caches/rclone" \
  --dir-cache-time=5m \
  --poll-interval=1m \
  --log-file="$HOME/Library/Logs/rclone/gdrive.log" \
  --log-level=INFO
```

Create `~/.local/bin/rclone-mount-gdrive-lbb`:

```zsh
#!/bin/zsh
set -eu

exec "$HOME/.local/bin/rclone" nfsmount \
  "gdrive:LBB-simulations" "$HOME/LBB-simulations" \
  --drive-shared-with-me \
  --vfs-cache-mode=writes \
  --cache-dir="$HOME/Library/Caches/rclone-lbb" \
  --dir-cache-time=5m \
  --poll-interval=1m \
  --log-file="$HOME/Library/Logs/rclone/gdrive-lbb.log" \
  --log-level=INFO
```

Make both scripts executable:

```bash
chmod 0755 "$HOME/.local/bin/rclone-mount-gdrive"
chmod 0755 "$HOME/.local/bin/rclone-mount-gdrive-lbb"
```

Test each script in one Terminal window, verify its mount from another window, and then press `Control-C` in the first window before testing the other script.

First Terminal window:

```bash
"$HOME/.local/bin/rclone-mount-gdrive"
"$HOME/.local/bin/rclone-mount-gdrive-lbb"
```

Second Terminal window:

```bash
ls -lah "$HOME/GoogleDrive"
ls -lah "$HOME/LBB-simulations"
```

## macOS: start both mounts at login

Create `~/Library/LaunchAgents/local.rclone.gdrive.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.rclone.gdrive</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>exec "$HOME/.local/bin/rclone-mount-gdrive"</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ThrottleInterval</key>
  <integer>10</integer>
</dict>
</plist>
```

Create `~/Library/LaunchAgents/local.rclone.gdrive-lbb.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>local.rclone.gdrive-lbb</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>exec "$HOME/.local/bin/rclone-mount-gdrive-lbb"</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ThrottleInterval</key>
  <integer>10</integer>
</dict>
</plist>
```

Validate, load, and inspect both launch agents:

```bash
plutil -lint "$HOME/Library/LaunchAgents/local.rclone.gdrive.plist"
plutil -lint "$HOME/Library/LaunchAgents/local.rclone.gdrive-lbb.plist"

launchctl bootstrap "gui/$(id -u)" \
  "$HOME/Library/LaunchAgents/local.rclone.gdrive.plist"
launchctl bootstrap "gui/$(id -u)" \
  "$HOME/Library/LaunchAgents/local.rclone.gdrive-lbb.plist"

launchctl print "gui/$(id -u)/local.rclone.gdrive"
launchctl print "gui/$(id -u)/local.rclone.gdrive-lbb"
ls -lah "$HOME/GoogleDrive"
ls -lah "$HOME/LBB-simulations"
```

After editing a mount script, restart its loaded service:

```bash
launchctl kickstart -k "gui/$(id -u)/local.rclone.gdrive"
launchctl kickstart -k "gui/$(id -u)/local.rclone.gdrive-lbb"
```

After editing a property list, unload and bootstrap that agent again so `launchd` reads the new settings:

```bash
launchctl bootout "gui/$(id -u)/local.rclone.gdrive"
launchctl bootstrap "gui/$(id -u)" \
  "$HOME/Library/LaunchAgents/local.rclone.gdrive.plist"
```

To unload the agents and unmount both directories:

```bash
launchctl bootout "gui/$(id -u)/local.rclone.gdrive"
launchctl bootout "gui/$(id -u)/local.rclone.gdrive-lbb"
```

If an interrupted process leaves a stale NFS mount, close shells and applications using it, then run:

```bash
umount "$HOME/GoogleDrive"
umount "$HOME/LBB-simulations"
```

## Copy and verify large directory trees

For large uploads, use rclone directly instead of `cp` through either mounted filesystem. It provides retries, checksums, and explicit verification:

```bash
rclone copy "$HOME/Downloads/example" \
  "gdrive:LBB-simulations/example" \
  --drive-shared-with-me --transfers 4 --checkers 8

rclone check "$HOME/Downloads/example" \
  "gdrive:LBB-simulations/example" \
  --drive-shared-with-me --one-way
```

`copy` does not delete destination files. Do not use `sync` unless destination deletion is intentional.

## Maintenance and troubleshooting

On Ubuntu:

```bash
# Restart mounts
systemctl --user restart rclone-gdrive.service
systemctl --user restart rclone-gdrive-lbb.service

# Follow logs
tail -f "$HOME/.local/state/rclone/gdrive.log"
tail -f "$HOME/.local/state/rclone/gdrive-lbb.log"

# Stop and unmount
systemctl --user stop rclone-gdrive.service
systemctl --user stop rclone-gdrive-lbb.service
```

On macOS:

```bash
# Follow logs
tail -f "$HOME/Library/Logs/rclone/gdrive.log"
tail -f "$HOME/Library/Logs/rclone/gdrive-lbb.log"

# Inspect launch-agent state
launchctl print "gui/$(id -u)/local.rclone.gdrive"
launchctl print "gui/$(id -u)/local.rclone.gdrive-lbb"
```

Changes made through another Drive client can take up to the polling interval to appear. Restarting a mount forces a fresh view if necessary.

## Shared OAuth client retirement

rclone has announced that its built-in Google Drive client ID will stop working during 2026. When that happens, existing mounts will need either:

- a personal Google OAuth desktop client ID; or
- a maintained third-party client that supplies its own approved OAuth app.

Creating a personal OAuth client is the durable free option, but it reintroduces Google Cloud Console setup. Track the current status in the [rclone Google Drive documentation](https://rclone.org/drive/) and [upstream retirement issue](https://github.com/rclone/rclone/issues/9580).

## References

- [rclone installation](https://rclone.org/install/)
- [rclone Google Drive backend](https://rclone.org/drive/)
- [rclone mount](https://rclone.org/commands/rclone_mount/)
- [rclone nfsmount](https://rclone.org/commands/rclone_nfsmount/)
- [Apple launch agents](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
