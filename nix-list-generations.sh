#!/usr/bin/env bash

# List all nix-darwin system generations/builds
# This script shows available system configurations that can be rolled back to

set -euo pipefail

echo "=== nix-darwin System Generations ==="
echo

# List system generations - try darwin-rebuild first, fall back to manual listing
if command -v darwin-rebuild >/dev/null 2>&1; then
  if darwin-rebuild --list-generations 2>/dev/null; then
    :  # Success, continue
  else
    echo "Note: darwin-rebuild --list-generations requires appropriate permissions"
    echo "Listing generations manually instead..."
    echo
  fi
else
  echo "Error: darwin-rebuild command not found"
  echo "Make sure you're running this on a nix-darwin system"
  echo
fi

echo
echo "=== Current System Generation ==="
# Show current generation
current_gen=$(readlink /run/current-system)
if [ -n "$current_gen" ]; then
  echo "Current: $current_gen"
  echo "Hash: $(basename "$current_gen" | cut -d'-' -f1)"
else
  echo "Could not determine current generation"
fi

# Show system profile information
echo
echo "=== System Profile Information ==="
system_profile="/nix/var/nix/profiles/system"
if [ -L "$system_profile" ]; then
  current_link=$(readlink "$system_profile")
  echo "Current profile: $current_link"

  # Extract generation number
  gen_num=$(echo "$current_link" | grep -o 'system-[0-9]*-link' | grep -o '[0-9]*')
  if [ -n "$gen_num" ]; then
    echo "Generation number: $gen_num"
  fi

  # Show target store path
  if [ -L "$system_profile" ]; then
    store_path=$(readlink -f "$system_profile" 2>/dev/null || readlink "$system_profile")
    echo "Store path: $store_path"
    echo "Hash: $(basename "$store_path" | cut -d'-' -f1)"
  fi
else
  echo "Could not determine system profile"
fi

echo
echo "=== Recent Generations ==="
# Show recent generation links manually
echo "Last 10 generations:"
ls -lt /nix/var/nix/profiles/system-*-link 2>/dev/null | head -10 | while IFS= read -r line; do
  # Parse the ls -l output
  gen_file=$(echo "$line" | awk '{print $9}')
  month=$(echo "$line" | awk '{print $6}')
  day=$(echo "$line" | awk '{print $7}')
  time=$(echo "$line" | awk '{print $8}')
  target=$(echo "$line" | awk '{print $11}')

  # Extract generation number from filename
  gen_num=$(basename "$gen_file" | sed 's/system-\([0-9]*\)-link/\1/')
  date_info="$month $day $time"

  # Get hash from target
  hash=$(basename "$target" | cut -d'-' -f1)

  echo "  Gen $gen_num ($date_info) - $hash"
done

echo
echo "=== Usage Tips ==="
echo "• List generations: darwin-rebuild --list-generations"
echo "• Switch to generation: darwin-rebuild --switch-generation <number>"
echo "• Rollback: darwin-rebuild --rollback"
echo "• Apply changes: darwin-rebuild switch --flake ~/Projects/nix-darwin"
echo "• Compare generations with nvd: nvd diff /nix/var/nix/profiles/system-<gen1>-link /nix/var/nix/profiles/system-<gen2>-link"
