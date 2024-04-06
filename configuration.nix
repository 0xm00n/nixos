{config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./vm.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.opengl.enable = true;

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

  # enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # enable touchpad support.
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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
    firefox librewolf

    # screenshot pkgs
    jq grim slurp wl-clipboard 
   
    # dev
    docker-compose git

    # cli
    wget ffmpeg file curl pfetch
    starship fontfor htop sudo
    unzip zip glow circumflex
    nnn
  ];

  system.stateVersion = "23.11";
}
