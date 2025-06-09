{
  description = "A basic flake for Flutter development with Nix and NixOS";

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
      forEachSystem = system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          # platformVersions = [ "35" ];
          # buildToolsVersions = [ "35.0.0" ];
          # cmakeVersions = [ "3.22.1" ];

          includeSystemImages = "if-supported";
          includeEmulator = "if-supported";

          includeNDK = "if-supported";
          # ndkVersions = [ "25.1.8937393" ];
        };
      in {
        inherit pkgs;

        # Reuse the same Android SDK, JDK and Flutter versions across all derivations
        androidSdk = androidComposition.androidsdk;
        flutter = pkgs.flutter332;
        jdk = pkgs.jdk17;
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShell = {
        pkgs,
        androidSdk,
        jdk,
        flutter,
        ...
      }:
        pkgs.mkShell rec {
          EMULATOR_NAME = "my_emulator";

          packages = [
            androidSdk
            jdk
            flutter

            (pkgs.writeShellApplication {
              name = "emulator-setup";

              text = ''
                avdmanager delete avd -n ${EMULATOR_NAME} 2>/dev/null || true
                avdmanager create avd -n ${EMULATOR_NAME} -k "system-images;android-35;google_apis;x86_64" -d "pixel_9_pro_xl"

                # Enable GPU acceleration
                {
                  echo "hw.gpu.enabled=yes"
                  echo "hw.gpu.mode=host"
                } >> ~/.android/avd/${EMULATOR_NAME}.avd/config.ini

                avdmanager list avd
              '';
            })
          ];

          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [libGL];
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
          JAVA_HOME = "${jdk}";

          shellHook = ''
            echo "Your development environment is ready!"
            echo "To edit this message, modify the shellHook in flake.nix"
          '';
        };
    };
}
