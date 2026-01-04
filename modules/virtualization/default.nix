{ config, lib, pkgs, vars, nixStateVersion, ... }:
{

  ##################################################
  # virtualization
  ##################################################
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users = {
    ${vars.targetUserName} = {
      extraGroups = [ 
        "libvirtd"
        "kvm"
      ];
    };
  };

  systemd.services.firstboot-virt = {
    enable = true;
    description = "firstboot-virt";
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.vmscripts}/bin/firstboot-virt";
    };
  };

  # initialize virtualization folders in home
  home-manager.users.${vars.targetUserName} = { lib, ... }: {
    home.activation = {
      init-homefld = lib.hm.dag.entryAfter ["writeBoundary"] ''
        folders="
          virt/runtime
          virt/images
        "
        for folder in $(echo $folders); do
          if [ ! -L "$HOME/$folder" ] && [ ! -d "$HOME/$folder" ]; then
            mkdir -p "$HOME/$folder"
          fi
        done
        touch "$HOME/virt/runtime/vms"
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    # virtualization todo
    cdrkit
    libosinfo
    vmscripts
  ]
}