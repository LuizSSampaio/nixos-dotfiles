{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Luiz Henrique Silva Sampaio";
    userEmail = "luizhsampaio07@gmail.com";
    extraConfig.init.defaultBranch = "main";
  };
}
