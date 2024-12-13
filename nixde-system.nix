{ config, pkgs, ... }:

{
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    vim wget curl neovim fish starship zoxide
    gcc gnumake cmake pkg-config autoconf automake libtool
  ];

  # Enable Docker.
  virtualisation.docker.enable = true;

  # Install git.
  programs.git.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow run non-nix executables, like vscode server.
  programs.nix-ld.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
