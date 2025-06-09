{
  description = "A flake for simplifying repetitive tasks in Nix";

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
        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      formatter = {pkgs}: pkgs.alejandra;

      packages = {pkgs}: {
        checks-flutter-test-template-builds = pkgs.callPackage ./checks/flutter/test-template-builds.nix { inherit self; };
      };

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
