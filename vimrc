function! PackInit() abort
  packadd minpac
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('airblade/vim-gitgutter')
  call minpac#add('airblade/vim-rooter')
  call minpac#add('alvan/vim-closetag')
  call minpac#add('editorconfig/editorconfig-vim')
  call minpac#add('her/central.vim')
  call minpac#add('honza/vim-snippets')
  call minpac#add('jeetsukumaran/vim-filebeagle')
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('junegunn/vim-easy-align')
  call minpac#add('junegunn/vim-slash')
  call minpac#add('markonm/traces.vim')
  call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
  call minpac#add('sheerun/vim-polyglot')
  call minpac#add('styled-components/vim-styled-components')
  call minpac#add('thaerkh/vim-workspace')
  call minpac#add('tomtom/tcomment_vim')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-rhubarb')
  call minpac#add('tpope/vim-sensible')
  call minpac#add('tpope/vim-sleuth')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-unimpaired')

  call minpac#add('vim-scripts/SyntaxAttr.vim')
endfunction

command! PackClean call PackInit() | call minpac#clean()
command! PackUpdate call PackInit() | call minpac#update('', {'do': 'call minpac#status()'})

if empty(glob('~/.vim/pack/minpac/opt/minpac'))
  silent !git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
  execute 'PackUpdate'
endif

colorscheme base16

set confirm
set hlsearch
set ignorecase smartcase
set matchpairs+=<:>
set mouse=a
set noshowcmd
set noshowmode
set rtp+=/usr/local/opt/fzf
set shiftround
set shortmess+=actFTWI
set splitbelow splitright
set updatetime=100

augroup autocommands
  autocmd!
  autocmd BufRead,BufNewFile .{eslint,babel,stylelint,prettier}rc set ft=json
  autocmd SessionLoadPost,VimResized * wincmd =
  autocmd WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd BufWritePre * %s/\s\+$//e
augroup END

" update plugins weekly on launch
if ! filereadable(expand("~/.vim/lastupdate"))
  \ || readfile(glob("~/.vim/lastupdate"))[0] < (localtime() - 604800)
  execute 'PackUpdate'
  silent execute '!echo ' . (localtime()) . ' > ~/.vim/lastupdate'
endif

" misc
map j gj
map k gk
let mapleader=' '
map <leader>d :bdelete<CR>
map <leader>t :tabnew<CR>
map <leader>c :tabclose<CR>
map <leader>ca :call DeleteHiddenBuffers()<CR>
map <leader>s :call SynStack()<CR>
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:filebeagle_show_hidden=1
let g:filebeagle_suppress_keymaps=1
map <silent>- <Plug>FileBeagleOpenCurrentBufferDir

" coc
let g:coc_global_extensions = [
  \ 'coc-css',
  \ 'coc-diagnostic',
  \ 'coc-eslint',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-prettier',
  \ 'coc-snippets',
  \ 'coc-tsserver',
  \ ]
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
imap <silent> <C-l> <Plug>(coc-snippets-expand-jump)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
nmap <silent> gn <Plug>(coc-diagnostic-next)
nmap <silent> <leader>f <Plug>(coc-format)
nmap <silent> <leader>a <Plug>(coc-codeaction)
vmap <silent> <leader>a <Plug>(coc-codeaction-selected)
nmap <silent> <leader>r <Plug>(coc-rename)
nmap <silent> <leader>R <Plug>(coc-refactor)

" fzf
let g:fzf_history_dir = '~/.local/share/fzf-history'
let g:fzf_layout = { 'window': 'enew' }
command! -bang -nargs=* Rg call fzf#vim#grep('rg '.shellescape(<q-args>),
  \ 0, {'options':'--delimiter : --nth 3..'}, <bang>0)
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>i :Rg<cr>
nnoremap <leader>o :Files<cr>

" vim-workspace
let g:workspace_autosave = 0
let g:workspace_persist_undo_history = 0
let g:workspace_session_directory = $HOME . '/.vim/sessions/'
let g:workspace_session_disable_on_args = 1

" delete hidden buffers
function! DeleteHiddenBuffers()
  let tpbl=[]
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    silent execute 'bwipeout' buf
  endfor
endfunction
