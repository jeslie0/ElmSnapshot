{
  description = "The \"snapshot\" package that is used by mkElmDerivation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        haskellPackages = pkgs.haskellPackages;
        homepage = "https://github.com/jeslie0/elmSnapshot";
      in
        {
          packages.default = (import ./default.nix (haskellPackages // { lib = pkgs.lib;})) // {
            meta = {
              description = "A program to serialise an elm-packages.json to binary";
              homepage = homepage;
              license = pkgs.lib.licenses.bsd3;
            };
          };

          # Requires IFD.
          # packages.snapshot = haskellPackages.callCabal2nix "snapshot" ./src/snapshot { };

          devShell = haskellPackages.shellFor {
            packages = p: [
              self.packages.${system}.default
            ];
            nativeBuildInputs = with haskellPackages;
              [
              ];

            # Enables Hoogle for the builtin packages.
            withHoogle = true;
          };
        }
    );
}
