# all versions of different sources
let
  retroarchversion = "1.22.2";
in
{
  # initial state version
  dotfilesgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dotfiles.git";
    ref = "master";
    rev = "c55b040e715008de974a4c502233201a69a853f6";
  };

  # desktop related
  dwmgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwm-flexipatch.git";
    ref = "master";
    rev = "5a42b3907ef5a862ba8fa4cae6507f9db1a78480";
  };

  stgit = builtins.fetchGit {
    url = "https://github.com/alainpham/st-flexipatch.git";
    ref = "master";
    rev = "6d4b441d4710b694a208a97de7373f06173737f3";
  };

  dmenugit = builtins.fetchGit {
    url = "https://github.com/alainpham/dmenu-flexipatch.git";
    ref = "master";
    rev = "90ad650797feab1d9768e93627301fd90b12b4fe";
  };

  slockgit = builtins.fetchGit {
    url = "https://github.com/alainpham/slock-flexipatch.git";
    ref = "master";
    rev = "6c52d690584762a91d59191bd795bff438564103";
  };

  dwmblocksgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwmblocks.git";
    ref = "master";
    rev = "1e796d6fe576afb7c941a0f51b3d2670eb823409";
  };

  gshortsgit = builtins.fetchGit {
    url = "https://github.com/alainpham/gshorts.git";
    ref = "master";
    rev = "dda21ee0407252346fd8839d12ce18952c76ac76";
  };

  nvtopurl =  builtins.fetchurl {
    url = "https://github.com/Syllo/nvtop/releases/download/3.2.0/nvtop-3.2.0-x86_64.AppImage";
    sha256 = "33c54fb7025f43a213db8e98308860d400db3349a61fc9382fe4736c7d2580c4";
    name = "nvtop.AppImage";
  };

  estationurl = builtins.fetchurl {
    url = "https://gitlab.com/es-de/emulationstation-de/-/package_files/246875981/download";
    sha256 = "4cb66cfc923099711cfa0eddd83db64744a6294e02e3ffd19ee867f77a88ec7e";
    name = "estation.AppImage";
  };
  
  retroarchversion = retroarchversion;

  retroarchpkgurl = builtins.fetchurl {
    url = "https://buildbot.libretro.com/stable/${retroarchversion}/linux/x86_64/RetroArch.7z";
    sha256 = "7d62da9a21397d6e1b9490785cedbeafd262781b50115076736fbe8a77ef30e9";
  };

  retroarchcorespkgurl = builtins.fetchurl {
    url = "https://buildbot.libretro.com/stable/${retroarchversion}/linux/x86_64/RetroArch_cores.7z";
    sha256 = "4b7ed8dc97d4bf035fce182c64b5658c7662e2e9e5d42129538afbd4b6096307";
  };

  retroarchbiosurl = builtins.fetchurl {
    url = "https://github.com/Abdess/retrobios/releases/download/v2026.03.17.2/Lakka_RetroArch_BIOS_Pack.zip";
    sha256 = "cd93eb2b31b9487bef728ac011c92bd84faac51a6d3ea6502d74d2ced021942a";
  };

  pcsx2biospkgurl = builtins.fetchurl {
    url = "https://github.com/archtaurus/RetroPieBIOS/raw/master/BIOS/pcsx2/bios/ps2-0230a-20080220.bin";
    sha256 = "f609ed1ca62437519828cdd824b5ea79417fd756e71a4178443483e3781fedd2";
  };

  decklinksdkurl = builtins.fetchurl {
    url = "http://192.168.8.100:28000/blackmagic/bmsdk12.9.zip";
    sha256 = "ffcd0e39e50aa788954d02a27d4368a1681fadf086fec3d2b53ae68463308578";
  };

  blackmagicdesktopvideosrc = builtins.fetchurl {
    url = "http://192.168.8.100:28000/blackmagic/Blackmagic_Desktop_Video_Linux_12.9-patched.tar";
    sha256 = "e8d522d19accbe926aacb20feaada1aba695fdea0025cd84aa67356f431b0c9f";
  };

}