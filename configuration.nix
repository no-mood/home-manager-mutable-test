# Minimal NixOS configuration for testing
# This is optional - you can test with standalone home-manager

{ config, pkgs, ... }:

{
  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "testhost";
  networking.networkmanager.enable = true;

  # User
  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "test";
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release
  system.stateVersion = "24.11";
}
