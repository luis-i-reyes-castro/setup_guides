## Fix: Terminal, Dark Mode, Dir Colors Too Dark

* Change directory color via `dircolors`
* This is the *correct* Linux way and survives reboots.

### 1️⃣ Create your own `~/.dircolors`

```bash
dircolors -p > ~/.dircolors
```

### 2️⃣ Edit it

```bash
gedit ~/.dircolors
```

Find the line:

```text
DIR 01;34 #directory
```

`34` = dark blue → bad on black.

Replace it with something more visible, for example:

**Bright cyan**

```text
DIR 01;96
```

**Bright green**

```text
DIR 01;92
```

**Bright yellow**

```text
DIR 01;93
```

Save and exit.

### 3️⃣ Activate it

Add this to **`~/.bashrc`** (near the bottom is fine):

```bash
eval "$(dircolors ~/.dircolors)"
```

Reload:

```bash
source ~/.bashrc
```

✔ Directories will now be clearly visible.

### 🔍 Color code cheat-sheet (use after `01;`)

| Color          | Code |
| -------------- | ---- |
| Bright blue    | `94` |
| Bright cyan    | `96` |
| Bright green   | `92` |
| Bright yellow  | `93` |
| Bright magenta | `95` |
| White          | `97` |
