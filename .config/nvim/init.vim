if filereadable( $HOME . "/.vimrc" )
  source ~/.vimrc
endif

""" vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source ~/.config/nvim/init.vim
endif

call plug#begin('~/.local/share/nvim')
  Plug 'neoclide/coc.nvim', {'branch': 'release'} "node required
call plug#end()