{ config, pkgs, ... }: let
   flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
   webcord = (import flake-compat {
     src = builtins.fetchTarball "https://github.com/fufexan/webcord-flake/archive/master.tar.gz";
   }).defaultNix;
   py-pkgs = ps: with ps; [
     pandas
     tqdm
     matplotlib
     scipy
     scikit-learn
     jupyterlab
   ];
in {
  imports =
    [
      ./hardware-configuration.nix
      ./vm.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = ["amdgpu"];

  boot.loader.systemd-boot.enable =true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "wired"; 
  networking.networkmanager.enable = true; 
  networking.firewall.enable = false;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.dbus.enable = true;

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware.pulseaudio.enable = false;

  # bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.tapping = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;

  # asusctl and supergfxctl
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  
  programs.fish.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  fonts.enableDefaultFonts = true;
  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fonts = with pkgs; [
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra

    liberation_ttf
    ubuntu_font_family

    fira-code
    fira-code-symbols

    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    victor-mono
    font-awesome_5

    source-han-sans-japanese
    source-han-sans-korean
    source-han-sans-simplified-chinese
    source-han-sans-traditional-chinese
  ];

  # docker
  virtualisation.docker.enable = true;

  users.users.amon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker" ];
    initialPassword = "changeme";
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    
    # GUI
    firefox vlc waybar swww kitty
    mako libnotify rofi-wayland pamixer
    networkmanagerapplet brightnessctl
    (waybar.overrideAttrs (oldAttrs: {
 	mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })
    )
    webcord.packages.${system}.default

    # screenshot pkgs
    grim slurp wl-clipboard
    unzip
    sudo
   
    # dev
    gcc cmake clang ninja distrobox
    vscodium docker-compose git
    (python3.withPackages py-pkgs)
    
    # cli
    wget ffmpeg file curl neofetch
    starship fontfor
  ];

  system.stateVersion = "23.05";
}
