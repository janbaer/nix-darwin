# Ghostty - fast, native, feature-rich terminal emulator (macOS pre-built binary)
#
# Uses ghostty-bin which fetches the official .dmg from release.files.ghostty.org.
# pkgs.ghostty (source build) is Linux-only; ghostty-bin is the Darwin package.
#
# NOTE: Remove "ghostty" from homebrew.casks in configuration.nix to avoid conflicts.
#
# To pin a specific version, pass version + sha256.
# The sha256 can be found by setting it to pkgs.lib.fakeHash, running
# `darwin-rebuild switch`, then copying the expected value from the error output.
#
# Example:
#   import ./programs/ghostty.nix {
#     inherit pkgs;
#     version = "1.1.0";
#     sha256  = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
#   }
{ pkgs
, version ? null
, sha256  ? null
}:

let
  hasOverride = version != null && sha256 != null;
in
  if hasOverride
  then pkgs.ghostty-bin.overrideAttrs (_: {
    inherit version;
    src = pkgs.fetchurl {
      url  = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
      hash = sha256;
    };
  })
  else pkgs.ghostty-bin
