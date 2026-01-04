{ pkgs, sources, ... }:

pkgs.appimageTools.wrapType2 {
  pname = "nvtop";
  version = "master";
  src = sources.nvtopurl;
}