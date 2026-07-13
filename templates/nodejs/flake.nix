{
  description = "A basic flake for Node.js development in Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default/future-26.11";

    utils.url = "github:limwa/nix-flake-utils";
    utils.inputs.systems.follows = "systems";

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
      forEachSystem = system: {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.nodejs;

        # Node.js development shell
        nodejs = {pkgs, ...}:
          pkgs.mkShell {
            meta.description = "A development shell with Node.js v24";

            packages = with pkgs; [
              nodejs_24
              corepack_24
            ];
          };
      };
    };
}
