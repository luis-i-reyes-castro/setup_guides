# Secure Shell (SSH)

Directory location: `~/.ssh`
Directory structure:
```text
.ssh/
authorized_keys
config
```

### File `authorized_keys`

Here we put the **public** keys of the users authorized to **log into** this machine via SSH. Example:
```text
ssh-ed25519 AAAA... user-01@machine-01
ssh-ed25519 AAAA... user-02@machine-02
```

### Generating Keys

Run:
```bash
ssh-keygen -t ed25519 -C "<machine-name>"
```

Files produced:
```bash
id_ed25519     # Private key
id_ed25519.pub # Public key
```

### Hostnames

Here we put the **public** IP Addresses of the to which we have been granted access.
```
Host <Host Name>
    HostName <IP Address>
    User <username>
```
