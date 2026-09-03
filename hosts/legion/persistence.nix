# Impermanence: preservation bind-mounts the listed state from the ext4
# mounted at /nix back onto the volatile (tmpfs) root. The persistent sources
# are the pre-migration on-disk /etc, /home, /var, /root of the same ext4 —
# nothing was moved or copied.
#
# Forgotten-path safety net:
#  - old data for any path NOT listed here remains on disk under /nix (e.g.
#    /nix/home/luiz/<path>) and can be copied back by hand;
#  - new writes to unlisted paths are lost on reboot — run the canary diff
#    from AGENTS.md ("Impermanence") periodically to catch them.
{ ... }:
{
  preservation = {
    enable = true;

    # The persistent store is the ext4 mounted at /nix.
    preserveAt."/nix" = {
      files = [
        # read very early by systemd; prepared in initrd
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        # hwclock drift file (created empty if missing)
        "/etc/adjtime"
      ];

      directories = [
        # Wi-Fi passphrases (runtime-written under the declarative /etc)
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        # LVM volume group metadata backups (recovery value)
        "/etc/lvm"

        # wholesale: bluetooth pairings, fprint fingerprints, tailscale node
        # state, libvirt/qemu VMs, NetworkManager state, /var/lib/nixos
        # uid-map, flatpak system installs, systemd linger/rfkill/timers/
        # coredump, private (user service state), power-profiles-daemon, ...
        "/var/lib"
        # journal + service logs
        "/var/log"
        # libvirt, tailscale, tuigreet, private (cron/mail)
        "/var/spool"
        # greetd/tuigreet --remember --remember-user-session
        "/var/cache/tuigreet"
        # safety net; typically tiny
        "/var/tmp"
        # root's home, wholesale
        "/root"
      ];

      users.luiz = {
        commonMountOptions = [
          "x-gvfs-hide" # hide bind mounts from Nautilus' sidebar
          "x-gdu.hide" # hide from GNOME Disks
        ];

        directories = [
          # identity & secrets (the sops-nix SSH key lives here; system
          # secrets and opencode MCP tokens are decrypted with it)
          {
            directory = ".ssh";
            mode = "0700";
          }
          {
            directory = ".pki";
            mode = "0700";
          }
          {
            directory = ".gnupg"; # not present yet; future-proof
            mode = "0700";
          }

          # XDG state, wholesale (tighten into per-app lists later if desired)
          ".config" # zen browser profile, 1Password, Bitwarden, gh auth,
          #      obs-studio, easyeffects, Vial, niri/noctalia, lazygit, ...
          #      (.config/sops-nix holds runtime symlinks recreated by sops-nix)
          ".local" # Steam, PrismLauncher, Terraria, Tabletop Simulator, umu,
          #      zed, godot, direnv allows, keyrings, Trash + .local/state:
          #      doom, opencode, nvf, wireplumber, yazi, nix profiles
          #      (= home-manager generations), home-manager
          ".cache" # 7.2G: kept on disk on purpose — a tmpfs .cache would eat RAM
          ".var" # flatpak app data (Hytale launcher saves etc.)

          # browser profiles (non-XDG locations)
          ".mozilla"
          ".librewolf"

          # dev tool state
          ".cargo"
          ".opam"
          ".bun"
          ".dotnet"
          ".java"
          ".mono"
          ".conan2"
          ".code"
          ".codex"
          ".cursor"
          ".vscode"
          ".vscode-shared"
          ".nv"
          ".revideo"
          ".lldb"
          ".nix-defexpr"

          # apps with home-level state
          ".anydesk"
          ".wakatime"
          ".godot"
          ".minecraft"
          ".steam"

          # user-installed themes/icons
          ".icons"
          ".themes"

          # user data (Music/Documents are created empty if absent)
          "Downloads"
          "Pictures"
          "Videos"
          "Music"
          "Documents"
          "Games" # heroic/steam game data
          "foundry-vtt-mcp" # project checkout
          "nixos-dotfiles" # this repository
        ];

        files = [
          ".bash_history"
          ".zsh_history"
          {
            file = ".git-credentials"; # git credential.helper = store
            mode = "0600";
          }
          {
            file = ".wakatime.cfg";
            mode = "0600";
          }
          {
            file = ".pulse-cookie"; # pipewire/pulse auth
            mode = "0600";
          }
          ".nvidia-settings-rc"
          {
            file = ".nix-profile"; # -> .local/state/nix/profiles/profile
            how = "symlink";
          }
        ];
      };
    };
  };

  # bind-mounted machine-id makes this unit moot (see preservation docs)
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
