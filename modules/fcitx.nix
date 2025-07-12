{ config, pkgs, ...}:
{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk             # alternatively, kdePackages.fcitx5-qt
      kdePackages.fcitx5-qt
      fcitx5-chinese-addons  # table input method support
      fcitx5-nord            # a color theme
      rime-data
      fcitx5-rime
    ];
  };
}
