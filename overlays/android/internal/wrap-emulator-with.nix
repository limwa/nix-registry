{
  lib,
  # Builders
  runCommandNoCC,
  # Packages
  makeWrapper,
}: {
  meta ? {},
  useHardwareGraphics ? true,
}: emulator: let
  unwrapped = emulator
    .override (oldAttrs: {
    name = "${oldAttrs.name}-unwrapped";

    configOptions =
      (oldAttrs.configOptions or {})
      // lib.optionalAttrs useHardwareGraphics {
        "hw.gpu.enabled" = "yes";
        "hw.gpu.mode" = "host";
      };
  });

  unwrappedMeta = lib.getAttrs ["description" "homepage"] unwrapped.meta;

  # To make the emulator pure, all variables related to the emulator need to be
  # taken care of.
  # https://developer.android.com/tools/variables
  wrapper =
    runCommandNoCC "${lib.removeSuffix "-unwrapped" unwrapped.name}" {
      nativeBuildInputs = [makeWrapper];

      meta =
        unwrappedMeta
        // meta
        // {
          mainProgram = unwrapped.meta.mainProgram or "emulator";
        };

      passthru = {
        inherit unwrapped;
      };
    } ''
      mkdir -p $out/bin
      makeWrapper "${lib.getExe unwrapped}" "$out/bin/${wrapper.meta.mainProgram}" \
        --unset ANDROID_HOME \
        --unset ANDROID_USER_HOME \
        --unset ANDROID_EMULATOR_HOME \
        --unset ANDROID_AVD_HOME \
        --set ANDROID_EMULATOR_USE_SYSTEM_LIBS 1
    '';
in
  wrapper
