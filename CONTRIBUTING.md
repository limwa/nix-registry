# Contributing

Everyone is welcome to contribute to this repository.

If you'd like to contribute, please take into consideration the [philosophy](/#philosophy) of this repository. Accordingly, changes like using a different formatter are not welcome, unless they are very well justified.

Furthermore, changes updating the `flake.lock` file are not needed, as the flake has an action to automatically update it. Instead, review the PR for updating the `flake.lock` file or create an issue requesting that it be updated.

## Getting started

To get started, fork this repository and clone it to your computer.

## Adding a new template

To add a new template, run the following command at the root of the repository:

```bash
nix flake new templates/<TEMPLATE_NAME> -t github:limwa/nix-registry#basic
```

> [!NOTE]
> Replace `<TEMPLATE_NAME>` with the name of the template you want to add.

This will create a new directory in the `templates` directory with the name of the template you specified.

Finally, modify the files in the template directory to suit your needs. When you're done, commit your changes and open a pull request.
