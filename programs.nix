{
  config,
  pkgs,
  homeDirectory,
  isWSL,
  agent-bridge,
  ...
}:

{
  imports = [
    ./alacritty.nix
  ];

  programs = {

    bash =
      let
        agent-bridge =
          pkgs.writeShellApplication {
            name          = "agent-bridge";
            text          = builtins.readFile ./agent-bridge.sh;
            runtimeInputs = [
              pkgs.socat
              pkgs.toybox # for pgrep and setsid
            ];
          };

      in {
        enable = true;
        initExtra = ''
          function ll() { eza -algF --group-directories-first "$@"; }
          function tree() { eza -T "$@"; }

        '' + (pkgs.lib.optionalString isWSL ''
          "${agent-bridge}/bin/agent-bridge"
        '');

        shellAliases = {
          dirs = "dirs -v";
        };

        # don't put duplicate lines or lines starting with space in the history
        historyControl = [ "ignoredups" "ignorespace" ];

        sessionVariables =
          let
            display = { DISPLAY = ":0"; };
            ssh_auth_sock =
              if pkgs.stdenv.isDarwin
              then { SSH_AUTH_SOCK = homeDirectory + "/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"; }
              else if isWSL
              then { SSH_AUTH_SOCK = homeDirectory + "/.1password/agent.sock"; }
              else {};

            # Bash completions weren't working for individual applications in
            # macOS, and this fixes it. Possibly this should also apply to WSL,
            # but I wasn't running into issues.
            xdg_data_dirs =
              pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
                XDG_DATA_DIRS = homeDirectory + "/.nix-profile/share";
              };
          in
            display // ssh_auth_sock // xdg_data_dirs;
      };

    fzf = 
      let defaultCommand = ''
        ${pkgs.ripgrep}/bin/rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null
      '';

      in {
        enable = true;

        # export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
        inherit defaultCommand;

        # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        fileWidgetCommand = defaultCommand;
      };

    ssh =
      if pkgs.stdenv.isDarwin then
        {
          enable = true;
          matchBlocks.any-host = {
            host = "*";
            extraOptions.IdentityAgent =
              homeDirectory + "/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
          };
        }
      else {};

    starship = {
      enable = true;
      settings = {
        battery.disabled = true;
        python = {
          python_binary = [ "${pkgs.python3}/bin/python3" ];
        };
      };
    };

    tmux =
      # I believe I originally did this so that I could reroute specific
      # C-PageUp/C-PageDown via Karabiner
      let
        isDarwin       = pkgs.stdenv.isDarwin;
        prevWinBinding = if isDarwin then "M-1" else "C-PageUp";
        nextWinBinding = if isDarwin then "M-2" else "C-PageDown";

        # https://github.com/microsoft/WSL/issues/5931
        escapeTime     = if isWSL then 1 else 0;

      in {
        enable = true;

        sensibleOnTop = false;

        # ported from my .tmux.conf:
        extraConfig = ''
          bind -n M-h select-pane -L
          bind -n M-l select-pane -R
          bind -n M-k select-pane -U
          bind -n M-j select-pane -D
          bind -n ${prevWinBinding} previous-window
          bind -n ${nextWinBinding} next-window

          set-option -g allow-rename off
          
          # tmux starts a login shell by default; this overrides that
          set-option -g default-command "$SHELL"

          # No delay after pressing escape in VIM
          set -sg escape-time ${builtins.toString escapeTime}
        '';

        terminal = "screen-256color"; # set -g default-terminal "screen-256color"

        inherit escapeTime;
      };

    neovim =
      let
        plugins =
          with pkgs.vimPlugins; [
            barbar-nvim
            fzf-vim
            gruvbox
            nvim-web-devicons
            #tokyonight-nvim
            catppuccin-nvim
            vim-nix
            vim-smoothie
          ];

        rgFileExts = [
          "c"
          "cc"
          "cmake"
          "conf"
          "config"
          "cpp"
          "css"
          "fbp"
          "gitignore"
          "go"
          "h"
          "hh"
          "hpp"
          "hs"
          "html"
          "jade"
          "js"
          "json"
          "jsonnet"
          "lock"
          "lua"
          "md"
          "nix"
          "php"
          "py"
          "rb"
          "scss"
          "styl"
          "toml"
          "txt"
          "yaml"
          "yml"
        ];

        extraConfig = ''
          set ignorecase
          set infercase
          set hidden
          set number
          set nowrap
          set autoindent expandtab tabstop=2 shiftwidth=2
          set statusline+=%F\ %c
          set backspace=indent,eol,start
          nnoremap <C-N> :bnext<CR>
          nnoremap <C-P> :bprev<CR>

          set background=dark
          if $TERM_PROGRAM ==# "Apple_Terminal"
            colorscheme gruvbox
          else
            set termguicolors
            colorscheme catppuccin-mocha
          endif

          augroup vimrc_autocmds
            autocmd BufEnter * highlight OverLength ctermbg=189 ctermfg=235 guifg=#ffffff guibg=#db4b4b
            autocmd BufEnter * match OverLength /\%>80v.\+/
          augroup END

          " change working directory to directory of the file being edited
          nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

          nmap <silent> <C-t> :FZF<CR>
          nmap <silent> <C-b> :Buffers<CR>
          nmap <silent> <C-l> :Lines<CR>
          nmap <silent> <C-k> :BLines<CR>
          nmap <silent> <C-j> :Lines <C-r><C-w><CR>
          nmap <silent> <leader>j :F <C-r><C-w><CR>

          let g:rg_command = '
            \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
            \ -g "*.{${pkgs.lib.strings.concatStringsSep "," rgFileExts}}"
            \ -g "!{.git,node_modules,vendor}/*" '

          command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
        '';

        extraLuaPackages =
          luaPkgs: with luaPkgs; [
          ];

        extraLuaConfig = ''
        '';

        extraPackages = [
          pkgs.fzf
          pkgs.ripgrep
        ];

      in {
        enable        = true;
        defaultEditor = true;
        vimAlias      = true;
        inherit extraConfig;
        inherit extraLuaConfig;
        inherit extraLuaPackages;
        inherit extraPackages;
        inherit plugins;
      };
  };
}
