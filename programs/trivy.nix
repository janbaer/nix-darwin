# Trivy - vulnerability scanner for containers and other artifacts
#
# By default, uses the version from nixpkgs. To pin a specific version,
# pass version + sha256 + vendorHash (all three are required together).
#
# If the target version requires a newer Go than nixpkgs provides, pass
# `goBuilder` (e.g. pkgs.buildGo125Module). The nixpkgs 25.11 trivy package
# uses `buildGo124Module` as its argument, so we replace that.
# In nixpkgs 25.11: buildGoModule = buildGo125Module (the default).
#
# Hashes can be obtained by temporarily setting them to pkgs.lib.fakeHash,
# running `darwin-rebuild switch`, then copying the expected values from
# the error output (sha256 first, then vendorHash on the second run).
#
# Example — pin a version that needs Go 1.25:
#   import ./programs/trivy.nix {
#     inherit pkgs;
#     version    = "0.69.3";
#     sha256     = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
#     vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
#     goBuilder  = pkgs.buildGo125Module;
#   }
{ pkgs
, version    ? null
, sha256     ? null
, vendorHash ? null
, goBuilder  ? null
}:

let
  hasOverride = version != null && sha256 != null && vendorHash != null;
  # nixpkgs 25.11 trivy uses buildGo124Module; replace it to use a newer Go
  base = if goBuilder != null
    then pkgs.trivy.override { buildGo124Module = goBuilder; }
    else pkgs.trivy;
in
  if hasOverride
  then base.overrideAttrs (old: {
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "aquasecurity";
      repo  = "trivy";
      rev   = "v${version}";
      hash  = sha256;
    };
    vendorHash = vendorHash;
    # ldflags embeds the version string; re-declare so it uses the overridden version
    ldflags = [ "-s" "-w" "-X=github.com/aquasecurity/trivy/pkg/version/app.ver=${version}" ];
    # trivy >= 0.69 uses encoding/json/v2 which requires GOEXPERIMENT=jsonv2
    env = (old.env or {}) // { GOEXPERIMENT = "jsonv2"; };
  })
  else base
