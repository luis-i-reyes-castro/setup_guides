# Supabase PostgreSQL Language Server in Cursor

## Installation

1. Lookup **`postgres-language-server`** in Cursor's Extensions Marketplace. It is published by Supabase.
2. Install the extension.
3. When prompted to install the missing language binary, accept and let Cursor install it.

## Configuration

```json
// postgres-language-server.jsonc
{
  "$schema": "https://pg-language-server.com/latest/schema.json",
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  },
  "typecheck": {
    "enabled": true
  },
  "files": {
    "include": [
      "/**/*.sql"
    ],
    "ignore": []
  },
  "format": {
    "enabled": true,
    "lineWidth": 92,
    "indentSize": 2,
    "indentStyle": "spaces",
    "keywordCase": "upper",
    "constantCase": "upper",
    "typeCase": "upper"
  },
  "db": {
    "connectionString": "postgres://<USER>:<PWD>@<DATABASE_URL>:5432/postgres?sslmode=require",
    "connTimeoutSecs": 10,
    "allowStatementExecutionsAgainst": [
      "<DATABASE_URL>/*"
    ]
  }
}
```

# Generic PostgreSQL Language Server in Cursor

For PostgreSQL databases hosted **outside Supabase**.

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
  "files.associations": {
    "*.sql": "postgres"
  },
  "[postgres]": {
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false,
  },
  "plpgsqlLanguageServer.definitionFiles": [
    "*.sql",
    "*.psql",
    "*.pgsql",
  ],
  "plpgsqlLanguageServer.host": "<HOST>",
  "plpgsqlLanguageServer.port": 5432,
  "plpgsqlLanguageServer.database": "<DATABASE>",
  "plpgsqlLanguageServer.user": "<USER>",
  "plpgsqlLanguageServer.password": "<PWD>",
  "plpgsqlLanguageServer.queryParameterPattern": "@[A-Za-z_][A-Za-z0-9_]*",
  "plpgsqlLanguageServer.keywordQueryParameterPattern": [
    "@{keyword}",
  ],
  "plpgsqlLanguageServer.enableExecuteFileQueryCommand": true,
  "plpgsqlLanguageServer.workspaceValidationTargetFiles": [
    "${env:HOME}/repository/**/*.sql"
  ],
}
```

This tells the language server to recognize:

```sql
@ruc
@codigo
@search
@id_codigo
```

as query parameters.

## Per-file configuration

At the top of SQL template files with query parameters, add either
```sql
/* plpgsql-language-server:use-query-parameter */
```
or
```sql
/* plpgsql-language-server:use-keyword-query-parameter */
```

Example:

```sql
/* plpgsql-language-server:use-query-parameter */

SELECT
    *
FROM
    customer
WHERE
    ruc = @ruc;
```

For annoying files, disable the extension:
```sql
/* plpgsql-language-server:disable */
```

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
