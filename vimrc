"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Standalone AI-Era High-Performance Vim & Neovim Configuration
"    Absorbed & modernized from vimrc-fork / amix/vimrc.
"    Features: Sub-ms startup, FZF & Ripgrep, NERDTree, Git review,
"    precision text editing, automated formatting, and Gruvbox UI.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nocompatible
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 1. Plugin Management (vim-plug)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-bootstrap vim-plug if not present (Vim & Neovim path support)
if has('nvim')
  let s:plug_path = expand('~/.local/share/nvim/site/autoload/plug.vim')
else
  let s:plug_path = expand('~/.vim/autoload/plug.vim')
endif

if empty(glob(s:plug_path))
  silent execute '!curl -fLo ' . s:plug_path . ' --create-dirs --proto "=https" --tlsv1.2 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Fast Search & Discovery (ripgrep & fd powered)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" File Tree Explorer (Lazy-loaded on toggle/find for 0ms startup overhead)
Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

" Universal Syntax & Indentation (Lazy-loaded for 100+ languages)
Plug 'sheerun/vim-polyglot'

" Git Integration & Review Workflow
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/git-messenger.vim'

" Precision Text Editing & Text Objects
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'michaeljsmith/vim-indent-object'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'editorconfig/editorconfig-vim'

" Fast Asynchronous Formatting & Linting
Plug 'dense-analysis/ale'

" Aesthetics & Light Statusline
Plug 'itchyny/lightline.vim'
Plug 'morhetz/gruvbox'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 2. General & System Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable

" History & Buffers
set history=1000
set autoread
au FocusGained,BufEnter * silent! checktime
set hidden

" Persistent Undo (Undo survives editor restart)
if has('persistent_undo')
  let s:undodir = expand('~/.vim/temp_dirs/undodir')
  if !isdirectory(s:undodir)
    silent! call mkdir(s:undodir, 'p')
  endif
  let &undodir = s:undodir
  set undofile
endif

" Disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" System Clipboard Integration (Seamless copy/paste with OS & AI tools)
if has('unnamedplus')
  set clipboard^=unnamed,unnamedplus
else
  set clipboard^=unnamed
endif

" Set Leader key to comma (classic amix convention)
let mapleader = ","
let g:mapleader = ","

" Fast saving & quitting
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 3. UI, Fonts & Colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number
set relativenumber
set cursorline
set signcolumn=yes
set mouse=a
set splitright splitbelow
set scrolloff=7
set cmdheight=1
set laststatus=2
set updatetime=250

" Quiet editor: No annoying sounds or flash
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Disable Ctrl+MouseClick triggering tags error
nnoremap <C-LeftMouse> <LeftMouse>
inoremap <C-LeftMouse> <LeftMouse>

" True Color support
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Neovim-specific UI enhancements
if has('nvim')
  set inccommand=split          " Live substitution preview
  tnoremap <Esc> <C-\><C-n>     " Easy exit from terminal mode
endif

" Colorscheme
set background=dark
try
  colorscheme gruvbox
catch
  try
    colorscheme desert
  catch
  endtry
endtry

" Lightline configuration
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['fugitive', 'readonly', 'filename', 'modified'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'], [ 'filetype' ] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())'
      \ },
      \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 4. Text, Indentation & Formatting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set autoindent
set smartindent
set wrap
set linebreak
set textwidth=500

" Search & Matching
set ignorecase smartcase
set hlsearch incsearch
set magic
set showmatch
set mat=2

" Wildmenu command line completion
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.o,*~,*.pyc,*/.git/*,*/node_modules/*,*/vendor/*,*/dist/*,*/target/*

" Clear search highlight with <leader><cr>
nnoremap <silent> <leader><cr> :nohlsearch<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 5. Navigation: Windows, Buffers & Tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Smart window navigation (<C-j>, <C-k>, <C-h>, <C-l>)
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Fast Buffer switching
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> <leader>l :bnext<CR>
nnoremap <silent> <leader>h :bprevious<CR>
nnoremap <silent> <leader>bd :bdelete<CR>
nnoremap <silent> <leader>ba :bufdo bd<CR>

" Tab management
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>to :tabonly<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>tm :tabmove<Space>
nnoremap <leader>t<leader> :tabnext<CR>

" Visual search with * and # (from amix/vimrc)
vnoremap <silent> * :<C-u>call <SID>VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call <SID>VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

function! s:VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if a:direction == 'replace'
    call feedkeys(":%s/" . l:pattern . "/")
  elseif a:direction == 'f'
    execute "normal /" . l:pattern . "^M"
  endif
  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 6. FZF & Ripgrep Fast Discovery (Reading & Search)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
endif

" Modern floating window layout for FZF
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.85 } }

" Allow exiting FZF with a single ESC press
augroup FZFKeybindings
  autocmd!
  autocmd FileType fzf tnoremap <buffer> <nowait> <Esc> <C-c>
augroup END

" Search workspace files
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <C-p> :Files<CR>

" Search text across all workspace files with Ripgrep
nnoremap <silent> <leader>g :Rg<CR>
nnoremap <silent> <leader>rg :Rg<CR>

" Search active buffers & buffer lines
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>bl :BLines<CR>

" Search Git commits history
nnoremap <silent> <leader>gc :Commits<CR>
nnoremap <silent> <leader>gh :BCommits<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 7. NERDTree (File Tree Explorer)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = "left"
let g:NERDTreeShowHidden = 1
let g:NERDTreeWinSize = 30
let g:NERDTreeIgnore = ['\.pyc$', '__pycache__$', '\.git$', 'node_modules$']

" Toggle NERDTree sidebar
nnoremap <silent> <leader>nn :NERDTreeToggle<CR>
" Locate & reveal current file in NERDTree
nnoremap <silent> <leader>nf :NERDTreeFind<CR>
" Open from bookmark
nnoremap <leader>nb :NERDTreeFromBookmark<Space>

" Auto-close Vim if the only window left is NERDTree
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 8. Git Workflow & Review
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git Status & Diff
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

" Interactive Git Blame side panel (press Enter on commit to view diff, gq to close)
nnoremap <leader>gb :Git blame<CR>

" Popup commit message under cursor (via git-messenger)
nnoremap <leader>gm <Plug>(git-messenger)

" GitGutter Toggle
nnoremap <silent> <leader>d :GitGutterToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 9. Asynchronous Code Formatting (ALE)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

" Modern fast formatters
let g:ale_fixers = {
\   'python': ['ruff_format', 'ruff'],
\   'go': ['gofumpt', 'goimports'],
\   'rust': ['rustfmt'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'javascriptreact': ['prettier'],
\   'typescriptreact': ['prettier'],
\   'json': ['prettier'],
\   'yaml': ['prettier'],
\   'html': ['prettier'],
\   'css': ['prettier'],
\   'markdown': ['prettier'],
\   'sh': ['shfmt'],
\   'proto': ['buf-format'],
\   'c': ['clang-format'],
\   'cpp': ['clang-format'],
\   'lua': ['lua-format']
\}

" Manual format shortcut
nnoremap <leader>cf :ALEFix<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 10. Filetype Customizations & Overrides
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup FileTypeCustom
  autocmd!
  autocmd FileType gitcommit setlocal spell | call setpos('.', [0, 1, 1, 0])
  autocmd FileType markdown setlocal wrap linebreak
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType json setlocal ts=2 sts=2 sw=2 expandtab
  autocmd BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl
  autocmd BufRead,BufNewFile *.env* set filetype=sh
augroup END
