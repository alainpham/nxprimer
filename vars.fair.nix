{
  hostname= "fair";
  targetUserName = "apham";
  targetUserEmail = "apham@localhost";
  keyboardLayout = "fr";
  keyboardModel = "pc105";
  keyboardVariant = "mac";
  wildcardDomain = "houze.dns.army";
  enableKubernetes = true;
  enableVirtualization = true;
  automaticlogin = true;
  disableTurboBoost = true; # disable turbo boost for laptops and minipcs that run intel
  # end of change this

  # harware specific settings
  kernelModules = [ config.boot.kernelPackages.broadcom_sta ];
  extraModulePackages = [ "wl" ];
  blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
    ];
  allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
}