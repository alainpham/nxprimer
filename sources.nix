# all versions of different sources
let
  retroarchversion = "1.22.2";
in
{
  # initial state version
  dotfilesgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dotfiles.git";
    ref = "master";
    rev = "c84f27acfda06e2b44d51c5521328b2098bdb52a";
  };

  # desktop related
  dwmgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwm-flexipatch.git";
    ref = "master";
    rev = "2f69d3c1e91bcd651f13b3184be7bc63c8ace395";
  };

  stgit = builtins.fetchGit {
    url = "https://github.com/alainpham/st-flexipatch.git";
    ref = "master";
    rev = "465a432f7dfb5ef01b2436fd35c0f8ee69920b06";
  };

  dmenugit = builtins.fetchGit {
    url = "https://github.com/alainpham/dmenu-flexipatch.git";
    ref = "master";
    rev = "90ad650797feab1d9768e93627301fd90b12b4fe";
  };

  slockgit = builtins.fetchGit {
    url = "https://github.com/alainpham/slock-flexipatch.git";
    ref = "master";
    rev = "b3eb868cfd11a493698afa97aa09afcceed4bf57";
  };

  dwmblocksgit = builtins.fetchGit {
    url = "https://github.com/alainpham/dwmblocks.git";
    ref = "master";
    rev = "bf55e259f05b1f1e497dc63ed45f332ba1edd174";
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
    url = "https://github.com/Abdess/retroarch_system/releases/download/v20220308/RetroArch_v1.10.1.zip";
    sha256 = "341c5011976e2e650ac991411daf74701327c26974b59b89f8a63b61cbb61b18";
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
    url = "http://192.168.8.100:28000/blackmagic/desktopvideo-12.9a3-x86_64-patched.tar.gz";
    sha256 = "44f571dcd325882f4b1e8dcffcef5899a8fcd297547b5f5414937e9cb4141e80";
  };

}