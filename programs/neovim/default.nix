{
  pkgs,
  ...
}:

{
  programs.neovim =
    let
      plugins =
        with pkgs.vimPlugins; [
          barbar-nvim
          catppuccin-nvim
          fzf-vim
          gruvbox
          markdown-preview-nvim
          nvim-web-devicons
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

        ${builtins.readFile ./markdown-preview.vim}
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
}
