{
  description = "A basic flake for C/C++ development with Nix and NixOS";

  inputs = {
    # The latest staging-next cycle of Nixpkgs has introduced a lot of
    # regressions, so use the revision of nixos-unstable before the
    # problematic staging-next cycle was merged.
    nixpkgs.url = "github:nixos/nixpkgs/9807714d6944a957c2e036f84b0ff8caf9930bc0";
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
        default = {outputs, ...}: outputs.devShells.c;

        # C/C++ development shell
        c = {pkgs, ...}:
          pkgs.mkShell {
            meta.description = "A development shell with C/C++ tools";

            packages = with pkgs; [
              # Build tools
              cmake
              ninja

              # Debugging tools
              gdb

              # Libraries and headers
              # openssl
            ];
          };
      };
    };
}
