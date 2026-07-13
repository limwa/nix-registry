{
  description = "A flake for simplifying repetitive tasks in Nix";

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
        pkgs = import nixpkgs {
          inherit system;
        };
      };
    } {
      meta = {
        revision = self.shortRev or self.dirtyShortRev;
      };

      formatter = {pkgs}: pkgs.alejandra;

      templates = utils.lib.mkTemplates ./templates;

      overlays = {
        android = import ./overlays/android;
      };
    };
}
