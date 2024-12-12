# NixDE
A simple NixOS Desktop Environment for programmers.

## Usage

Copy `env.nix.example` to `env.nix` and edit it to fit your needs.

Run:

```
sudo nixos-rebuild switch --flake path:.#nixde
```

The `path:` is required because `env.nix` is [ignored by git](https://discourse.nixos.org/t/use-nix-file-excluded-from-git/37196/12).
