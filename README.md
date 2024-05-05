# My Home Manager configuration

### Commands I might want to run/good resources

- `nix flake update`: In the Home Manager manual's words, "The flake inputs are
  not automatically updated by Home Manager. You need to use the standard
  `nix flake update` command for that."

- `nix flake lock`: ... Or maybe this is the command? According to
  [this blog post](https://www.bekk.christmas/post/2021/16/dotfiles-with-nix-and-home-manager):
  "You can update all your programs by navigating to your dotfiles folder and
  running `nix flake lock`, which updates the `flake.lock` file."

- `scripts/switch <profile>` (where profile is either `macos` or `wsl`): This
  runs `home-manager switch --flake .#<profile>`, which installs
  files/applications/symlinks where they belong. Run this in the root directory
  of the repository.

- Configuration options for every module:
  https://nix-community.github.io/home-manager/options.xhtml

### TODO

- Migrate git config.
- Migrate karabiner-elements config. Ideally abandon jsonnet and generate it
  natively in Nix. Install the configuration using
  `xdg.configFile."karabiner/karabiner.json".txt = ...`.

### History

#### First steps on macOS

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

#### Allowing for multiple configuration profiles

I tried to replicate my installation of both nix and home-manager in WSL on my
Dell XPS. This mostly worked, except that the nix installation failed to create
my per-user nix profile directory, which prohibited me from installing anything
(i.e. home-manager). After searching around online, I managed to work around
this like so:

  ```bash
  sudo mkdir -m 0755 -p /nix/var/nix/profiles/per-user/zberman
  sudo chown -R zberman:nixbld /nix/var/nix/profiles/per-user/zberman/
  ```

Then I replicated some of what I observed in
[this dotfiles repo](https://github.com/ereslibre/dotfiles/) to support multiple
configuration profiles ("macos" and "wsl").

#### Configuring ssh and github so I can use private flake inputs

##### macOS

I installed [Secretive](https://github.com/maxgoedjen/secretive) for macOS on my
Mac Studio by downloading the release directly from the release page and moving
the application to my Applications folder. The application instructs you to
export `SSH_AUTH_SOCK` in bash and add a couple of lines to `~/.ssh/config`,
both of which I achieved through Home Manager. I used Secretive to generate a
new private key, and I added the public key to my github account through the
browser.

#### WSL

This was difficult and my solution is fragile. I started following the 1Password
instructions for setting up 1Password's ssh agent for use in WSL. But I realized
this involves setting up git in WSL to use ssh.exe from Windows, which seems
antithetical to this whole Home Manager setup. I identified five possible
solutions. I gave #3 a shot first and then switched to #1:

1. Follow [this guide](https://dev.to/d4vsanchez/use-1password-ssh-agent-in-wsl-2j6m)
   to use npiperelay.exe and socat. First, install 1Password for Windows and
   enable the SSH agent. Then, build npiperelay.exe (I was able to cross-compile
   for Windows in WSL with a single command:
   `GOOS=windows nix run nixpkgs#go -- install github.com/jstarks/npiperelay@latest`.
   Then, I copied the resulting binary (which appeared within `~/go/bin`) to a
   Windows directory that was already part of my Windows path. Hacky! Finally, I
   modified the glue code it provides to fit nicely into my Home Manager bash
   configuration (see [agent-bridge.sh](/agent-bridge.sh)).
2. Install 1Password through Home Manager and try to set up the ssh agent
   natively in Linux. This will probably involve me manually typing a password
   (as opposed to using biometrics) but it's reasonably clean. That being said,
   it probably prevents proper bootstrapping of my Home Manager configuration,
   because I won't be able to use 1Password's ssh agent for the very first
   installation. That's probably fine though, I can just use my github login.
3. Install 1Password in WSL without Nix. Set up the ssh agent using 1Password's
   instructions. This is effectively what I did with Secretive on macOS. I
   actually tried this, but I couldn't figure out how to log into 1Password in
   WSL because 1Password in WSL seemingly couldn't interact with my Yubikey.
4. Use tpm2-pkcs11 to generate the key. [Here's](https://www.ledger.com/blog/ssh-with-tpm)
   a guide. Meanwhile, the official (?) guide (says)[https://github.com/tpm2-software/tpm2-pkcs11/blob/master/docs/SSH.md#step-5---ensuring-the-library-is-in-a-good-path)
   ssh only accepts pkcs11 libraries in trusted locations. It appears you can
   (whitelist specific pkcs11 libraries using nixos modules)[https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/ssh.nix#L125C11-L125C11],
   which (apparently)[https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/ssh.nix#L326C26-L326C26]
   just tells systemd to pass an extra argument to ssh-agent when launching it.
   Seem like something I might have to configure manually outside of Nix, just
   like I did with Secretive on macOS.
5. Try out KeePassXC, either for all of its password management features or just
   its ssh agent.

This surely means I can't actually bootstrap my WSL Home Manager configuration
if I have private flake inputs, because I'll need to run `home-manager switch`
to install my .bashrc, but `home-manager switch` will fail to pull from the
private flake inputs. But I hope the following workaround will work:

1. Build and install npiperelay.exe manually as described above.
2. Comment out the use of private flake inputs in this repository.
3. Run home-manager switch to get things set up correctly for the 1Password ssh
   agent.
4. Uncomment and switch again.
