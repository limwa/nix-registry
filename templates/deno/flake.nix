{
  description = "A basic flake for Deno development with Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=pull/417619/merge";
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
      forEachSystem = system: {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.deno;

        # Deno development shell
        deno = {pkgs, ...}:
          pkgs.mkShell {
            meta.description = "A development shell with Deno";

            packages = with pkgs; [
              deno
            ];
          };
      };
    };
}
