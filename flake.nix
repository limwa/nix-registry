{
  description = "A flake for simplifying repetitive tasks in Nix";

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
      formatter = {pkgs}: pkgs.alejandra;

      templates = {
        basic = utils.lib.mkTemplate {
          path = ./templates/basic;
        };

        flutter = utils.lib.mkTemplate {
          path = ./templates/flutter;
        };

        nodejs = utils.lib.mkTemplate {
          path = ./templates/nodejs;
        };
      };
    };
}
