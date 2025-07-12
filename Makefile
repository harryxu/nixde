# vim: set noexpandtab tabstop=4 shiftwidth=4:
#
.PHONY: flakerebuild update

flakerebuild:
	sudo nixos-rebuild switch --impure --flake path:.#nixde

update:
	sudo nix flake update

upgrade: update flakerebuild
