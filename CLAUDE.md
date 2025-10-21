# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a nix-darwin configuration repository that manages macOS system packages, user environment, and dotfiles through Nix flakes. The configuration uses:

- **nix-darwin**: macOS system management
- **home-manager**: User environment and dotfiles management
- **nix-homebrew**: Integration with Homebrew for packages not available in nixpkgs

## Architecture

### Flake Structure

The repository uses a single-host configuration with the following module hierarchy:

1. **flake.nix**: Entry point defining inputs (nixpkgs, nix-darwin, home-manager) and outputs
2. **hosts/macbook-work/configuration.nix**: System-level configuration (packages, fonts, homebrew)
3. **home.nix**: User-level configuration (packages, programs, dotfiles via symlinks)
4. **programs/*.nix**: Modular program configurations imported by home.nix

### Key Design Patterns

**Symlink-based Dotfile Management**: home.nix uses `mkOutOfStoreSymlink` to create symlinks to `/Users/jan.baer/Projects/dotfiles/` rather than copying files into the Nix store. This allows dotfiles to be edited directly without rebuilding the Nix configuration.

**Hybrid Package Management**: Combines Nix packages (environment.systemPackages, home.packages) with Homebrew for macOS-specific apps and packages with issues in nixpkgs.

**Modular Program Configuration**: Program configurations are split into separate files under `programs/` and imported with explicit argument passing.

## Common Commands

### Building and Switching

Apply configuration changes:
```bash
darwin-rebuild switch --flake ~/Projects/nix-darwin
# or use the helper script:
./nix-switch.sh
```

Build without activating:
```bash
darwin-rebuild build --flake ~/Projects/nix-darwin
```

### Generation Management

List available generations:
```bash
darwin-rebuild --list-generations
```

Rollback to a previous generation:
```bash
darwin-rebuild --switch-generation <number>
```

Note: The `nix-list-generations.sh` script is for NixOS, not nix-darwin. It won't work on macOS.

### Garbage Collection

Remove old generations:
```bash
nix-collect-garbage -d --delete-older-than 1d
# or use the helper script:
./nix-garbage-collect.sh
```

### Flake Management

Update flake inputs:
```bash
nix flake update
```

Update specific input:
```bash
nix flake lock --update-input nixpkgs
```

Show flake metadata:
```bash
nix flake show
nix flake metadata
```

## Development Workflow

### Adding System Packages

Add to `hosts/macbook-work/configuration.nix` in `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  # Add packages here
];
```

### Adding User Packages

Add to `home.nix` in `home.packages`:
```nix
home.packages = with pkgs; [
  # Add packages here
];
```

### Adding Homebrew Packages

Edit `hosts/macbook-work/configuration.nix`:
- **brews**: CLI tools
- **casks**: GUI applications
- **masApps**: Mac App Store apps (requires app ID from `mas search <name>`)

### Adding Program Configurations

1. Create `programs/<name>.nix` with a function that accepts `{pkgs, config, ...}`
2. Import in `home.nix`: `<name> = import ./programs/<name>.nix {inherit pkgs config;};`

### Adding Dotfile Symlinks

Add to `home.file` in `home.nix`:
```nix
home.file."<path>" = {
  source = mkOutOfStoreSymlink "/Users/${username}/Projects/dotfiles/<path>";
  force = true;
  recursive = true; # for directories
};
```

## Important Constraints

- **Username**: Hardcoded as "jan.baer" in multiple places (flake.nix, home.nix)
- **Host ID**: Machine-specific "M9WMQ6QPM7" in flake.nix
- **System**: aarch64-darwin (Apple Silicon)
- **Nixpkgs Channel**: 25.05 release branch
- **Dotfiles Location**: Expects `/Users/jan.baer/Projects/dotfiles/` to exist

## Direnv Integration

The repository uses direnv with nix integration:
- `.envrc` loads the Nix shell environment
- `shell.nix` provides development tools
- Configured to suppress log output and extend timeout

When making changes to `.envrc` or `shell.nix`, run `direnv allow` to reload.
