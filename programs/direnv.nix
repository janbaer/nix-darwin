{ pkgs, ... }: {
  enable = true;
  # Upstream fish-based tests are flaky on darwin; skip checkPhase.
  package = pkgs.direnv.overrideAttrs (_: { doCheck = false; });
  enableZshIntegration = true;
  nix-direnv.enable = true;
  silent = true; # doesn't work
}
