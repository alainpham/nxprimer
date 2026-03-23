{ pkgs, sources, ... }:

pkgs.appimageTools.wrapType2 {
  pname = "ppsspp";
  version = "master";
  src = sources.ppssppurl;
}