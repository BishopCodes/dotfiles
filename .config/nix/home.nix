{ config, pkgs, ... }:

{
  programs.sdkman.enable = true;

  programs.zsh.enable = true;
  programs.bash.enable = true;

  programs.sdkman.candidates = [
    "java"
    "groovy"
    "kotlin"
  ];

  environment.variables = {
    SDKMAN_DIR = "$HOME/.sdkman";
  };
