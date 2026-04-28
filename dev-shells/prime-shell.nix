let
  config = { allowUnfree = true; };
  # Pinned to nixpkgs-unstable @ 3e2cf88 — provides poppler 24.02.0, matching
  # the Debian apt version used in the Docker CI image.
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/3e2cf88148e732abc1d259286123e06a9d8c964a.tar.gz") { inherit config; };
in pkgs.mkShell {
  buildInputs = with pkgs; [
    pdftk
    ghostscript
    poppler-utils # provides pdfinfo
    qpdf
  ];
}
