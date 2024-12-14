# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };  
vars = import ./env.nix;
home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
       (import "${home-manager}/nixos")
    ]; 
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  virtualisation.docker.enable = true;
  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.juanc = {
    isNormalUser = true;
    description = "juanc";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      rustdesk
      unstable.neovim
      docker
      git
      chromium
      lazygit
      nodejs
      ripgrep
      xsel
      ngrok
      corepack_22
      keepassxc
      discord
      spotify
      signal-desktop
      telegram-desktop
      brave
      gitkraken 
   ];
  };
  environment.variables.GTK_THEME = "Adwaita:dark";
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  #environment.variables.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  services.qemuGuest.enable = true;
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      wget 
      vim  
      git 
      gcc 
      clang
      gnumake42
      cmake
      pkg-config 
      llvm
      hidapi
      systemd
      udev
      openssl
      anchor
      rustup
      pkg-config
      rustfmt
      llvm
      protobuf
      zlib
      steam-run
      solana-cli
      unzip
  ];
  home-manager.users.juanc = {
    programs.git = {
      enable = true;
      userName = vars.userName;
      userEmail = vars.userEmail;
    };
    home.stateVersion = "24.11";
  };
  programs.ssh.startAgent = true;
  #programs.ssh.identities = [ "/home/juanc/.ssh/github" ];
  programs.ssh.extraConfig = ''
    Host *
     AddKeysToAgent true
     IdentityFile ~/.ssh/github

  '';
  networking.wireguard.enable = true;
  networking.wg-quick.interfaces = {
    wg0 = vars.wg0; 
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  fonts.packages = with pkgs; [
    nerdfonts
  ];
  system.stateVersion = "24.11"; # Did you read the comment?
  system.activationScripts.rustup = ''
    PATH=${pkgs.rustup}/bin:/home/juanc/.cargo/bin:${pkgs.curl}/bin:${pkgs.bash}/bin:run/current-system/sw/bin:/nix/store/8rq01kg6lng5d1fz5wd0mfn2yjaww9sq-system-path/bin/tar:/run/current-system/sw/bin/clang:$PATH
    runuser -u juanc rustup toolchain install 1.75.0
    runuser -u juanc rustup default 1.75.0
    touch /home/juanc/.bashrc 
    rm /home/juanc/.bashrc
    touch /home/juanc/.bashrc 
    echo export PATH=${pkgs.solana-cli}:/home/juanc/programs/bin:'$PATH' >> /home/juanc/.bashrc
    echo export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib >> /home/juanc/.bashrc
    echo export LLVM_CONFIG_PATH=${pkgs.llvm}/bin/llvm-config/bin/llvm-config >> /home/juanc/.bashrc
    echo ${pkgs.systemd.dev}
    echo export PKG_CONFIG_PATH=${pkgs.systemd.dev}/lib/pkgconfig >> /home/juanc/.bashrc
    echo export CFLAGS="-I${pkgs.systemd.dev}/include" >> /home/juanc/.bashrc
    echo export LDFLAGS="-L${pkgs.systemd.dev}/lib" >> /home/juanc/.bashrc
    echo export CC=/run/current-system/sw/bin/clang >> /home/juanc/.bashrc
    echo export NIXPKGS_ALLOW_UNFREE=1 >> /home/juanc/.bashrc
    echo alias build-sbf=cargo-build-sbf >> /home/juanc/.bashrc
    source /home/juanc/.bashrc
    alias build-sbf=cargo-build-sbf
'';

   
}
