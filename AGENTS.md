# AGENTS.md - AI Coding Agent Guidelines

This document provides guidelines for AI coding agents working in this NixOS dotfiles repository.

## Project Overview

This is a **NixOS configuration repository** using Nix Flakes for declarative system management.
The repository configures NixOS systems with home-manager integration for user-level configuration.

| Attribute        | Value                                             |
|-----------------|---------------------------------------------------|
| Language         | Nix                                               |
| Build System     | Nix Flakes                                        |
| Platform         | x86_64-linux                                      |
| Package Source   | nixpkgs unstable                                  |
| User Management  | home-manager (integrated as NixOS module)         |
| Disk Management  | disko (declarative; describes the EXISTING layout)|
| State Management | preservation (impermanence; volatile tmpfs `/`)   |

## Repository Structure

```
nixos-dotfiles/
├── flake.nix                          # Main entry point - inputs and system definitions
├── flake.lock                         # Locked dependency versions
├── hosts/
│   ├── legion/                        # The real machine (AMD laptop, Limine, niri)
│   │   ├── disko.nix                  # Disk layout — EXISTING partitions; read its safety header!
│   │   ├── persistence.nix            # preservation profile: everything that survives reboots
│   │   ├── hardware-configuration.nix # hardware detection only (mounts live in disko.nix)
│   │   ├── system.nix                 # host system config (imports disko.nix + persistence.nix)
│   │   └── user.nix                   # home-manager config for luiz
│   └── vm/                            # stale VM host (entry commented out in flake.nix)
└── modules/                           # shared toggle-style modules (user-level, modules/system/*)
```

## Build Commands

```bash
# Build without switching (test build / validation)
nix build .#nixosConfigurations.legion.config.system.build.toplevel

# Install for next boot WITHOUT activating at runtime, then reboot
sudo nixos-rebuild boot --flake .#legion

# Build and switch to configuration (requires sudo) — normal changes only
sudo nixos-rebuild switch --flake .#legion
```

**IMPORTANT:** if a change touches `disko.devices`, `fileSystems`, or anything
mount-related, always deploy with `nixos-rebuild boot` + reboot — never
`switch`/`test`, which attempt to start/stop mount units at runtime (e.g. a
new tmpfs root must never be mounted over the live root).

## Disk Management (disko) — SAFETY RULES

- `hosts/legion/disko.nix` describes the machine's **existing** partitions,
  LUKS containers and LVM VG, pinned by PARTUUID with exact sector boundaries
  and `destroy = false` on both disks.
- The disko NixOS module is used **declaratively only**: it generates
  `fileSystems`, `boot.initrd.luks.devices` and `swapDevices`. It never
  formats anything at build or activation time.
- **NEVER run the disko CLI against this repository** (`disko`,
  `disko-install`, `nix run github:nix-community/disko …`). Its default mode
  is destroy+format+mount. Any intentional repartitioning requires deleting
  the safety header in `hosts/legion/disko.nix` first.
- When changing the disk layout: edit `hosts/legion/disko.nix`, then
  `nix flake check`, `nix build …toplevel`, and diff `result/etc/fstab`
  against `/etc/fstab` **before** deploying with `nixos-rebuild boot`.

## Impermanence (preservation)

- `/` is a tmpfs wiped on every boot. The root ext4 (LUKS `cryptroot`) is
  mounted at `/nix` and is the persistent store: it holds `/nix/store` and,
  at its on-disk root, the pre-migration `/etc`, `/home`, `/var`, `/root`
  trees (zero data was moved during migration).
- `hosts/legion/persistence.nix` lists everything bind-mounted back from
  `/nix` at boot. **A path missing from that list loses its new writes on
  reboot** (its old pre-migration data still exists under `/nix/…`).
- **Rollback:** boot a previous generation from the Limine boot menu. Older
  generations mount the ext4 at `/` again, so the pre-impermanence system
  boots exactly as it was — nothing on disk was changed by the migration.
- **Canary check** (run periodically during the first weeks; finds state that
  is written to the volatile home but not persisted):
  ```bash
  sudo bash -c 'diff <(cd /home/luiz && find . | sort) <(cd /nix/home/luiz && find . | sort)'
  ```
  `<` lines = written but NOT persisted → add to `users.luiz.directories`/
  `files` in `hosts/legion/persistence.nix`. `>` lines = pre-migration
  leftovers on the persistent side (informational).
- **Recover a forgotten path:** copy it back from the persistent tree
  (`/nix/home/luiz/<path>`), then add it to the preserve list.
- `system.autoUpgrade.allowReboot` is forced off during the canary period
  (`hosts/legion/system.nix`); remove that override once the preserve list
  is validated in daily use.

## Validation and Testing

```bash
nix flake check                                # Validate flake syntax and evaluate outputs
nix flake show                                 # Show all flake outputs
nix build .#nixosConfigurations.legion.config.system.build.toplevel
diff /etc/fstab result/etc/fstab               # for mount-affecting changes
```

