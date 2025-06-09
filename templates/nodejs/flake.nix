{
  description = "A basic flake for Node.js development in Nix and NixOS";

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
      forEachSystem = system: {
        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShell = {pkgs, ...}:
        pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            corepack_22
          ];

          shellHook = ''
            echo "Your development environment is ready!"
            echo "To edit this message, modify the shellHook in flake.nix"
          '';
        };
    };
}
