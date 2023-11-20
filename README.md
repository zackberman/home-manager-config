# My Home Manager configuration

### Commands I might want to run/good resources

- `nix flake update`: In the Home Manager manual's words, "The flake inputs are
  not automatically updated by Home Manager. You need to use the standard
  `nix flake update` command for that.

- `home-manager switch --flake .`: This installs files/applications/symlinks
  where they belong. Clone this repo and run it from inside.

- Configuration options for every module:
  https://nix-community.github.io/home-manager/options.html

### TODO

- Migrate .vimrc. See documention for
  [programs.vim.plugins](https://nix-community.github.io/home-manager/options.html#opt-programs.vim.plugins).
  It looks like not all of my plugins are in nixpkgs. But it looks like maybe it
  wouldn't be that hard to package them myself? See the `buildVimPluginFrom2Nix`
  pattern in [vim/plugins/generated.nix](https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/applications/editors/vim/plugins/generated.nix).

### History

I ran the nix-darwin uninstaller. Then, I uninstalled Nix by following these
instructions: https://nixos.org/manual/nix/stable/installation/uninstall#macos.
The instructions specifically say you don't need to reboot to finish
uninstallation... but I decided to do so anyway.

Next, I ran the Determine Nix Installer:
https://github.com/DeterminateSystems/nix-installer

Next, Home Manager. I followed instructions in the official manual, skipping
section 1 ("Installing Home Manager") and opting instead to use flakes. First,
I set up my home.nix configuration according to section 2.1. To start, I
included some of the packages I use most in home.packages. Then I followed
section 3.2 ("Standalone setup"), which installs home-manager and runs "switch"
for the first time. I did this with my home.nix in the default location, but I
subsequently moved this file into this git repo from which I can run
"home-manager switch --flake .". I configured bash and did my best to move
individual bash options into the proper Home Manager bash config section, which
lets you express the things you commonly express in a .bashrc as Nix values
instead.

Home Manager can't actually set my shell at the OS level. To do that, after
running `home-manager switch --flake .`, I ran
`realpath ~/.nix-profile/bin/bash` and then appended the result to /etc/shells
(manually, in vim) and changed my shell using `chsh`.

