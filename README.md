## Nix-darwin installation and usage

This document describes, how to install and use nix-darwin with my configuration on a MacBook.

After installation of the **nix-darwin** module, you need to execute once:

```bash
nix run nix-darwin -- switch --flake
```

If this was running successfully, you can now use in future the following command to apply your changes:

```
darwin-rebuild switch --flake ~/Projects/nix-darwin
```

If you want to rollback to a previous generation, run: `darwin-rebuild --switch-generation {number}`

To check, which generations you have available, run: `darwin-rebuild --list-generations`

To cleanup old generations you no longer need, run:

```bash
nix-collect-garbage -d --delete-older-than 1d
```

## Important: Running darwin-rebuild

`darwin-rebuild switch` must be run in a **local graphical terminal session** — not over SSH and not inside a TMUX session started over SSH.

Some packages (e.g. `ghostty-bin`) install macOS `.app` bundles, which requires nix-darwin to manage `/Applications`. macOS restricts this to processes with Full Disk Access, which is only available in a graphical session.

**Run it directly in a local terminal tab (e.g. Ghostty) outside of TMUX.**

If you must run it over SSH or in a non-graphical context, you can grant Full Disk Access to SSH under:
System Settings → General → Sharing → Remote Login → press the `i` icon → enable "Allow full disk access for remote users".
