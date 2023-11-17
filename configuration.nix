{config, pkgs, ... }: 
let
   flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
   webcord = (import flake-compat {
     src = builtins.fetchTarball "https://github.com/fufexan/webcord-flake/archive/master.tar.gz";
   }).defaultNix;
   obsidian = pkgs.callPackage ./packages/obsidian.nix {};
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

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

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
  
  # enable fish
  programs.fish.enable = true;

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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # unfree pkgs
  nixpkgs.config = {
    allowUnfree = true;
  };

  users.users.amon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" "docker" ];
    initialPassword = "changeme";
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    
    # GUI
    vlc waybar swww kitty
    mako libnotify rofi-wayland pamixer
    networkmanagerapplet brightnessctl
    (waybar.overrideAttrs (oldAttrs: {
 	mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })
    )
    webcord.packages.${system}.default
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
    obsidian

    # screenshot pkgs
    flameshot
   
    # dev
    docker-compose git vscodium
    
    # cli
    wget ffmpeg file curl pfetch
    starship fontfor htop sudo
    unzip
  ];

  system.stateVersion = "23.05";
}
