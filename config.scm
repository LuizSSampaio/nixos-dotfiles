;; GNU Guix System Configuration — legion
;;
;; Machine: Lenovo Legion (AMD Ryzen + NVIDIA hybrid graphics via PRIME offload)
;; Mirrors features from the previous NixOS configuration:
;;   - LUKS full-disk encryption (3 devices: root, swap, storage)
;;   - AMD iGPU + NVIDIA dGPU (PRIME offload, nvidia-offload wrapper)
;;   - PipeWire audio (ALSA + PulseAudio + JACK compat)
;;   - NetworkManager + nftables firewall
;;   - Tailscale VPN
;;   - Bluetooth
;;   - greetd display manager (tuigreet front-end)
;;   - Steam + GameMode
;;   - Flatpak
;;   - upower + power-profiles-daemon + polkit
;;   - User: luiz (wheel, networkmanager, audio, video)
;;   - Locale: en_US.UTF-8 / pt_BR.UTF-8 regional overrides
;;   - Timezone: America/Sao_Paulo
;;   - Keyboard: us-intl (cedilla variant)
;;
;; Initial setup:
;;   1. Copy channels.scm to ~/.config/guix/channels.scm
;;   2. Run: guix pull
;;   3. As root: guix system init config.scm /mnt   (first install)
;;      or:      guix system reconfigure config.scm  (subsequent updates)

(use-modules
 ;; Core Guix system modules
 (gnu)
 (gnu system)
 (gnu system file-systems)
 (gnu system accounts)
 (gnu system mapped-devices)
 (gnu system keyboard)
 (gnu system nss)
 (gnu packages)
 (gnu packages linux)
 (gnu packages admin)
 (gnu packages shells)
 (gnu packages certs)
 (gnu packages networking)
 (gnu packages games)
 (gnu packages xorg)
 ;; Services
 (gnu services)
 (gnu services base)
 (gnu services networking)
 (gnu services audio)
 (gnu services pm)
 (gnu services desktop)
 (gnu services dbus)
 (gnu services security-token)
 (gnu services games)
 (gnu services xorg)
 ;; nonguix — unfree software channel
 (nongnu packages linux)
 (nongnu packages nvidia)
 (nongnu services nvidia)
 (nongnu system linux-initrd))

;;; ---------------------------------------------------------------------------
;;; Kernel
;;;
;;; linux-nonfree from nonguix includes out-of-tree NVIDIA support and ships
;;; the non-free firmware blobs required for AMD microcode + NVIDIA.
;;; ---------------------------------------------------------------------------

(define %kernel linux-nonfree)

;;; ---------------------------------------------------------------------------
;;; Mapped devices — LUKS encryption
;;;
;;; Three LUKS containers matching the NixOS hardware-configuration:
;;;   cryptroot    → / (ext4 on /dev/mapper/cryptroot)
;;;   cryptswap    → swap
;;;   cryptstorage → /mnt/storage (via LVM volume group vg--storage)
;;; ---------------------------------------------------------------------------

(define %mapped-devices
  (list
   (mapped-device
    (source (uuid "82c28330-9254-4b1c-908a-4ddf127a53d0"))
    (target "cryptroot")
    (type luks-device-mapping))
   (mapped-device
    (source (uuid "ae661835-887b-44ea-b85a-c3fccf50438c"))
    (target "cryptswap")
    (type luks-device-mapping))
   (mapped-device
    (source (uuid "b6abffa9-06b2-47e4-8a01-2b73dca6da81"))
    (target "cryptstorage")
    (type luks-device-mapping))))

;;; ---------------------------------------------------------------------------
;;; File systems
;;; ---------------------------------------------------------------------------

