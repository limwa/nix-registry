{
  description = "A basic flake for Java development in Nix and NixOS";

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

        jdk = pkgs.jdk;
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShell = {
        pkgs,
        jdk,
        ...
      }:
        pkgs.mkShell {
          JAVA_HOME = "${jdk}";

          packages = [
            jdk
          ];
        };
    };
}
