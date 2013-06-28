"dependent {{{
if filereadable( $HOME . "/.vimrc.dependent" )
      source ~/.vimrc.dependent
endif
" }}}

" Search {{{
set incsearch "インクリメンタルサーチを行う
set smartcase "検索時に大文字を含んでいたら大/小を区別
set wrapscan  "最後まで検索後最初に戻る
set hlsearch  "ハイライト
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return>
" }}}

" Configurations {{{
set hidden "変更中のファイルでも、保存しないで他のファイルを表示
" }}}

" Visualization {{{
set ambiwidth=double
set list "タブ文字、行末など不可視文字を表示する
set listchars=eol:$,tab:>\ ,extends:< "listで表示される文字のフォーマットを指定する
" }}}

" UI {{{
:syntax on "シンタックスハイライト有効
set number "行番号を表示する
hi Comment ctermfg=yellow "dddd
set showmatch "閉じ括弧が入力されたとき、対応する括弧を表示する
set wildmenu  "コマンドライン補完の強化

"全角スペースを視覚化
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=#666666
au BufNewFile,BufRead * match ZenkakuSpace /　/

"入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END

"ターミナルでマウスを使用できるようにする
set mouse=a
set guioptions+=a
set ttymouse=xterm2
" }}}

" Backup & Swap {{{
set swapfile
set directory=~/.vim/swp "スワップファイル用のディレクトリ
set backupdir=~/.vim/swp "バックアップファイルを作るディレクトリ
set browsedir=buffer "ファイル保存ダイアログの初期ディレクトリをバッファファイル位置に設定
" }}}

" indent {{{
set autoindent "新しい行のインデントを現在行と同じにする
set smarttab "行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする。
set shiftwidth=4 "シフト移動幅
set smartindent "新しい行を作ったときに高度な自動インデントを行う
set expandtab "タブの代わりに空白文字を挿入する
set backspace=2 "deleteキー削除
" }}}


"===============================
"vimプラグイン管理 for neobundle
"
set nocompatible "Vi互換をオフ

if has('vim_starting')
  set runtimepath+=~/.vim/neobundle.vim/
  filetype off
  call neobundle#rc(expand('~/.vim/bundle'))
  filetype plugin on
  filetype indent on
endif

" 使いたいプラグインのリポジトリを羅列。Subversion とか Mercurial でもいけるらしい。
NeoBundle 'Shougo/neocomplcache.vim'
NeoBundle 'Shougo/neobundle.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/unite.vim'
"NeoBundle 'mattn/zencoding-vim'
"NeoBundle 'thinca/vim-quickrun'
NeoBundle 'thinca/vim-ref'
"
""Brief help
":NeoBundleList          
""- list configured bundles
":NeoBundleInstall!    
"- install(update) bundles
":NeoBundleClean(!)      "- confirm(or auto-approve) removal of unused
""bundles
""Installation check.
"===============================

" neocomplcache
let g:neocomplcache_enable_at_startup = 1 " 起動時に有効化
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_smart_case = 1
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_manual_completion_start_length = 0
let g:neocomplcache_caching_percent_in_statusline = 1
let g:neocomplcache_enable_skip_completion = 1
let g:neocomplcache_skip_input_time = '0.5'
let g:NeoComplCache_DictionaryFileTypeLists = {
    \ 'default' : '',
    \ 'php' : '~/.vim/dict/php.dict' 
    \}

" 自動保管の色
hi Pmenu guibg=#f5f5dc guifg=#000000
hi PmenuSel guibg=#0000ff guifg=#ffffff
hi PmenuSbar guibg=#aaaaaa
hi PmenuThumb guifg=#0000ff

"syntastic
let g:syntastic_check_on_open = 1
let g:syntastic_enable_signs = 1
let g:syntastic_echo_current_error = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_enable_highlighting = 1
" php コマンドのオプションを上書かないと動かなかった
let g:syntastic_php_php_args = '-l'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"vim-ref
let g:ref_phpmanual_path = $HOME."/.vim/refs/php-chunked-xhtml"

" unite.vim {{{ 
"" 入力モードで開始する
let g:unite_enable_start_insert=0
"バッファ一覧
noremap <C-Q><C-B> :Unite buffer<CR>
" ファイル一覧
noremap <C-Q><C-F> :UniteWithBufferDir -buffer-name=files file<CR>
" 最近使ったファイルの一覧
noremap <C-Q><C-R> :Unite file_mru<CR>
" レジスタ一覧
noremap <C-Q><C-Y> :Unite -buffer-name=register register<CR>
" ファイルとバッファ
noremap <C-Q><C-U> :Unite buffer file_mru<CR>
" 全部
noremap <C-Q><C-A> :Unite UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
" Unite-grep
nnoremap <silent> ,ug :Unite grep:%:-iHRn<CR>
" }}}
" reference
"http://subtech.g.hatena.ne.jp/cho45/20061010/1160459376
" http://vim.wikia.com/wiki/Mac_OS_X_clipboard_sharing
"
" need 'set enc=utf-8' and
" below shell environment variable for UTF-8 characters
" export __CF_USER_TEXT_ENCODING='0x1F5:0x08000100:14'
"
" Vim(Mac)
if has('mac') && !has('gui')
    nnoremap <silent> <Space>y :.w !pbcopy<CR><CR>
    vnoremap <silent> <Space>y :w !pbcopy<CR><CR>
    nnoremap <silent> <Space>p :r !pbpaste<CR>
    vnoremap <silent> <Space>p :r !pbpaste<CR>
" GVim(Mac & Win)
else
    noremap <Space>y "+y
    noremap <Space>p "+p
endif
