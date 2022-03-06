{ pkgs, config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [

    # cli tools
    exa ffmpeg unzip xclip pfetch
    libnotify gnupg update-nix-fetchgit yt-dlp
    ripgrep rsync imagemagick
    scrot bottom newsboat
    tealdeer cava killall onefetch
    # gui apps
    obs-studio mpv sxiv 
    transmission-gtk pavucontrol pcmanfm
    # unfree apps (sorry daddy stallman)
    discord minecraft steam
    # dev tools
    python3 git jdk dconf gcc rustc rustfmt cargo
  ];
}
