{
  description = "A basic flake for Rust development with Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:limwa/nix-flake-utils";

    # Needed for shell.nix
    flake-compat.url = "github:edolstra/flake-compat";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    utils,
    ...
  }:
    utils.lib.mkFlakeWith {
      forEachSystem = system: rec {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import rust-overlay)];
        };

        rustToolchain = pkgs.rust-bin.stable.latest.complete;
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.rust;

        # Rust development shell
        rust = {
          pkgs,
          rustToolchain,
          ...
        }:
          pkgs.mkShell {
            meta.description = "A development shell with Rust";

            packages = [
              rustToolchain
            ];
          };
      };
    };
}
