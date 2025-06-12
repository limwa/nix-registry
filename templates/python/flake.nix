{
  description = "A basic flake for Python development with Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:limwa/nix-flake-utils";

    # Needed for shell.nix
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs = {
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.mkFlakeWith {
      forEachSystem = system: rec {
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3.withPackages (ps: []);
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShell = {
        pkgs,
        python,
        ...
      }:
        pkgs.mkShell {
          packages = [
            python
          ];
        };
    };
}
