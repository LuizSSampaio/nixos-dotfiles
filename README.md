# GNU Guix System Configuration

Start configuration for migrating from NixOS to GNU Guix System with
[nonguix](https://gitlab.com/nonguix/nonguix) for unfree/non-free software
(NVIDIA drivers, firmware blobs, linux-nonfree kernel).

## Machine: legion (Lenovo Legion — AMD Ryzen + NVIDIA hybrid)

| Feature | Implementation |
|---|---|
| Kernel | `linux-nonfree` (nonguix) |
| Bootloader | GRUB EFI |
| Encryption | LUKS (cryptroot, cryptswap, cryptstorage) |
| GPU | AMD iGPU (primary) + NVIDIA dGPU (PRIME offload via nonguix) |
| Audio | PipeWire + WirePlumber (ALSA, PulseAudio & JACK compat) |
| Networking | NetworkManager + nftables firewall |
| VPN | Tailscale |
| Bluetooth | BlueZ |
| Display manager | greetd + tuigreet |
| Session | niri (Wayland compositor — install via `guix home`) |
| Gaming | Steam (nonguix) + GameMode |
| App sandbox | Flatpak |
| Power | upower + power-profiles-daemon |
| Locale | `en_US.UTF-8` / `pt_BR.UTF-8` regional overrides |
| Timezone | `America/Sao_Paulo` |
| Keyboard | `us` `intl` |

## Files

| File | Purpose |
|---|---|
| `channels.scm` | Guix channel definitions (guix + nonguix) |
| `config.scm` | System configuration (place at `/etc/config.scm`) |

## Initial Setup

### 1. Configure channels

```bash
mkdir -p ~/.config/guix
cp channels.scm ~/.config/guix/channels.scm
guix pull
hash guix  # reload PATH
```

### 2. First install (from the Guix installer or a live system)

```bash
# Partition, format and mount your disks first, then:
guix system init config.scm /mnt
```

### 3. Subsequent reconfiguration

```bash
# As root (or with sudo):
guix system reconfigure /etc/config.scm
```

### 4. User environment (guix home)

Per-user packages and dotfiles (niri, ghostty, zsh, git, neovim, emacs …)
are managed with `guix home`.  Create a `home.scm` home configuration and run:

```bash
guix home reconfigure home.scm
```

## Notes

### NVIDIA PRIME offload

The `nvidia-offload` wrapper script is installed system-wide.  Use it to run
an application on the discrete NVIDIA GPU:

```bash
nvidia-offload steam
nvidia-offload %command%   # Steam launch option
```

### Steam (unfree)

Steam ships in the nonguix channel.  After `guix pull`, add it to your user
profile or the system packages list:

```scheme
(use-package-modules nonguix)

;; In packages list:
steam
```

### Adjusting disk UUIDs

The LUKS device UUIDs in `config.scm` are copied from the original
NixOS `hardware-configuration.nix`.  Verify them on the target machine:

```bash
lsblk -f
blkid /dev/sdXY
```

Update the `(uuid ...)` fields in the `%mapped-devices` and `%file-systems`
definitions accordingly.

### Auto-upgrade equivalent

Guix does not have a built-in `system.autoUpgrade` service.  The recommended
approach is a weekly cron job or systemd timer that runs:

```bash
guix pull && guix system reconfigure /etc/config.scm
```
