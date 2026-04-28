;; GNU Guix system configuration — Legion laptop.
;;
;; Apply with:
;;   sudo guix system reconfigure guix/hosts/legion/system.scm
;;
;; This configuration mirrors the NixOS setup found in hosts/legion/ and
;; modules/system/:
;;   • EFI bootloader (GRUB)
;;   • LUKS-encrypted root, swap and extra storage volumes
;;   • NetworkManager networking
;;   • nftables firewall
;;   • NVIDIA PRIME offload (proprietary driver via nonguix)
;;   • PipeWire audio
;;   • Tailscale VPN
;;   • Bluetooth
;;   • Brazilian Portuguese locale overrides

;; ---------------------------------------------------------------------------
;; Load paths — make local modules visible to (use-modules ...).
;; ---------------------------------------------------------------------------
(add-to-load-path
 (string-append (dirname (current-filename)) "/../../.."))

;; ---------------------------------------------------------------------------
;; Module imports
;; ---------------------------------------------------------------------------
(use-modules
 ;; GNU Guix core
 (gnu)
 (gnu system)
 (gnu system file-systems)
 (gnu system mapped-devices)
 (gnu system shadow)
 (gnu system keyboard)
 ;; Services
 (gnu services)
 (gnu services base)
 (gnu services networking)
 (gnu services audio)
 (gnu services desktop)
 (gnu services ssh)
 (gnu services sysctl)
 (gnu services vpn)
 ;; Packages
 (gnu packages admin)
 (gnu packages bash)
 (gnu packages certs)
 (gnu packages linux)
 (gnu packages networking)
 (gnu packages shells)
 (gnu packages version-control)
 ;; nonguix — non-free kernel + NVIDIA
 (nongnu system linux-initrd)
 (nongnu packages linux)
 ;; Local NVIDIA PRIME module
 (modules nvidia))

;; ---------------------------------------------------------------------------
;; Keyboard layout
;; ---------------------------------------------------------------------------
(define %keyboard-layout
  (keyboard-layout "us" "intl"))

;; ---------------------------------------------------------------------------
;; LUKS mapped devices
;;
;; Mirrors the NixOS luks.devices block in hosts/legion/system.nix.
;; ---------------------------------------------------------------------------
(define %mapped-devices
  (list
   ;; Root filesystem
   (mapped-device
    (source (uuid "82c28330-9254-4b1c-908a-4ddf127a53d0"))
    (target "cryptroot")
    (type luks-device-mapping))

   ;; Swap
   (mapped-device
    (source (uuid "ae661835-887b-44ea-b85a-c3fccf50438c"))
    (target "cryptswap")
    (type luks-device-mapping))

   ;; Extra storage volume (LVM inside LUKS)
   (mapped-device
    (source (uuid "b6abffa9-06b2-47e4-8a01-2b73dca6da81"))
    (target "cryptstorage")
    (type luks-device-mapping))))

