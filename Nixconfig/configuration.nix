{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  environment.etc."os-release".text = ''
    NAME="NixOS"
    ID=nixos
    VERSION="26.11 (Zokor)"
    VERSION_CODENAME=zokor
    PRETTY_NAME="NixOS 26.11 (Zokor)"
    LOGO=nix-snowflake
    HOME_URL="https://nixos.org"
    DOCUMENTATION_URL="https://nixos.orglearn.html"
    SUPPORT_URL="https://nixos.orgcommunity.html"
    BUG_REPORT_URL="https://github.com"
  '';

  # Desktop Environment & Session Management
  programs.hyprland.enable = true;
  services.seatd.enable = true;
  services.getty.autologinUser = "ari";

  # Gaming Optimizations
  programs.gamemode.enable = true; # Automatically optimizes Intel CPU governor for Minecraft

  # Fonts Configuration
  fonts.packages = with pkgs; [
    material-symbols
    rubik
    roboto
    nerd-fonts.caskaydia-cove
  ];

  # Force Wayland for Ozone-based apps (Electron/Chromium)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # System Packages
  environment.systemPackages = with pkgs; [
    kitty
    (discord.override { withVencord = true; })
    fastfetch
    hyfetch
    quickshell
    p7zip
    git
    hyprlock
    prismlauncher
    thunar
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    hyprpaper
    tlp
    obsidian
    yt-dlp
    ffmpeg
    kdePackages.dolphin
    openshot-qt
    fetch
    kdePackages.audiotube
    pear-desktop
  ];

  # System Shell Aliases (Updated to seamlessly use your existing Flakes)
  environment.shellAliases = {
    installpkg = "sudo nano /etc/nixos/configuration.nix";
    rebuild = "sudo nixos-rebuild switch --flake /etc/nixos/#nixos";
  };

  # General System Settings
  nixpkgs.config.allowUnfree = true;

  # Bootloader Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time Zone & Experimental Features
  time.timeZone = "Europe/Vienna";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Internationalization & Locales
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Printing
  services.printing.enable = true;

  # Sound (Pipewire setup over PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # SearXNG - self-hosted metasearch engine
  # Secret key lives outside the Nix store: generate once with
  #   openssl rand -hex 32 | sudo tee /etc/searxng-secret
  # and make sure it's only readable by root (chmod 600).
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;
    environmentFile = "/etc/searxng-secret";
    settings = {
      server = {
        secret_key = "@SEARXNG_SECRET@";
        port = 8080;
        bind_address = "127.0.0.1"; # local-only; flip to 0.0.0.0 + open the firewall for LAN access
      };
      search.formats = [ "html" "json" "rss" ];
    };
  };

  # User Account Settings
  users.users."ari" = {
    isNormalUser = true;
    description = "Ari";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Applications
  programs.firefox.enable = true;

  # State Version
  system.stateVersion = "26.05";
}
