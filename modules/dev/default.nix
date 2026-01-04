{ config, lib, pkgs, vars, sources, nixStateVersion, ... }:
{

  programs.java.enable = true;
  programs.java.package = pkgs.jdk17_headless;
  
  environment.systemPackages = with pkgs; [
    ansible
    nodejs_24
    go
    maven
  ]
}