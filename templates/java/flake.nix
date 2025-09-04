{
  description = "A basic flake for Java development in Nix and NixOS";

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

        jdk = pkgs.jdk;
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.java;

        # Java development shell
        java = {
          pkgs,
          jdk,
          ...
        }:
          pkgs.mkShell {
            meta.description = "A development shell with Java";

            env = {
              JAVA_HOME = "${jdk}";
            };

            packages = [
              jdk
              # pkgs.gradle
              # pkgs.maven
            ];
          };
      };
    };
}