## Dependency Management

```bash
nix flake update                               # Update all flake inputs
nix flake lock --update-input nixpkgs          # Update specific input
nix flake metadata                             # Show current input versions
```

## Secrets Management (sops-nix)

Secrets are encrypted in-repo with sops-nix. The single identity is a dedicated
passphrase-less SSH ed25519 key (`~/.ssh/id_ed25519`); sops-nix converts it to
an age key at activation via `sops.age.sshKeyPaths`. With impermanence, the key
itself is preserved via `users.luiz.directories = [ ".ssh" ]` in
`hosts/legion/persistence.nix` — keep it that way or system secrets stop
decrypting.

| Item                    | Path                                        |
|-------------------------|---------------------------------------------|
| Encryption rules        | `.sops.yaml`                                |
| Encrypted secret files  | `secrets/*.yaml`                            |
| SSH key (private)       | `~/.ssh/id_ed25519` (passphrase-less, dedicated) |
| CLI identity (derived)  | `~/.config/sops/age/keys.txt` (derived from the SSH key) |
| Decrypted (home-manager)| `~/.config/sops-nix/secrets/<name>` (symlink into `$XDG_RUNTIME_DIR`) |

```bash
sops secrets/opencode.yaml    # edit secrets (uses derived identity at default path)
```

To add a secret: add a key to a file under `secrets/`, define `sops.secrets.<name>` with
`sopsFile`, then reference it via the stable symlink
`~/.config/sops-nix/secrets/<name>` (config files can use opencode-style
`{file:...}` interpolation). Never commit plaintext secret values.

The `.sops.yaml` recipient is the SSH public key converted with
`nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/.ssh/id_ed25519.pub`.
To rotate the SSH key, keep the old key in place until the secrets are
re-encrypted: generate the new key at a temp path, put its recipient in
`.sops.yaml`, run `sops updatekeys` on every file under `secrets/` (this still
decrypts with the old identity), then swap the new key into
`~/.ssh/id_ed25519` and re-derive the CLI identity
(`ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt`).
Run `git add` on changed files under `secrets/` before rebuilding — git flakes
ignore unstaged new files.

## Code Style Guidelines

### Nix Language Conventions

1. **Indentation**: Use 2 spaces for indentation (no tabs)

2. **Attribute Sets**: Opening brace on same line, closing brace aligned
   ```nix
   { attribute = value; nested = { inner = "value"; }; }
   ```

3. **Lists**: One item per line for multi-item lists
   ```nix
   environment.systemPackages = with pkgs; [ neovim git wget ];
   ```

4. **Function Arguments**: Use destructuring: `{ config, pkgs, lib, ... }:`

5. **Module Structure**: Standard module pattern
   ```nix
   { config, pkgs, ... }: { imports = [ ]; }
   ```

### Naming Conventions

- **Files**: lowercase with hyphens: `hardware-configuration.nix`, `user.nix`
- **Directories**: lowercase: `hosts/`, `modules/`
- **Attributes**: camelCase for NixOS options (following nixpkgs convention)

### Import Patterns

- Relative paths for local modules: `../../modules/system/default.nix`
- String interpolation for dynamic paths: `(./. + "/hosts/${hostname}/user.nix")`

### Comments

- Use `#` for single-line comments
- Use `/* */` for multi-line comments (sparingly)

## Formatting

No formatter is enforced in CI. Recommended:
```bash
nix run nixpkgs#nixfmt -- flake.nix    # official formatter
nix run nixpkgs#alejandra -- .          # popular alternative
```

## Key Configuration Patterns

### Adding a New Host

1. Create `hosts/<hostname>/hardware-configuration.nix` (hardware detection only)
2. Create `hosts/<hostname>/disko.nix` (disk layout — mind the safety rules above)
3. Create `hosts/<hostname>/system.nix` (imports `../../modules/system/default.nix` + local modules)
4. Create `hosts/<hostname>/user.nix` for home-manager
5. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkSystem inputs.nixpkgs "x86_64-linux" "<hostname>";
   ```

### Adding System Packages / Services

System services live in `modules/system/` (toggle modules via `modules.system.*`
in the host's `system.nix`); user packages live in `modules/packages.nix`.

## Error Handling

1. **State Version**: Do not change `system.stateVersion` unless you understand the implications
2. **Hardware Config**: `hardware-configuration.nix` is auto-generated by `nixos-generate-config`; mount declarations belong in `disko.nix`
3. **Flakes**: Experimental features `nix-command` and `flakes` are enabled
4. **User**: Primary user is `luiz` in the `wheel` and `networkmanager` groups

## Debugging Tips

```bash
nix repl                                      # Enter a Nix REPL
:lf .                                         # Load flake in REPL

nix search nixpkgs <package-name>             # Search for packages
```
