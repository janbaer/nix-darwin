#!/usr/bin/env bash

# Compare differences between nix-darwin generations
# Usage: ./generation-diff.sh [gen1] [gen2]
# If no arguments provided, compares current with previous generation

set -euo pipefail

show_usage() {
  echo "Usage: $0 [generation1] [generation2]"
  echo
  echo "Examples:"
  echo "  $0                    # Compare current with previous generation"
  echo "  $0 178 179           # Compare generation 178 with 179"
  echo "  $0 current previous  # Compare current with previous"
  echo
  echo "Available generations:"
  if command -v darwin-rebuild >/dev/null 2>&1; then
    darwin-rebuild --list-generations 2>/dev/null | tail -5 || {
      echo "  (Run with appropriate permissions to see full list)"
      ls -lt /nix/var/nix/profiles/system-*-link 2>/dev/null | head -5 | awk '{print "  Generation", $9, "-", $6, $7, $8}'
    }
  fi
}

get_generation_path() {
  local gen="$1"

  case "$gen" in
    "current")
      readlink /run/current-system 2>/dev/null || echo ""
      ;;
    "previous"|"prev")
      # Get previous generation from list
      local current_num prev_num
      current_num=$(readlink /nix/var/nix/profiles/system 2>/dev/null | sed 's/system-\([0-9]*\)-link/\1/')
      if [ -n "$current_num" ] && [ "$current_num" -gt 1 ]; then
        prev_num=$((current_num - 1))
        echo "/nix/var/nix/profiles/system-${prev_num}-link"
      else
        # Fallback: get second-to-last from ls
        ls -t /nix/var/nix/profiles/system-*-link 2>/dev/null | sed -n '2p'
      fi
      ;;
    [0-9]*)
      # Numeric generation
      echo "/nix/var/nix/profiles/system-${gen}-link"
      ;;
    /*)
      # Full path
      echo "$gen"
      ;;
    *)
      echo ""
      ;;
  esac
}

compare_with_nvd() {
  local path1="$1"
  local path2="$2"
  
  echo "=== Using nvd tool ==="
  if nvd diff "$path1" "$path2" 2>/dev/null; then
    return 0
  else
    echo "nvd comparison failed, trying alternative methods..."
    return 1
  fi
}

compare_with_nix_store() {
  local path1="$1"
  local path2="$2"
  
  echo "=== Using nix store diff-closures ==="
  if nix store diff-closures "$path1" "$path2" 2>/dev/null; then
    return 0
  else
    echo "nix store diff-closures failed"
    return 1
  fi
}

compare_manual() {
  local path1="$1"
  local path2="$2"
  
  echo "=== Manual comparison ==="
  echo "Generation 1: $(basename "$path1")"
  echo "Generation 2: $(basename "$path2")"
  echo
  
  # Compare store paths
  echo "Store paths:"
  echo "  Path 1: $path1"
  echo "  Path 2: $path2"
  echo
  
  # Check if paths exist
  if [ ! -e "$path1" ]; then
    echo "Error: Path 1 does not exist: $path1"
    return 1
  fi
  
  if [ ! -e "$path2" ]; then
    echo "Error: Path 2 does not exist: $path2"
    return 1
  fi
  
  # Show basic info
  echo "Timestamps:"
  echo "  Path 1: $(ls -l "$path1" | awk '{print $6, $7, $8}')"
  echo "  Path 2: $(ls -l "$path2" | awk '{print $6, $7, $8}')"
  
  return 0
}

main() {
  # Check if running on nix-darwin
  if ! command -v darwin-rebuild >/dev/null 2>&1; then
    echo "Error: darwin-rebuild command not found"
    echo "Make sure you're running this on a nix-darwin system"
    exit 1
  fi

  # Parse arguments
  local gen1="${1:-current}"
  local gen2="${2:-previous}"

  if [ "$gen1" = "-h" ] || [ "$gen1" = "--help" ]; then
    show_usage
    exit 0
  fi

  # Get generation paths
  local path1
  local path2
  path1=$(get_generation_path "$gen1")
  path2=$(get_generation_path "$gen2")

  if [ -z "$path1" ]; then
    echo "Error: Could not determine path for generation '$gen1'"
    show_usage
    exit 1
  fi

  if [ -z "$path2" ]; then
    echo "Error: Could not determine path for generation '$gen2'"
    show_usage
    exit 1
  fi

  echo "Comparing nix-darwin generations:"
  echo "  From: $(basename "$path1") -> $path1"
  echo "  To:   $(basename "$path2") -> $path2"
  echo
  
  # Try different comparison methods
  if command -v nvd >/dev/null 2>&1; then
    if compare_with_nvd "$path1" "$path2"; then
      exit 0
    fi
  fi
  
  if command -v nix >/dev/null 2>&1; then
    if compare_with_nix_store "$path1" "$path2"; then
      exit 0
    fi
  fi
  
  # Fallback to manual comparison
  compare_manual "$path1" "$path2"
  
  echo
  echo "Tip: Install nvd for better diff output: ./install-nvd.sh"
}

main "$@"
