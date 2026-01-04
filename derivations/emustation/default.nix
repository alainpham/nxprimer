{ appimageTools, sources, ... }:

appimageTools.wrapType2 {
    pname = "estation";
    version = "master";
    src = sources.emustationurl;
}