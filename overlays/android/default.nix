final: prev: {
  androidenv =
    prev.androidenv
    // {
      emulateApp = let
        patchEmulateApp = fn:
          fn
          // {
            __functor = self: arg: final.callPackage fn arg;

            override =
              fn.override
              // {
                __functor = self: arg: patchEmulateApp (fn.override arg);
              };
          };
      in
        patchEmulateApp prev.androidenv.emulateApp;
    };

  limwa.android = {
    wrapEmulatorWith = final.callPackage ./internal/wrap-emulator-with.nix {};
  };
}
