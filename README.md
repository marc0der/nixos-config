# Nixos Flake

## System Level

To apply new changes in `configuration.nix`, run the following:

```bash
sudo nixos-rebuild switch --flake .
```
To upgrade dependencies to the latest in the specified channel in `flake.nix`, run the following:

```bash
# update the channel
sudo nix flake update --flake .

# run full system upgrade
sudo nixos-rebuild --upgrade switch --flake .
```

## Home Manager

To apply changes in `home.nix`, run the following:

```bash
home-manager switch --flake .
```

To upgrade dependencies to the latest:

```bash
nix flake update --flake .
home-manager switch --upgrade --flake .
```

