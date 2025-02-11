## Nix-darwin installation and usage

This document describes, how to install and use nix-darwin with my configuration on a MacBook.

After installation of the **nix-darwin** module, you need to execute once:

```bash
nix run nix-darwin -- switch --flake
```

If this was running successfully, you can now use in future the following command to apply your changes:

```bash
nix-collect-garbage -d --delete-older-than 1d
```

To delete all generations older than today, run:

```bash
nix-collect-garbage -d --delete-older-than 1d
```
