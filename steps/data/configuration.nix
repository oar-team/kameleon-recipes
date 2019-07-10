# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = ""; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     netcat-gnu
     wget 
     vim
   ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  #
  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA11hK5N+moQadYFcW/Cf1OqoQPdsm+ABRII1TEWgji4ZqzXbX36vIksvmGmibIvRiZ0J6yJ5/M6GLbZqcMengPBIaCmd/3OrdYpgjAAfIhhh7GN3jRRcq5K0SHnaIU4JjyBcNxEdv1krii8cr1HPRv0x8eHPdOc4JGA3FmH97L+8= auguste@abenaki"];
    services.openssh = {
       enable = true;
       startWhenNeeded = true;
    };

systemd.services."serial-getty@ttyS0".enable = true;
boot.loader.grub.device = "/dev/sda3";
boot.loader.grub.forceInstall = true;

boot.kernelParams = ["console=tty0 console=ttyS0,38400n8 modprobe.blacklist=myri10ge"];
boot.loader.grub.extraConfig = ''
    serial --speed=38400 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

# To satify Kadeploy's port scanning 
networking.firewall.enable = false;
#boot.postBootCommands="(while true; do /nix/var/nix/profiles/system/sw/bin/nc -l 25300; done) &";

  system.stateVersion = "19.09"; # Did you read the comment?
}
