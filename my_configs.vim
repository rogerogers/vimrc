set nu
call plug#begin('~/.vim/plugged')
Plug 'ycm-core/YouCompleteMe'
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
call plug#end()

let g:ale_fixers = {
\   'javascript': ['prettier','eslint'],
\   'javascriptreact': ['prettier','eslint'],
\   'python': ['black', 'isort'],
\   'java': ['google_java_format'],
\   'yaml': ['prettier'],
\   'json': ['prettier'],
\   'html': ['html-beautify'],
\   'htmldjango': ['html-beautify'],
\   'rust': ['rustfmt'],
\}
let g:ale_linters = {
    \ 'python': ['pylint'],
            \}
let g:ycm_filetype_whitelist = {
            \'javascript': 1,
            \'java': 1,
            \'python': 1,
            \'rust': 1,
            \}
let g:html_beautify_optiona = '--editorconfig'
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>cl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>rf :YcmCompleter GoToReferences<CR>
let g:NERDTreeWinPos = "left"

let g:ale_fix_on_save = 1
set laststatus=2  " always display the status line
set completeopt=noinsert,menuone
