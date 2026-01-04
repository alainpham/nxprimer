{ appimageTools, sources, ... }:

appimageTools.wrapType2 {
    pname = "nvtop";
    version = "master";
    src = sources.nvtopurl;
}