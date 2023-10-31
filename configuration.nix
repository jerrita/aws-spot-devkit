{ config, lib, pkgs, ... }: {
    imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
    ec2.efi = true;

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
        enableAutosuggestions = true;
        enableCompletion = true;
        shellAliases = {
            k = "kubectl";
            update = "sudo nixos-rebuild switch";
        };

        zplug = {
            enable = true;
            plugins = [
                { name = "zsh-users/zsh-autosuggestions"; }
            ];
        };

        oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "sonicradish";
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