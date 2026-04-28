(define-module (luiz systems)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system file-systems)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (%luiz-timezone
            %luiz-locale
            %luiz-keyboard-layout
            %luiz-initrd-modules
            %luiz-initial-os))

(define-public %luiz-timezone "America/Sao_Paulo")
(define-public %luiz-locale "en_US.UTF-8")

(define-public %luiz-keyboard-layout
  (keyboard-layout "us" "intl"))

;; initrd kernel modules common to all hosts.
;; Mirrors boot.initrd.availableKernelModules in the NixOS configs.
(define-public %luiz-initrd-modules
  (append
   '("nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc"
     "dm_mod" "dm_crypt" "aes_x86_64" "sha256_generic")
   %base-initrd-modules))

;; Skeleton operating-system used as a base for all host configurations.
;; Per-host files should override individual fields via inheritance or
;; by composing on top of this value.
(define-public %luiz-initial-os
  (operating-system
    (host-name "luiz")
    (locale %luiz-locale)
    (timezone %luiz-timezone)

    (locale-definitions
     (list
      (locale-definition (name "en_US.UTF-8") (source "en_US"))
      (locale-definition (name "pt_BR.UTF-8") (source "pt_BR"))))

    (keyboard-layout %luiz-keyboard-layout)

    ;; Non-free Linux kernel + microcode initrd (from nonguix).
    (kernel linux)
    (initrd microcode-initrd)
    (initrd-modules %luiz-initrd-modules)

    ;; kvm-amd enables AMD virtualisation support.
    (kernel-arguments
     (append '("kvm-amd") %default-kernel-arguments))

    (bootloader
     (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (targets '("/boot/efi"))
      (keyboard-layout %luiz-keyboard-layout)
      (timeout 3)))

    (services '())
    (file-systems %base-file-systems)
    (sudoers-file #f)))
