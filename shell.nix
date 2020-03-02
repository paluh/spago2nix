let
  pkgs = import <nixpkgs> {};
  spago2nix = pkgs.callPackage (import ./default.nix) {};
in
  pkgs.stdenv.mkDerivation {
    name = "spago2nix";
    buildInputs = [
      spago2nix
    ];
  }
