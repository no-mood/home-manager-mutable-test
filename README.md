# test-mutable-config

Minimal flake to test the Home Manager `mutable` patch.
Uses the fork/branch at `github:no-mood/home-manager/mutable-files`:
`https://github.com/no-mood/home-manager/tree/mutable-files`

## Usage

```bash
# build without activation
nix build .#homeConfigurations.test.activationPackage

# activate (overwrites $HOME of the current user)
# adjust home.username/homeDirectory if needed
home-manager switch --flake .#test
```

## VM

```bash
nix build .#nixosConfigurations.testhost.config.system.build.vm
./result/bin/run-testhost-vm
```

VM credentials: `test` / `test`.

## What it tests

`home.nix` defines a few files with `mutable.enable = true`.
After activation, `$HOME` links point to writable copies under
`~/.home-manager/mutable/` instead of the Nix store.

```
# default (immutable)
~/test/immutable.txt -> /nix/store/…-home-manager-files/test/immutable.txt

# mutable
~/test/mutable-seed.txt -> ~/.home-manager/mutable/store/…-home-manager-files/test/mutable-seed.txt
```

Seed creates the working copy once per store path. Force re-seeds on each switch
for the current store path.
