{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.sops;
in
{
  options.modules.sops = {
    enable = lib.mkEnableOption "user-level sops-nix secrets with the shared SSH key";
  };

  config = lib.mkIf cfg.enable {
    sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };
}
