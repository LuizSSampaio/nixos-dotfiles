{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.system.sops;
in
{
  options.modules.system.sops = {
    enable = lib.mkEnableOption "system-level sops-nix secrets with the shared SSH key";
  };

  config = lib.mkIf cfg.enable {
    sops.age.sshKeyPaths = [ "${config.users.users.luiz.home}/.ssh/id_ed25519" ];
  };
}
