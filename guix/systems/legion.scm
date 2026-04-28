(define-module (luiz systems legion)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system shadow)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services networking)
  #:use-module (gnu services audio)
  #:use-module (gnu services vpn)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages version-control)
  #:use-module (luiz systems)
  #:use-module (luiz modules nvidia)
  #:export (%legion-operating-system))

;; ---------------------------------------------------------------------------
;; LUKS mapped devices
;; ---------------------------------------------------------------------------
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

;; ---------------------------------------------------------------------------
;; File systems
;; ---------------------------------------------------------------------------
(define %file-systems
  (cons*
   (file-system
    (mount-point "/boot/efi")
    (device (uuid "8515-3EC5" 'fat32))
    (type "vfat")
    (flags '(noatime)))

   (file-system
    (mount-point "/")
    (device "/dev/mapper/cryptroot")
    (type "ext4")
    (dependencies %mapped-devices))

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
   %nvidia-offload-script
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
   (nvidia-prime-services)

   (list
    (service network-manager-service-type)

    (service nftables-service-type
             (nftables-configuration
              (ruleset (plain-file "nftables.conf" %nftables-ruleset))))

    (service pipewire-service-type)
    (service wireplumber-service-type)

    (service bluetooth-service-type
             (bluetooth-configuration (auto-enable? #f)))

    (service tailscale-service-type))

   (modify-services %base-services
     (delete iptables-service-type))))

;; ---------------------------------------------------------------------------
;; Operating system declaration
;; ---------------------------------------------------------------------------
(define-public %legion-operating-system
  (operating-system
    (inherit %luiz-initial-os)
    (host-name "legion")

    (mapped-devices  %mapped-devices)
    (file-systems    %file-systems)
    (swap-devices    %swap-devices)
    (users           %users)
    (packages        %system-packages)
    (services        %system-services)))

;; Allow this file to be passed directly to `guix system reconfigure`.
%legion-operating-system
