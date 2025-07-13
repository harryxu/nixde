# vim: set noexpandtab tabstop=4 shiftwidth=4:

.PHONY: flakerebuild update gc3d gcboot gc

flakerebuild:
	sudo nixos-rebuild switch --impure --flake path:.#nixde

update:
	sudo nix flake update

upgrade: update flakerebuild

gc3d:
	sudo nix-collect-garbage --delete-older-than 3d
	nix-collect-garbage --delete-older-than 3d

gcboot:
	sudo /run/current-system/bin/switch-to-configuration boot

gc: gc3d gcboot
