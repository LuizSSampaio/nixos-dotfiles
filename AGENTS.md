# AGENTS.md - AI Coding Agent Guidelines

This document provides guidelines for AI coding agents working in this NixOS dotfiles repository.

## Project Overview

This is a **NixOS configuration repository** using Nix Flakes for declarative system management.
The repository configures NixOS systems with home-manager integration for user-level configuration.

| Attribute       | Value                                      |
|-----------------|--------------------------------------------|
| Language        | Nix                                        |
| Build System    | Nix Flakes                                 |
| Platform        | x86_64-linux                               |
| Package Source  | nixpkgs unstable                           |
| User Management | home-manager (integrated as NixOS module) |

## Repository Structure

```
nixos-dotfiles/
├── flake.nix                      # Main entry point - inputs and system definitions
├── flake.lock                     # Locked dependency versions
├── hosts/                         # Per-machine configurations
│   ├── vm/
│   │   ├── hardware-configuration.nix
│   │   └── user.nix               # Home-manager config for vm
│   └── laptop/
│       ├── hardware-configuration.nix
│       └── user.nix               # Home-manager config for laptop
└── modules/                       # Shared/reusable modules
    └── system/
        └── configuration.nix      # Base system configuration
```

## Build Commands

```bash
# Build and switch to configuration (requires sudo)
sudo nixos-rebuild switch --flake .#vm
sudo nixos-rebuild switch --flake .#laptop

# Build without switching (test build)
nixos-rebuild build --flake .#vm

# Build a VM for testing (no sudo needed)
nixos-rebuild build-vm --flake .#vm
```

## Validation and Testing

```bash
nix flake check                               # Validate flake syntax and evaluate outputs
nix flake show                                # Show all flake outputs
nix build .#nixosConfigurations.vm.config.system.build.toplevel
```

## Dependency Management

```bash
nix flake update                              # Update all flake inputs
nix flake lock --update-input nixpkgs         # Update specific input
nix flake metadata                            # Show current input versions
```

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

- Relative paths for local modules: `./modules/system/configuration.nix`
- String interpolation for dynamic paths: `(./. + "/hosts/${hostname}/user.nix")`

### Comments

- Use `#` for single-line comments
- Use `/* */` for multi-line comments (sparingly)

## Formatting

No formatter is currently configured. Recommended:
```bash
nix run nixpkgs#nixfmt -- flake.nix    # official formatter
nix run nixpkgs#alejandra -- .          # popular alternative
```

## Key Configuration Patterns

### Adding a New Host

1. Create `hosts/<hostname>/hardware-configuration.nix`
2. Create `hosts/<hostname>/user.nix` for home-manager
3. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkSystem inputs.nixpkgs "x86_64-linux" "<hostname>";
   ```

### Adding System Packages

Edit `modules/system/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [ neovim git ];
```

### Adding User Packages (via home-manager)

Edit `hosts/<hostname>/user.nix`:
```nix
home.packages = with pkgs; [ /* user-specific packages */ ];
```

## Error Handling

1. **State Version**: Do not change `system.stateVersion` unless you understand the implications
2. **Hardware Config**: `hardware-configuration.nix` is auto-generated; manual edits may be overwritten
3. **Flakes**: Experimental features `nix-command` and `flakes` are enabled
4. **User**: Primary user is `luiz` in the `wheel` and `networkmanager` groups

## Debugging Tips

```bash
nix repl                                      # Enter a Nix REPL
:lf .                                         # Load flake in REPL

nix search nixpkgs <package-name>             # Search for packages
```
