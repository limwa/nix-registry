{
  lib,
  # Builders
  runCommandNoCC,
  # Packages
  makeWrapper,
  libGL,
  vulkan-loader,
}:

{
  meta ? {},
  useHardwareGraphics ? "opengl",
}:

assert useHardwareGraphics == false || useHardwareGraphics == "opengl" || useHardwareGraphics == "vulkan";

emulator: let
  unwrapped = emulator.override (oldAttrs: {
    name = "${oldAttrs.name}-unwrapped";

    configOptions =
      (oldAttrs.configOptions or {})
      // (
        lib.optionalAttrs (useHardwareGraphics != false) {
          "hw.gpu.enabled" = "yes";
        }
      );
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
    } (
      ''
        mkdir -p $out/bin
        makeWrapper "${lib.getExe unwrapped}" "$out/bin/${wrapper.meta.mainProgram}" \
      ''
      + lib.concatStringsSep " " (
        [
          "--unset ANDROID_HOME"
          "--unset ANDROID_USER_HOME"
          "--unset ANDROID_EMULATOR_HOME"
          "--unset ANDROID_AVD_HOME"
          "--set ANDROID_EMULATOR_USE_SYSTEM_LIBS 0"
        ]
        ++ lib.optionals (useHardwareGraphics != false) [
          "--prefix LD_LIBRARY_PATH : \"${lib.makeLibraryPath [libGL]}\""
        ]
        ++ lib.optionals (useHardwareGraphics == "vulkan") [
          "--prefix LD_LIBRARY_PATH : \"${lib.makeLibraryPath [vulkan-loader]}\""
          "--set ANDROID_EMU_VK_LOADER_PATH \"${vulkan-loader}/lib/libvulkan.so\""
        ]
      )
    );
in
  wrapper
