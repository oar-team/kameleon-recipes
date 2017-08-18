{ config, pkgs, ...} :
{
  boot.loader.grub.device = "/dev/sda";

  # Enable virtualbox guest additions
  virtualisation.virtualbox.guest.enable = true;

  # Enable the sshd daemon so you can ssh
  # into it
  services.openssh.enable = true;

  fileSystems = [
    { mountPoint = "/";
      label = "nixos";
    }
  ];

  users.users.root.initialHashedPassword = "";

}
