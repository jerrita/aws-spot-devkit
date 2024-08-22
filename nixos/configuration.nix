{ config, lib, pkgs, ... }: {
    imports = [ 
        <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
        ./cachix.nix
        ./env.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "devkit";
    environment.systemPackages = with pkgs; [
        tmux
        neovim
        wget
        git

        sysstat
        screenfetch
        htop
        file
        tree
        iproute2

        cachix
        jq
    ];

    services.resolved.enable = false;
    networking.resolvconf.enable = false;
    environment.etc."resolv.conf".text = "nameserver 8.8.8.8\nnameserver 1.1.1.1\n";

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
    };

    security.sudo.wheelNeedsPassword = false;
    services.openssh.enable = true;
    programs.nix-ld.enable = true;   # fix vscode remote
    programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestions.enable = true;
        enableCompletion = true;
        ohMyZsh = {
            enable = true;
            theme = "sonicradish";
            plugins = [ "git" ];
        };
    };
    
    users.users.jerrita = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6m8fiwUgm+iSczcsBm/mzH2yoyjiFvlUSs4N4U7urU jerrita@Jerrita-Air"
        ];
    };

    system.stateVersion = "23.05";
}
