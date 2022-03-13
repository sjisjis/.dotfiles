set binary noeol
set noswapfile
if has('nvim')
  set clipboard+=unnamedplus
else
  set clipboard=unnamed,autoselect
endif
set mouse=a "ターミナルでマウスを使用できるようにする

""" Search
set incsearch "インクリメンタルサーチを行う
set smartcase "検索時に大文字を含んでいたら大/小を区別
set wrapscan  "最後まで検索後最初に戻る
set hlsearch  "ハイライト
nnoremap <Esc><Esc> :<C-u>set nohlsearch<Return>

""" Configurations
set hidden "変更中のファイルでも、保存しないで他のファイルを表示

""" Visualization
if !exists('g:vscode')
    set ambiwidth=double "TODO:vscodeでエラーとなる
endif
set list "タブ文字、行末など不可視文字を表示する
set listchars=eol:↲,tab:>\ ,extends:< "listで表示される文字のフォーマットを指定する

""" UI
:syntax on "シンタックスハイライト有効
set number "行番号を表示する
hi Comment ctermfg=yellow "dddd
set showmatch "閉じ括弧が入力されたとき、対応する括弧を表示する
set wildmenu  "コマンドライン補完の強化

""" 全角スペースを視覚化
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=#666666
au BufNewFile,BufRead * match ZenkakuSpace /　/

""" 入力モード時、ステータスラインのカラーを変更
augroup InsertHook
autocmd!
autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END

augroup HighlightTrailingSpaces
  autocmd!
  autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
  autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

""" indent
set autoindent "新しい行のインデントを現在行と同じにする
set smarttab "行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする。
set shiftwidth=4 "シフト移動幅
set smartindent "新しい行を作ったときに高度な自動インデントを行う
set expandtab "タブの代わりに空白文字を挿入する
set backspace=2 "deleteキー削除

""" sudo忘れ
cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>

""" 自動保管の色
hi Pmenu guibg=#f5f5dc guifg=#000000
hi PmenuSel guibg=#0000ff guifg=#ffffff
hi PmenuSbar guibg=#aaaaaa
hi PmenuThumb guifg=#0000ff

""" Vim(Mac)
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