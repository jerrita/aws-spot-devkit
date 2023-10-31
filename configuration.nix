{ config, lib, pkgs, ... }: {
    imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];

    networking.hostName = "devkit";
    environment.systemPackages = with pkgs; [
        vim
        wget
        git

        sysstat
        screenfetch
        htop
        file
        tree
        iproute2

        gcc13
        cmake
        gnumake
        gdb
    ];

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
        shellAliases = {
            k = "kubectl";
            update = "sudo nixos-rebuild switch";
        };
    };
    programs.command-not-found.enable = true;
    
    users.users.jerrita = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINu+Alullj1Meq+a3KNFlIT9lU9YCb8WDr/mZhHCEPji jerrita@mac-air"
        ];
    };

    system.stateVersion = "23.05";
}