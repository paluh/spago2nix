let
  easy-dhall-nix = pkgs: import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-dhall-nix";
      rev = "9c4397c3af63c834929b1e6ac25eed8ce4fca5d4";
      sha256 = "1cbrqfbx29rymf4sia1ix4qssdybjdvw0is9gv7l0wsysidrcwhf";
    }
  ) {
    inherit pkgs;
  };

in
{ pkgs ? import <nixpkgs> {}
, dhall-json ? (easy-dhall-nix pkgs).dhall-json-simple
, nodejs ? pkgs.nodejs-10_x
}:

  let
    easy-purescript-nix = import (
      pkgs.fetchFromGitHub {
        owner = "justinwoo";
        repo = "easy-purescript-nix";
        rev = "340e82b6ecaccc4059740e69f8ec18546b527481";
        sha256 = "1q2ciwd3193kig1paidzrgxl60y4rb39bsi97lk7m6ff8mis6z6i";
      }
    ) {
      inherit pkgs;
    };

  in
    pkgs.stdenv.mkDerivation {
      name = "spago2nix";

      src = pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.;

      buildInputs = [ pkgs.makeWrapper ];
      propagatedBuildInputs = [ easy-purescript-nix.purs easy-purescript-nix.spago ];

      installPhase = ''
        mkdir -p $out/bin
        target=$out/bin/spago2nix

        >>$target echo '#!${nodejs}/bin/node'
        >>$target echo "require('$src/bin/output.js')";

        chmod +x $target

        wrapProgram $target \
          --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.nix-prefetch-git
        easy-purescript-nix.spago
        easy-purescript-nix.purs
        dhall-json
      ]}
      '';
    }
