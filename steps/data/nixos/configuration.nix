# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget 
    vim
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda3";
  boot.loader.grub.forceInstall = true;

  boot.kernelParams = ["console=tty0 console=ttyS0,38400n8 modprobe.blacklist=myri10ge"];
  boot.loader.grub.extraConfig = ''
    serial --speed=38400 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';
  systemd.services."serial-getty@ttyS0".enable = true;

  networking.hostName = ""; # Dhcp will set hostname
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
  };

  
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  #
  system.stateVersion = "19.09"; # Did you read the comment?
}
