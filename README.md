# Nix Flake Registry

This repository contains a flake which I use in my day-to-day development activities. For now, it contains templates for bootstrapping new projects.

[![Flake](https://github.com/limwa/nix-registry/actions/workflows/flake.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/flake.yaml)

| Template | Status                                                                                                                                                                                        |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Basic](https://github.com/limwa/nix-registry/tree/main/templates/basic)    | [![Basic Template](https://github.com/limwa/nix-registry/actions/workflows/template-basic.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-basic.yaml)       |
| [Flutter](https://github.com/limwa/nix-registry/tree/main/templates/flutter)  | [![Flutter Template](https://github.com/limwa/nix-registry/actions/workflows/template-flutter.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-flutter.yaml) |
| [Go](https://github.com/limwa/nix-registry/tree/main/templates/go)       | [![Go Template](https://github.com/limwa/nix-registry/actions/workflows/template-go.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-go.yaml)                |
| [Java](https://github.com/limwa/nix-registry/tree/main/templates/java)     | [![Java Template](https://github.com/limwa/nix-registry/actions/workflows/template-java.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-java.yaml)          |
| [Node.js](https://github.com/limwa/nix-registry/tree/main/templates/nodejs)  | [![Node.js Template](https://github.com/limwa/nix-registry/actions/workflows/template-nodejs.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-nodejs.yaml)   |
| [Python](https://github.com/limwa/nix-registry/tree/main/templates/python)   | [![Python Template](https://github.com/limwa/nix-registry/actions/workflows/template-python.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-python.yaml)    |
| [Rust](https://github.com/limwa/nix-registry/tree/main/templates/rust)     | [![Rust Template](https://github.com/limwa/nix-registry/actions/workflows/template-rust.yaml/badge.svg)](https://github.com/limwa/nix-registry/actions/workflows/template-rust.yaml)          |

## Usage

To see what is provided by this flake, you can run `nix flake show github:limwa/nix-registry`.

> [!TIP]
> To avoid having to type `github:limwa/nix-registry` every time you execute a command, you can add this flake to your system's flake registry.
> 
> To do that:
> 
> 1. Run `nix registry add limwa github:limwa/nix-registry`.
> 2. From then on, you can use `limwa` instead of `github:limwa/nix-registry` in your nix commands!

### Templates

To bootstrap your project with one of the templates provided by this flake, you can run

```bash
# e.g. for the flutter template
nix flake init -t github:limwa/nix-registry#flutter

# OR
nix flake new my_flutter_project -t github:limwa/nix-registry#flutter
```

A list of all of the templates provided by this flake can be obtained by running `nix flake show github:limwa/nix-registry`.

> [!CAUTION]
> Nix, by default, will cache the contents of this repository.
> This means that if you run `nix flake show github:limwa/nix-registry` again or instantiate a template from this repository,
> you might not see the latest changes.
>
> As such, if you want to see the latest changes, use the `--refresh` flag in your `nix` commands.

## Contributing

If you'd like to contribute to this repository, please read the [contributing guidelines](CONTRIBUTING.md).

## Philosophy

All of the templates provided by this flake are meant to be opinionated and tailored towards my personal workflow. This is a design choice and I won't be changing it.

In particular, all of them are made to work with [nix-direnv](https://github.com/nix-community/nix-direnv) and use [alejandra](https://github.com/kamadorueda/alejandra) for formatting.
Furthermore, all of them use my [nix-flake-utils](https://github.com/limwa/nix-flake-utils) library, which was purpose-built to make it easier to extend the functionality of the templates without much friction.
