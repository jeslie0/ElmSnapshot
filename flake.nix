{
  description = "The \"snapshot\" package that is used by mkElmDerivation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

      forAllSystems =
        nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
        });

      haskellPackages =
        system: nixpkgsFor.${system}.haskellPackages;

      homepage =
        "https://github.com/jeslie0/elmSnapshot";
      in
        {
          packages =
            forAllSystems (system:
              let
                pkgs =
                  nixpkgsFor.${system};
              in
                {
                  default = (import ./default.nix ((haskellPackages system) // { lib = pkgs.lib;})) // {
                    meta = {
                      description = "A program to serialise an elm-packages.json to binary";
                      homepage = homepage;
                      license = pkgs.lib.licenses.bsd3;
                    };
                  };
                }
            );

          # Requires IFD.
          # packages.snapshot = haskellPackages.callCabal2nix "snapshot" ./src/snapshot { };

          devShell =
            forAllSystems (system:
              (haskellPackages system).shellFor {
                packages = p: [
                  self.packages.${system}.default
                ];
                nativeBuildInputs = with haskellPackages;
                  [
                  ];

                # Enables Hoogle for the builtin packages.
                withHoogle = true;
              }
            );
        };
}
