# Dev Shells

Project-specific Nix shells providing CLI tools not in the global environment.

## Usage

```bash
nix-shell ~/Projects/nix-darwin/dev-shells/<name>-shell.nix
```

Or from within this directory:

```bash
nix-shell prime-shell.nix
```

## Shells

### `prime-shell.nix`

Tools for the `bu-prime` project:

| Tool | Purpose |
|------|---------|
| `pdftk` | PDF manipulation |
| `ghostscript` | PDF rendering/conversion |
| `poppler-utils` | `pdfinfo`, `pdftotext`, etc. — pinned to 24.02.0 to match Docker CI |
| `qpdf` | PDF decryption/linearization (required for fileSize tests) |