(define %file-systems
  (append
   (list
    ;; EFI System Partition
    (file-system
     (device (uuid "8515-3EC5" 'fat32))
     (mount-point "/boot/efi")
     (type "vfat")
     (flags '(boot)))

    ;; Root filesystem (on LUKS-decrypted device)
    (file-system
     (device "/dev/mapper/cryptroot")
     (mount-point "/")
     (type "ext4")
     (dependencies %mapped-devices))

    ;; Secondary storage (on LUKS → LVM volume group)
    (file-system
     (device "/dev/mapper/vg--storage-storage")
     (mount-point "/mnt/storage")
     (type "ext4")
     (flags '(no-fail))
     (dependencies %mapped-devices)))

   ;; Include the standard virtual filesystems
   %virtual-file-systems))

;;; ---------------------------------------------------------------------------
;;; Swap
;;; ---------------------------------------------------------------------------

(define %swap-devices
  (list
   (swap-space
    (target "/dev/mapper/cryptswap")
    (dependencies %mapped-devices))))

;;; ---------------------------------------------------------------------------
;;; nvidia-offload helper script
;;;
;;; Equivalent to the NixOS nvidia-offload script: sets the NVIDIA PRIME
;;; render-offload environment variables and exec's the given command.
;;; ---------------------------------------------------------------------------

(define nvidia-offload
  (program-file
   "nvidia-offload"
   #~(begin
       (setenv "__NV_PRIME_RENDER_OFFLOAD" "1")
       (setenv "__NV_PRIME_RENDER_OFFLOAD_PROVIDER" "NVIDIA-G0")
       (setenv "__GLX_VENDOR_LIBRARY_NAME" "nvidia")
       (setenv "__VK_LAYER_NV_optimus" "NVIDIA_only")
       (apply execl (cadr (command-line))
              (cadr (command-line))
              (cddr (command-line))))))

;;; ---------------------------------------------------------------------------
;;; Users
;;; ---------------------------------------------------------------------------

(define %users
  (list
   (user-account
    (name "luiz")
    (comment "Luiz Henrique Silva Sampaio")
    (group "users")
    (supplementary-groups
     '("wheel"          ; sudo access
       "networkmanager" ; NetworkManager CLI / GUI control
       "audio"          ; direct audio device access
       "video"          ; GPU / camera access
       "input"          ; input devices (keyboard, mouse, gamepad)
       "kvm"            ; virtualisation
       "docker"))       ; container management (if Docker is added later)
    (shell (file-append zsh "/bin/zsh"))
    (home-directory "/home/luiz"))))

;;; ---------------------------------------------------------------------------
;;; Keyboard layout
;;; ---------------------------------------------------------------------------

(define %keyboard-layout
  (keyboard-layout "us" "intl"))

;;; ---------------------------------------------------------------------------
;;; Bootloader — GRUB EFI
;;;
;;; GRUB is the closest equivalent to the NixOS limine EFI setup available
;;; natively in Guix.  The EFI installation target mirrors the /boot/efi
;;; mount point defined above.
;;; ---------------------------------------------------------------------------

(define %bootloader
  (bootloader-configuration
   (bootloader grub-efi-bootloader)
   (targets '("/boot/efi"))
   (keyboard-layout %keyboard-layout)
   (timeout 3)))

;;; ---------------------------------------------------------------------------
;;; Packages available system-wide
;;;
;;; Keep this list minimal; prefer per-user profiles (guix home) for
;;; application software.
;;; ---------------------------------------------------------------------------

(define %system-packages
  (append
   (list
    ;; NVIDIA PRIME offload wrapper
    nvidia-offload
    ;; Essential networking
    nss-certs          ; TLS certificate store
    iproute            ; ip(8), tc(8)
    wireless-tools     ; iwconfig etc.
    ;; Shell
    zsh
    ;; Basic utilities
    htop
    pciutils
    usbutils)
   ;; Include packages already in %base-packages
   %base-packages))

;;; ---------------------------------------------------------------------------
;;; Services
;;; ---------------------------------------------------------------------------

(define %services
  (append
   (list

    ;;; --- Display manager: greetd + tuigreet ---
    ;;; Mirrors the NixOS greetd configuration that auto-launches niri-session
    ;;; for user `luiz` and falls back to an interactive tuigreet prompt.
    (service greetd-service-type
             (greetd-configuration
              (greeter-supplementary-groups '("input" "video"))
              (terminals
               (list
                (greetd-terminal-configuration
                 (terminal-vt "1")
                 (terminal-switch #t)
                 (default-session-command
                   (greetd-agreety-session
                    (command (file-append tuigreet "/bin/tuigreet"))
                    (command-args '("--greeting" "Welcome to GNU Guix!"
                                   "--asterisks"
                                   "--remember"
                                   "--remember-user-session"
                                   "--time"
                                   "--cmd" "niri-session"))))
                 (initial-session-user "luiz")
                 (initial-session-command
                   (greetd-agreety-session
                    (command (file-append niri "/bin/niri-session")))))))))

    ;;; --- NVIDIA (nonguix) ---
    ;;; Installs the proprietary NVIDIA driver and configures PRIME offload.
    ;;; The amdgpu driver handles the primary display; NVIDIA is available
    ;;; on-demand via the nvidia-offload wrapper script.
    (service nvidia-driver-service-type
             (nvidia-driver-configuration
              (driver nvidia-driver)
              ;; PRIME offload: AMD is the primary GPU (PCI 0:6:0),
              ;; NVIDIA is the secondary/offload GPU (PCI 0:1:0).
              (prime-offload? #t)
              (modprobe-blacklist '("nouveau"))))

    ;;; --- PipeWire audio ---
    (service pipewire-service-type)
    (service wireplumber-service-type)

    ;;; --- NetworkManager ---
    (service network-manager-service-type
             (network-manager-configuration
              (dns "systemd-resolved")))
    (service wpa-supplicant-service-type)

    ;;; --- Tailscale VPN ---
    (service tailscale-service-type)

    ;;; --- Bluetooth ---
    (service bluetooth-service-type
             (bluetooth-configuration
              (auto-enable? #f)))

    ;;; --- Power management ---
    (service upower-service-type)
    (service power-profiles-daemon-service-type)

    ;;; --- Polkit ---
    (service polkit-service-type)

    ;;; --- Flatpak ---
    (service flatpak-service-type)

    ;;; --- D-Bus ---
    (service dbus-root-service-type)

    ;;; --- Elogind (seat management) ---
    (service elogind-service-type
             (elogind-configuration
              (handle-lid-switch 'suspend)
              (handle-lid-switch-external-power 'ignore)))

    ;;; --- Nftables firewall ---
    ;;; Mirrors the NixOS firewall rules: allow LocalSend (53317) and
    ;;; Tailscale (UDP 41641 default) through the firewall.
    (service nftables-service-type
             (nftables-configuration
              (ruleset
               (plain-file
                "nftables.conf"
                "
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    # Allow established/related connections
    ct state { established, related } accept;

    # Allow loopback
    iif lo accept;

    # Allow ICMP / ICMPv6
    ip protocol icmp accept;
    ip6 nexthdr icmpv6 accept;

    # Allow SSH (optional — remove if not needed)
    tcp dport 22 accept;

    # LocalSend (LAN file transfer, port 53317)
    tcp dport 53317 accept;
    udp dport 53317 accept;

    # Tailscale — allow traffic from tailscale0 interface
    iif tailscale0 accept;

    # Tailscale WireGuard UDP port (default 41641)
    udp dport 41641 accept;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
"))))

    ;;; --- udev rules (e.g. for Vial QMK keyboards) ---
    (udev-rules-service 'vial
                        (file->etc-file
                         (plain-file
                          "vial.rules"
                          "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{serial}==\"*vial:f64c2b3c*\", MODE=\"0660\", GROUP=\"plugdev\", TAG+=\"uaccess\", TAG+=\"udev-acl\"\n")))

    ;;; --- Steam + GameMode ---
    ;;; NOTE: Steam requires the `steam` package from nonguix (unfree).
    ;;; Add the `steam` package to %system-packages or a user profile once
    ;;; the nonguix channel is pulled; it is listed here as a service comment
    ;;; only because Guix does not have a dedicated Steam service type.
    ;;; GameMode daemon:
    (service feral-gamemode-service-type))

   ;;; Base services (syslog, static networking, etc.)
   ;;; Strip out services we replace (e.g. networking)
   (modify-services %base-services
     (delete network-manager-service-type)
     ;; Use our keyboard layout in the console
     (console-font-service-type
      config =>
      (map (lambda (tty)
             (cons tty (file-append font-terminus
                                    "/share/consolefonts/ter-132n")))
           '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6"))))))

;;; ---------------------------------------------------------------------------
;;; Operating system declaration
;;; ---------------------------------------------------------------------------

(operating-system
 (kernel %kernel)

 ;; Use the nonguix microcode initrd for AMD CPU microcode updates
 (initrd microcode-initrd)

 ;; Silent/quiet kernel parameters (mirrors the NixOS plymouth config)
 (kernel-arguments
  (append
   '("quiet"
     "splash"
     "loglevel=3"
     "rd.systemd.show_status=false"
     "rd.udev.log_level=3"
     "udev.log_priority=3"
     ;; AMD PRIME — keep amdgpu as primary, nvidia as offload
     "amdgpu.dpm=1"
     "nvidia-drm.modeset=1")
   %default-kernel-arguments))

 ;; Firmware (includes non-free AMD/NVIDIA firmware blobs via nonguix)
 (firmware (list linux-firmware))

 (bootloader %bootloader)
 (mapped-devices %mapped-devices)
 (file-systems %file-systems)
 (swap-devices %swap-devices)

 (host-name "legion")

 (timezone "America/Sao_Paulo")

 (locale "en_US.UTF-8")

 ;; Regional locale overrides matching the NixOS i18n.extraLocaleSettings
 (locale-definitions
  (list
   (locale-definition (name "en_US.utf8") (source "en_US"))
   (locale-definition (name "pt_BR.utf8") (source "pt_BR"))))

 (locale-namedefs
  (plain-file
   "locale-namedefs"
   "LC_ADDRESS=pt_BR.UTF-8\nLC_IDENTIFICATION=pt_BR.UTF-8\nLC_MEASUREMENT=pt_BR.UTF-8\nLC_MONETARY=pt_BR.UTF-8\nLC_NAME=pt_BR.UTF-8\nLC_NUMERIC=pt_BR.UTF-8\nLC_PAPER=pt_BR.UTF-8\nLC_TELEPHONE=pt_BR.UTF-8\nLC_TIME=pt_BR.UTF-8\n"))

 (keyboard-layout %keyboard-layout)

 ;; NSS — needed for hostname resolution and user lookups
 (name-service-switch %mdns-host-lookup-nss)

 (users (append %users %base-user-accounts))

 (packages %system-packages)

 (services %services))
