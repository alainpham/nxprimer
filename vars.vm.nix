{
  nixversion = "25.05";
  hostname= "nxvm";
  targetUserName = "apham";
  targetUserEmail = "apham@localhost";
  keyboardLayout = "fr";
  keyboardModel = "pc105"; # for macbook use "macbook79"
  wildcardDomain = "houze.dns.army";
  enableKubernetes = true;
  automaticlogin = true;
  disableTurboBoost = true; # disable turbo boost for laptops and minipcs that run intel
  # end of change this
}