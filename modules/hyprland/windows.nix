{ pkgs, lib, config, ... }:

let cfg = config.modules.hyprland;
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      workspace = [ "w[tv1], gapsout:0, gapsin:0" "f[1], gapsout:0, gapsin:0" ];

      windowrule = [
        "border_size 0, rounding 0, match:float 0, match:workspace w[tv1]"
        "border_size 0, rounding 0, match:float 0, match:workspace f[1]"

        "suppress_event maximize, match:class .*"

        "opacity 0.97 0.9, match:class .*"

        "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0, match:pin 0"

        "float on, match:tag floating-window"
        "center on, match:tag floating-window"
        "size 875 600, match:tag floating-window"

        "tag +floating-window, match:class (bluetui|impala|wiremix|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|imv|mpv)"
        "tag +floating-window, match:class (xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus), match:title ^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)"
        "float on, match:class org.gnome.Calculator"

        "opacity 1 1, match:class ^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"

        "rounding 6, match:tag pop"

        "idle_inhibit always, match:tag noidle"

        # Terminal
        "tag +terminal, match:class (Alacritty|kitty|com.mitchellh.ghostty)"

        # 1Password
        "no_screen_share on, match:class ^(1[p|P]assword)$"
        "tag +floating-window, match:class ^(1[p|P]assword)$"

        # Browser
        "tag +chromium-based-browser, match:class ((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)"
        "tag +firefox-based-browser, match:class ([fF]irefox|zen|librewolf)"

        "tile on, match:tag chromium-based-browser"

        "opacity 1 0.98, match:tag chromium-based-browser"
        "opacity 1 0.98, match:tag firefox-based-browser"

        "opacity 1.0 1.0, match:initial_title ((?i)(?:[a-z0-9-]+.)*youtube.com_/|app.zoom.us_/wc/home)"

        # Davinci Resolve
        "stay_focused on, match:class .*[Rr]esolve.*, match:float 1"

        # Hyprshot
        "no_anim on, match:namespace selection"

        # LocalSend
        "float on, match:class (Share|localsend)"
        "center on, match:class (Share|localsend)"

        # QEMU
        "opacity 1 1, match:class qemu"

        # Steam
        "float on, match:class steam"
        "center on, match:class steam, match:title Steam"
        "opacity 1 1, match:class steam"
        "size 1100 700, match:class steam, match:title Steam"
        "size 460 800, match:class steam, match:title Friends List"
        "idle_inhibit fullscreen, match:class steam"
      ];

      layerrule = [ "no_anim on, match:namespace walker" ];
    };
  };
}
