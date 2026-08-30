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
  let s:plugged_dir = expand('~/.local/share/nvim/plugged')
else
  let s:plug_path = expand('~/.vim/autoload/plug.vim')
  let s:plugged_dir = expand('~/.vim/plugged')
endif

if empty(glob(s:plug_path))
  silent execute '!curl -fLo ' . s:plug_path . ' --create-dirs --proto "=https" --tlsv1.2 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(s:plugged_dir)

" Fast Search & Discovery (ripgrep & fd powered)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" File Navigation: nvim-tree + oil.nvim (Neovim) / fern.vim (Vim)
if has('nvim')
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'stevearc/oil.nvim'
else
  Plug 'lambdalisue/fern.vim'
endif

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
  if has('nvim')
    let s:undodir = expand('~/.local/share/nvim/undo')
  else
    let s:undodir = expand('~/.vim/temp_dirs/undodir')
  endif
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
nnoremap <BS> <C-W>h

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
" => 7. File Navigation: nvim-tree & Oil.nvim (Neovim) / fern.vim (Vim)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('nvim')
lua << LUA_EOF
-- nvim-tree on_attach to preserve window navigation keys and mouse interaction
local function tree_on_attach(bufnr)
  local api = require('nvim-tree.api')
  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
  pcall(vim.keymap.del, 'n', '<C-k>', { buffer = bufnr })

  -- Window navigation
  vim.keymap.set('n', '<C-h>', '<C-w>h', opts('Window Left'))
  vim.keymap.set('n', '<C-j>', '<C-w>j', opts('Window Down'))
  vim.keymap.set('n', '<C-k>', '<C-w>k', opts('Window Up'))
  vim.keymap.set('n', '<C-l>', '<C-w>l', opts('Window Right'))

  -- Mouse click & double click interaction
  vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open / Expand'))
  vim.keymap.set('n', '<LeftRelease>', api.node.open.edit, opts('Open / Expand'))
end

-- nvim-tree.lua setup (Modern async file explorer with git badges & devicons)
local ok_tree, nvim_tree = pcall(require, "nvim-tree")
if ok_tree then
  nvim_tree.setup({
    on_attach = tree_on_attach,
    disable_netrw = false,
    hijack_netrw = false,
    view = {
      width = 32,
      side = "left",
    },
    renderer = {
      group_empty = true,
      highlight_git = true,
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = { "^\\.git$", "^node_modules$", "^\\.pyc$", "^__pycache__$" },
    },
    git = {
      enable = true,
      ignore = false,
    },
  })
end

-- oil.nvim setup (Edit filesystem like a normal text buffer)
local ok_oil, oil = pcall(require, "oil")
if ok_oil then
  oil.setup({
    default_file_explorer = false,
    columns = {
      "icon",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      max_width = 90,
      max_height = 30,
      border = "rounded",
    },
  })
end
LUA_EOF

  " nvim-tree shortcuts
  nnoremap <silent> <leader>nn :NvimTreeToggle<CR>
  nnoremap <silent> <leader>nf :NvimTreeFindFile<CR>

  " oil.nvim shortcuts
  nnoremap <silent> - :Oil<CR>
  nnoremap <silent> <leader>o :Oil<CR>
  nnoremap <silent> <leader>O :Oil --float<CR>
else
  " Modern Async Fern.vim Configuration for standard Vim
  let g:fern#drawer_width = 32
  let g:fern#default_hidden = 1
  let g:fern#scheme#file#show_absolute_path_on_root = 0

  " Toggle Fern drawer sidebar
  nnoremap <silent> <leader>nn :Fern . -drawer -toggle<CR>
  " Locate & reveal current file in Fern drawer
  nnoremap <silent> <leader>nf :Fern . -drawer -reveal=%<CR>

  function! s:init_fern() abort
    nmap <buffer><expr>
          \ <Plug>(fern-my-expand-or-collapse)
          \ fern#smart#leaf(
          \   "<Plug>(fern-action-open)",
          \   "<Plug>(fern-action-expand)",
          \   "<Plug>(fern-action-collapse)",
          \ )
    nmap <buffer> <CR> <Plug>(fern-my-expand-or-collapse)
    nmap <buffer> o <Plug>(fern-action-open:edit)
    nmap <buffer> <C-t> <Plug>(fern-action-open:tabedit)
    nmap <buffer> N <Plug>(fern-action-new-file)
    nmap <buffer> K <Plug>(fern-action-new-dir)
    nmap <buffer> D <Plug>(fern-action-remove)
    nmap <buffer> q <Plug>(fern-action-drawer:close)
    " Preserve window navigation inside Fern
    nmap <buffer> <C-h> <C-w>h
    nmap <buffer> <C-j> <C-w>j
    nmap <buffer> <C-k> <C-w>k
    nmap <buffer> <C-l> <C-w>l
    " Enable mouse click & double-click interaction
    nmap <buffer> <LeftRelease> <Plug>(fern-my-expand-or-collapse)
    nmap <buffer> <2-LeftMouse> <Plug>(fern-my-expand-or-collapse)
  endfunction

  augroup FernCustomGroup
    autocmd!
    autocmd FileType fern call s:init_fern()
    " Auto-close Vim if the only window left is Fern drawer
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && &filetype ==# 'fern' | quit | endif
  augroup END
endif

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
