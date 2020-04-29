set nu
let g:ycm_auto_trigger = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier','eslint'],
\   'python': ['black'],
\}
let g:ycm_filetype_whitelist = {
            \'python': 1,
            \'javascript': 1
            \}
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>cl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>rf :YcmCompleter GoToReferences<CR>
let g:NERDTreeWinPos = "left"

let g:ale_fix_on_save = 1
set statusline=%<%f\ %h%m%r%{kite#statusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2  " always display the status line
set completeopt=noinsert
