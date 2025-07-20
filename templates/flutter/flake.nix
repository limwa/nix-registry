{
  description = "A basic flake for Flutter development with Nix and NixOS";

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
      forEachSystem = system: rec {
        outputs = utils.lib.forSystem self system;

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        # Reuse the same Android SDK, JDK and Flutter versions across all derivations
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeEmulator = "if-supported";
          includeNDK = "if-supported";
          includeSystemImages = "if-supported";

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
              EMULATOR_NAME = "emulator-5554";

              # Android environment variables
              ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
              GRADLE_OPTS = let
                buildToolsVersion = pkgs.lib.getVersion (builtins.elemAt androidComposition.build-tools 0);
              in "-Dorg.gradle.project.android.aapt2FromMavenOverride=${env.ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";

              # Java environment variables
              JAVA_HOME = "${jdk}";

              # Needed for graphics hardware acceleration in the emulator
              LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [libGL];
            };

            packages = [
              androidComposition.androidsdk
              flutter
              jdk

              (pkgs.writeShellApplication {
                name = "emulator-setup";

                text = ''
                  avdmanager delete avd -n "${env.EMULATOR_NAME}" 2>/dev/null || true
                  avdmanager create avd -n "${env.EMULATOR_NAME}" -k "system-images;android-35;google_apis;x86_64" -d "pixel_9_pro_xl"

                  # Enable GPU acceleration
                  {
                    echo "hw.gpu.enabled=yes"
                    echo "hw.gpu.mode=host"
                  } >> "$HOME/.android/avd/${env.EMULATOR_NAME}.avd/config.ini"

                  avdmanager list avd
                '';
              })

              (pkgs.writeShellApplication {
                name = "emulator-launch";

                text = ''
                  flutter emulators --launch "${env.EMULATOR_NAME}"
                '';
              })
            ];
          };
      };
    };
}
