{ config, pkgs, ... }:
let
  env = import ./env.nix;
  utils = import ./utils.nix;
in
  {
    imports = builtins.concatLists [
      (utils.importIfExists ./modules/sys-nvidia.nix)
      (utils.importIfExists ./modules/sys-gnome.nix)
      (utils.importIfExists ./modules/fcitx.nix)
    ];

    # Enable Flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # List packages installed in system profile. To search, run: $ nix search wget
    environment.systemPackages = with pkgs; [
      vim wget curl neovim fish starship zoxide
      gcc gnumake cmake pkg-config autoconf automake libtool
      pciutils
      tmux kitty
    ];

    programs.hyprland.enable = true;
    services.displayManager.gdm.wayland = true;


    # Enable Docker.
    virtualisation.docker.enable = true;

    # Add docker users
    users.extraGroups.docker.members = [ "${env.username}" ];

    # Set fish as default shell.
    # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    programs.bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    # Fonts
    fonts.packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.ubuntu-mono

      font-awesome           # ttf-font-awesome

      noto-fonts
      noto-fonts-emoji
      noto-fonts-extra
      noto-fonts-cjk-sans

      wqy_zenhei
      wqy_microhei
    ];

    # Install git.
    programs.git.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Allow run non-nix executables, like vscode server.
    programs.nix-ld.enable = true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 3389 ];
      allowedUDPPorts = [ 3389 ];
    };

  }
