{
  writeShellApplication,
  nix,
  self,
}:

writeShellApplication {
  name = "flutter-test-template-builds";

  runtimeInputs = [
    nix
    self
  ];

  text = ''
    TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf $TEMP_DIR' EXIT

    cd "$TEMP_DIR"
    echo "$TEMP_DIR"

    nix flake new env -t ${self}#flutter

    # shellcheck source=/dev/null
    . <(nix print-dev-env ./env)

    flutter create ./app && cd app

    # flutter build apk --debug
    flutter build aab --debug
  '';
}