{
  description = "A basic flake for Elixir development with Nix and NixOS";

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
      forEachSystem = system: {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.elixir;

        # Elixir development shell
        elixir = {pkgs, ...}:
          pkgs.mkShell {
            meta.description = "A development shell with Elixir";

            packages = with pkgs; [
              erlang
              erlang-language-platform
              elixir
              elixir-ls
            ];
          };
      };
    };
}
