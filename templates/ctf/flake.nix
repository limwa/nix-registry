{
  description = "A flake for Capture The Flag competitions";

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
          config = {
            allowUnfree = true;
          };
        };
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.ctf;

        # CTF shell
        ctf = {pkgs, outputs, ...}:
          pkgs.mkShell {
            meta.description = "A shell with common CTF tools";

            packages = with pkgs; [
              outputs.packages.cyberchef
              outputs.packages.revshells

              (python3.withPackages (ps: [
                ps.requests
                ps.beautifulsoup4
                ps.pwntools
                ps.cryptography
                ps.pillow
                ps.jwt
              ]))

              gef
              ghidra
              hashcat
              john
              netcat
              nmap
            ];
          };
      };

      packages = utils.lib.invokeAttrs {
        cyberchef = {pkgs, ...}: pkgs.writeShellApplication {
          name = "cyberchef";

          runtimeInputs = [
            pkgs.xdg-utils
          ];

          text = ''
            xdg-open "https://cyberchef.io/" > /dev/null
          '';
        };

        revshells = {pkgs, ...}: pkgs.writeShellApplication {
          name = "revshells";

          runtimeInputs = [
            pkgs.xdg-utils
          ];

          text = ''
            xdg-open "https://www.revshells.com/" > /dev/null
          '';
        };
      };
    };
}
