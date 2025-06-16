{
  description = "A basic flake for Python development with Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:limwa/nix-flake-utils";

    # Needed for shell.nix
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.mkFlakeWith {
      forEachSystem = system: rec {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3.withPackages (ps: []);
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.python;

        # Python development shell
        python = {
          pkgs,
          python,
          ...
        }:
          pkgs.mkShell {
            meta.description = "A development shell with Python";

            packages = [
              python
            ];
          };
      };
    };
}