;; ---------------------------------------------------------------------------
;; File systems
;; ---------------------------------------------------------------------------
(define %file-systems
  (cons*
   ;; EFI system partition
   (file-system
    (mount-point "/boot/efi")
    (device (uuid "8515-3EC5" 'fat32))
    (type "vfat")
    (flags '(noatime)))

   ;; Encrypted root
   (file-system
    (mount-point "/")
    (device "/dev/mapper/cryptroot")
    (type "ext4")
    (dependencies %mapped-devices))

   ;; Extra storage mount
   (file-system
    (mount-point "/mnt/storage")
    (device "/dev/mapper/vg--storage-storage")
    (type "ext4")
    (flags '(nofail))
    (dependencies %mapped-devices))

   %base-file-systems))

;; ---------------------------------------------------------------------------
;; Swap
;; ---------------------------------------------------------------------------
(define %swap-devices
  (list (swap-space (target "/dev/mapper/cryptswap")
                    (dependencies %mapped-devices))))

;; ---------------------------------------------------------------------------
;; Users
;; ---------------------------------------------------------------------------
(define %users
  (cons*
   (user-account
    (name "luiz")
    (comment "Luiz Henrique Silva Sampaio")
    (group "users")
    (supplementary-groups '("wheel" "netdev" "audio" "video" "input"))
    (shell (file-append zsh "/bin/zsh")))
   %base-user-accounts))

;; ---------------------------------------------------------------------------
;; System packages
;; ---------------------------------------------------------------------------
(define %system-packages
  (cons*
   git
   zsh
   nss-certs
   %nvidia-offload-script        ; nvidia-offload helper (from modules/nvidia)
   %base-packages))

;; ---------------------------------------------------------------------------
;; nftables firewall rules
;;
;; Equivalent to the NixOS networking.firewall block:
;;   - trusted Tailscale interface
;;   - TCP/UDP port 53317 (LocalSend)
;;   - Tailscale UDP port
;; ---------------------------------------------------------------------------
(define %nftables-ruleset
  "#!/usr/sbin/nft -f

# Flush all existing rules
flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    # Allow established and related connections
    ct state { established, related } accept

    # Allow loopback
    iif lo accept

    # Allow ICMP / ICMPv6
    ip  protocol icmp   accept
    ip6 nexthdr  icmpv6 accept

    # Trust Tailscale interface fully
    iifname \"tailscale0\" accept

    # LocalSend (TCP + UDP 53317)
    tcp dport 53317 accept
    udp dport 53317 accept

    # Tailscale WireGuard port (default 41641; overridden at runtime)
    udp dport 41641 accept
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
")

;; ---------------------------------------------------------------------------
;; Services
;; ---------------------------------------------------------------------------
(define %system-services
  (append
   ;; NVIDIA PRIME offload services from local module
   (nvidia-prime-services)

   (list
    ;; NetworkManager (equivalent to networking.networkmanager.enable)
    (service network-manager-service-type)

    ;; nftables firewall
    (service nftables-service-type
             (nftables-configuration
              (ruleset (plain-file "nftables.conf" %nftables-ruleset))))

    ;; PipeWire audio (replaces PulseAudio)
    (service pipewire-service-type)
    (service wireplumber-service-type)

    ;; Bluetooth
    (service bluetooth-service-type
             (bluetooth-configuration (auto-enable? #f)))

    ;; Tailscale VPN
    (service tailscale-service-type)

    ;; SSH daemon (disabled by default — uncomment to enable)
    ;; (service openssh-service-type)
    )

   ;; Base desktop services (udev, dbus, polkit, etc.) minus the ones we
   ;; replace above.
   (modify-services %base-services
     ;; Replace the default iptables-based firewall with our nftables setup.
     (delete iptables-service-type))))

;; ---------------------------------------------------------------------------
;; Operating system declaration
;; ---------------------------------------------------------------------------
(operating-system
  (host-name "legion")
  (timezone "America/Sao_Paulo")
  (locale "en_US.UTF-8")

  ;; Brazilian Portuguese locale overrides (mirrors i18n.extraLocaleSettings)
  (locale-definitions
   (list
    (locale-definition (name "en_US.UTF-8") (source "en_US"))
    (locale-definition (name "pt_BR.UTF-8") (source "pt_BR"))))

  (keyboard-layout %keyboard-layout)

  ;; ---------------------------------------------------------------------------
  ;; Bootloader — GRUB with EFI support.
  ;; The NixOS config used limine; GRUB is the standard Guix choice for EFI.
  ;; ---------------------------------------------------------------------------
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets '("/boot/efi"))
    (keyboard-layout %keyboard-layout)
    (timeout 3)))

  ;; ---------------------------------------------------------------------------
  ;; Non-free Linux kernel (required for NVIDIA + AMD firmware blobs).
  ;; Provided by the nonguix channel.
  ;; ---------------------------------------------------------------------------
  (kernel linux)
  (initrd microcode-initrd)

  ;; initrd kernel modules — mirrors boot.initrd.availableKernelModules
  (initrd-modules
   (append
    '("nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc"
      "dm_mod" "dm_crypt" "aes_x86_64" "sha256_generic")
    %base-initrd-modules))

  ;; Extra kernel modules loaded at boot (kvm-amd for virtualisation)
  (kernel-arguments
   (append '("kvm-amd") %default-kernel-arguments))

  (mapped-devices  %mapped-devices)
  (file-systems    %file-systems)
  (swap-devices    %swap-devices)
  (users           %users)
  (packages        %system-packages)
  (services        %system-services))
