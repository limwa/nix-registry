{
  lib,
  # Builders
  runCommandNoCC,
  # Packages
  makeWrapper,
}: {useHardwareGraphics ? true}: emulator: let
  base = emulator.override (oldAttrs: {
    configOptions =
      (oldAttrs.configOptions or {})
      // lib.optionalAttrs useHardwareGraphics {
        "hw.gpu.enabled" = "yes";
        "hw.gpu.mode" = "host";
      };
  });
in
  # To make the emulator pure, all variables related to the emulator need to be
  # taken care of.
  # https://developer.android.com/tools/variables
  runCommandNoCC "${base.name}-wrapped" {
    nativeBuildInputs = [makeWrapper];
    meta.mainProgram = base.meta.mainProgram or "emulator";
  } ''
    mkdir -p $out/bin
    makeWrapper "${lib.getExe base}" "$out/bin/${emulator.meta.mainProgram}" \
      --unset ANDROID_HOME \
      --unset ANDROID_USER_HOME \
      --unset ANDROID_EMULATOR_HOME \
      --unset ANDROID_AVD_HOME \
      --set ANDROID_EMULATOR_USE_SYSTEM_LIBS 1
  ''
