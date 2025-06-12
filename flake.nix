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
      meta = {
        revision = self.shortRev or self.dirtyShortRev;
      };

      formatter = {pkgs}: pkgs.alejandra;

      templates = utils.lib.mkTemplates ./templates;
    };
}
