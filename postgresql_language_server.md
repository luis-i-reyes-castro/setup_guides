# PostgreSQL Language Server in Cursor (Linux) with psycopg Named Parameters

## Goal

Enable:

* SQL linting
* Go To Definition
* Find References
* Hover documentation

for PostgreSQL code in Cursor, while supporting psycopg named parameters such as:

```sql
%(ruc)s
%(codigo)s
%(id_codigo)s
```

## Problem

The Supabase PostgreSQL Language Server works well for schema navigation but treats psycopg placeholders as syntax errors because they are not valid PostgreSQL syntax.

The older `vscode-plpgsql-lsp` extension supports custom query parameter patterns, making it a better fit for SQL template files used by Python applications.

## Environment

* OS: Ubuntu Linux x86_64
* IDE: Cursor
* Database: Supabase PostgreSQL
* Driver: psycopg3
* SQL files stored in repository (e.g. `backend/sql/...`)

## Installation

### 1. Download the Linux VSIX

Do not use the generic VSIX download. Use this:

```
https://marketplace.visualstudio.com/_apis/public/gallery/publishers/uniquevision/vsextensions/vscode-plpgsql-lsp/2.11.3/vspackage?targetPlatform=linux-x64
```

For mac (arm64):
```
https://marketplace.visualstudio.com/_apis/public/gallery/publishers/uniquevision/vsextensions/vscode-plpgsql-lsp/2.11.3/vspackage?targetPlatform=darwin-arm64
```

The default Marketplace download may install a macOS ARM build, which produces:

```text
invalid ELF header
```

Verify the downloaded file is the Linux build:

```bash
mkdir /tmp/plpgsql-test
cd /tmp/plpgsql-test

unzip ~/Downloads/uniquevision.vscode-plpgsql-lsp-2.11.3@linux-x64.vsix >/dev/null

file extension/server/out/*.node
```

Expected output:

```text
ELF 64-bit LSB shared object, x86-64
```

Incorrect output:

```text
Mach-O 64-bit arm64 bundle
```

If you see `Mach-O`, you downloaded the macOS version.

### 2. Install the extension

In Cursor:

```text
Ctrl+Shift+P
Extensions: Install from VSIX...
```

Important:

Use:

```text
Extensions: Install from VSIX...
```

NOT:

```text
Developer: Install Extension from Location...
```

The latter expects an unpacked extension directory and will not work for a VSIX file.

Select:

```text
~/Downloads/uniquevision.vscode-plpgsql-lsp-2.11.3@linux-x64.vsix
```

### 3. Disable conflicting PostgreSQL language servers

Disable the Supabase PostgreSQL Language Server for the workspace to avoid multiple language servers processing the same SQL files.

## Configuration

Open Cursor Settings JSON and add:

```json
{
    "plpgsqlLanguageServer.queryParameterPattern":
        "%\\([A-Za-z_][A-Za-z0-9_]*\\)s"
}
```

This tells the language server to recognize:

```sql
%(ruc)s
%(codigo)s
%(search)s
%(id_codigo)s
```

as query parameters.

## Per-file configuration

At the top of SQL template files, add:

```sql
/* plpgsql-language-server:use-query-parameter */
```

Example:

```sql
/* plpgsql-language-server:use-query-parameter */

SELECT
    *
FROM
    customer
WHERE
    ruc = %(ruc)s;
```

Without this comment, the language server may still report syntax errors on psycopg placeholders.

## Verification

Open a SQL file containing:

```sql
%(ruc)s
```

Expected behavior:

* No syntax errors on placeholders
* Hover information works
* Go To Definition works
* Find References works (where supported)

## Troubleshooting

### Error: "invalid ELF header"

Check the architecture of the installed native module:

```bash
file ~/.cursor/extensions/uniquevision.vscode-plpgsql-lsp-*/server/out/*.node
```

Linux build:

```text
ELF 64-bit LSB shared object, x86-64
```

Wrong build:

```text
Mach-O 64-bit arm64 bundle
```

If the module is Mach-O, uninstall the extension and install the Linux x64 VSIX.

### Verify installed extension

```bash
file ~/.cursor/extensions/uniquevision.vscode-plpgsql-lsp-2.11.3/server/out/*.node
```

Expected:

```text
ELF 64-bit LSB shared object, x86-64
```
