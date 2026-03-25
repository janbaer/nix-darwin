# direnv - shell extension that manages your environment
#
# Patches the GNUmakefile to remove -linkmode=external, which conflicts with
# CGO_ENABLED=0 set by nixpkgs. Go 1.25 rejects this combination as an error
# (Go 1.24 silently ignored it). direnv has no C code, so the internal linker
# works correctly.
{ pkgs, ... }: {
  enable = true;
  package = pkgs.direnv.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace GNUmakefile \
        --replace-fail ' -linkmode=external' ""
    '';
  });
  enableZshIntegration = true;
  nix-direnv.enable = true;
  silent = true; # doesn't work
}
