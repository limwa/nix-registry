# Nix Flake Registry

This repository contains a flake which I use in my day-to-day development activities. For now, it contains templates for bootstrapping new projects.

[![Flutter Template](https://github.com/limwa/nix-flake-registry/actions/workflows/flutter-template.yaml/badge.svg)](https://github.com/limwa/nix-flake-registry/actions/workflows/flutter-template.yaml)

## Usage

To see what is provided by this flake, you can run

```bash
nix flake show github:limwa/nix-flake-registry
```

> [!TIP]
> To avoid having to type `github:limwa/nix-flake-registry` every time you execute a command, you can add this flake to your system's flake registry.
> 
> To do that:
> 
> 1. Run `nix registry add limwa github:limwa/nix-flake-registry`.
> 2. From then on, you can use `limwa` instead of `github:limwa/nix-flake-registry` in your nix commands!

### Templates

To bootstrap your project with one of the templates provided by this flake, you can run

```bash
# e.g. for the flutter template
nix flake init -t github:limwa/nix-flake-registry#flutter
```

A list of all of the templates provided by this flake can be obtained by running

```bash
nix flake show github:limwa/nix-flake-registry
```
