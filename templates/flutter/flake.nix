{
  description = "A basic flake for Flutter development with Nix and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:limwa/nix-flake-utils";

    # For hardware-accelerated Android emulator on NixOS
    limwa.url = "github:limwa/nix-registry";

    # Needed for shell.nix
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    limwa,
    ...
  }:
    utils.lib.mkFlakeWith {
      forEachSystem = system: rec {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;

          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };

          overlays = [
            # For hardware-accelerated Android emulator on NixOS
            limwa.overlays.android
          ];
        };

        # Reuse the same Android SDK, JDK and Flutter versions across all derivations
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeNDK = "if-supported";

          buildToolsVersions = ["34.0.0"];
          cmakeVersions = ["3.22.1"];
          platformVersions = ["35"];
          ndkVersions = ["26.3.11579264"];
        };

        flutter = pkgs.flutter332;
        jdk = pkgs.jdk17;
      };
    } {
      formatter = {pkgs, ...}: pkgs.alejandra;

      devShells = utils.lib.invokeAttrs {
        default = {outputs, ...}: outputs.devShells.flutter;

        # Flutter development shell
        flutter = {
          pkgs,
          androidComposition,
          flutter,
          jdk,
          ...
        }:
          pkgs.mkShell rec {
            meta.description = "A development shell with Flutter and an Android SDK installation";

            env = {
              # Android environment variables
              ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
              GRADLE_OPTS = let
                buildToolsVersion = pkgs.lib.getVersion (builtins.elemAt androidComposition.build-tools 0);
              in "-Dorg.gradle.project.android.aapt2FromMavenOverride=${env.ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";

              # Java environment variables
              JAVA_HOME = "${jdk}";
            };

            packages = [
              androidComposition.androidsdk
              flutter
              jdk
            ];
          };
      };

      packages = utils.lib.invokeAttrs {
        emulator = {
          pkgs,
          androidComposition,
          ...
        }: let
          # By default, the emulator uses the platform version of the last platform
          # specified in the Android SDK
          #
          # If you want to use a different platform version, you can change the
          # `platformVersion` variable below.
          platformVersion = pkgs.lib.getVersion (pkgs.lib.last androidComposition.platforms);
        in
          pkgs.limwa.android.wrapEmulatorWith {
            meta.description = "An Android emulator, running SDK version ${platformVersion}";
            useHardwareGraphics = true;
          } (
            pkgs.androidenv.emulateApp {
              name = "my-emulator";
              deviceName = "my_emulator";

              inherit platformVersion;
              systemImageType = "google_apis_playstore";

              # The emulator uses the instruction set of the host system
              # to avoid emulating alien architectures (e.g. arm64 on x86_64)
              #
              # If you want to emulate a specific architecture, you can change
              # the ABI version below.
              abiVersion =
                if pkgs.stdenv.isAarch32
                then "armeabi-v7a"
                else if pkgs.stdenv.isAarch64
                then "arm64-v8a"
                else if pkgs.stdenv.isx86_32
                then "x86"
                else if pkgs.stdenv.isx86_64
                then "x86_64"
                else throw "Please specify an ABI version for your system";

              # Specify user home to speed up boot times and avoid creating
              # a lot of avd instances taking up disk space
              androidUserHome = "\$HOME/.android";
            }
          );
      };
    };
}
