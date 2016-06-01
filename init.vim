""""""""""""""""""""""""""""""""""""""""
" Plug initialization
""""""""""""""""""""""""""""""""""""""""

if has("win32")
    call plug#begin('~\AppData\Local\nvim\.vim\plugged')
else
    call plug#begin('~/.config/nvim/.vim/plugged')
endif

Plug 'morhetz/gruvbox'

"Plug 'klen/python-mode'
"Plug 'Valloric/YouCompleteMe'
"Plug 'davidhalter/jedi-vim'
"Plug 'scrooloose/nerdtree'
"Plug 'Yggdroot/indentLine'
"Plug 'mjbrownie/vim-htmldjango_omnicomplete'
"Plug 'lambdalisue/vim-django-support'
"Plug 'shougo/neocomplete.vim'

Plug 'python-rope/ropevim'
Plug 'hynek/vim-python-pep8-indent'
Plug 'hdima/python-syntax'

Plug 'hail2u/vim-css3-syntax'
Plug 'othree/html5.vim'

if has('unix')
    Plug 'Shougo/deoplete.nvim'
    Plug 'carlitux/deoplete-ternjs'
    Plug 'zchee/deoplete-jedi'
    Plug 'Shougo/neco-vim'
    Plug 'Shougo/neco-syntax'
endif

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'scrooloose/syntastic'
Plug 'vim-utils/vim-husk'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'raimondi/delimitmate'
Plug 'tpope/vim-surround'
Plug 'moll/vim-bbye'
Plug 'majutsushi/tagbar'

call plug#end()

runtime macros/matchit.vim
"runtime macros/editexisting.vim

""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
""""""""""""""""""""""""""""""""""""""""

function! GetFileDirectory ()
    " get directory of opened file for statusline
    let fileDirectory = expand("%:p:h")
    return fileDirectory
endfunction

func! DeleteTrailingWS()
    " delete trailing spaces on save
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc

""""""""""""""""""""""""""""""""""""""""
" Vim settings
""""""""""""""""""""""""""""""""""""""""

" no lag in terminal vim
set ttimeoutlen=0

" backups, etc..
set undofile
set backup
if has("win32")
	set undodir=~\AppData\Local\nvim\.vim\misc
	set backupdir=~\AppData\Local\nvim\.vim\misc
	set directory=~\AppData\Local\nvim\.vim\misc
else
	set undodir=~/.vim/misc
	set backupdir=~/.vim/misc
	set directory=~/.vim/misc
endif

" tabs/spaces, indentation
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4
set expandtab       " tabs are spaces
set smarttab            " Be smart when using tabs ;)
set autoindent
set cindent

" statusline
set statusline=%t\ %<%m%H%W%q%=%{GetFileDirectory()}\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set laststatus=2        " always show status bar

" search, highlighting
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

" folding
set foldcolumn=1        " Add a bit extra margin to the left

set scrolloff=999
set autoread            " autoreload buffer if changes
set lazyredraw          " redraw only when we need to.
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
"set ffs=unix,dos,mac
set showfulltag
set hidden              " buffers don't close
set nocompatible        " nocompatible with vi
set colorcolumn=80
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h
set shiftround
set sessionoptions-=blank

filetype plugin indent on

set omnifunc=syntaxcomplete#Complete

setlocal shortmess+=I   " hide intro message on start
" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

autocmd FileType * syntax on
autocmd FileType * setlocal formatoptions-=t
autocmd FileType * setlocal formatoptions-=o
autocmd FileType * setlocal formatoptions-=r
" maximum history items
autocmd FileType * setlocal history=300
autocmd BufWrite * call DeleteTrailingWS()

""""""""""""""""""""""""""""""""""""""""
" MAPPINGS (keys, bindings)
""""""""""""""""""""""""""""""""""""""""

" :W save the file as root
if has("unix")
    command W w !sudo tee % > /dev/null
endif

" don't close window if :bd
nmap <leader>bd :bp<CR>:bd#<CR>

" leave ins mode in :term easier
tnoremap <C-[> <C-\><C-n>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DEPEND ON $TERM SETTINGS (graphical, gui, gvim, terminal, console, tty)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
    colorscheme gruvbox
    set background=dark
    set guifont=Hack\ 10
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guioptions+=a  "highlighted text automatically copies to "* register
    set guioptions+=c  "no graphical popup dialogs
else
    if $KONSOLE_PROFILE_NAME != '' || $COLORTERM == 'gnome-terminal' ||
                \ $TERM == 'screen' || $TERM == 'screen-256color' ||
                \ $TERM == 'xterm-256color' || $OS == 'Windows_NT'
        try
            colorscheme gruvbox
        catch
        endtry

        set background=dark
    else
        colorscheme desert
        set background=dark
    endif
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PYTHON-SPECIFIC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let python_highlight_all = 1
autocmd Filetype python setlocal foldmethod=syntax
autocmd Filetype python setlocal foldlevel=1
autocmd Filetype python setlocal foldminlines=15
autocmd Filetype python setlocal foldnestmax=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" python-mode
"let g:pymode_lint_cwindow = 0
"let g:pymode_rope_completion = 0
"let g:pymode_folding = 0

" jedi-vim
"let g:jedi#popup_on_doeed_identifiers_with_syntax = 1

" youcompleteme
""let g:ycm_seed_identifiers_with_syntax = 1
""let g:ycm_server_keep_logfiles = 1
"let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_key_list_select_completion = ['<Down>', 'CTRL-N']
"let g:ycm_key_list_previous_completion = ['<Up>', 'CTRL-P']
"nmap <leader>d :YcmCompleter GoToDeclaration<CR>
"nmap <leader>D :YcmCompleter GoToDefinition<CR>
"nmap <leader>* :YcmCompleter GoToReferences<CR>
"nmap <leader>k :YcmCompleter GetDoc<CR>

" ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" syntastic
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"let g:syntastic_error_symbol = 'E'
"let g:syntastic_warning_symbol = 'W'
"let g:syntastic_style_error_symbol = 'e'
"let g:syntastic_style_warning_symbol = 'w'
"let g:syntastic_python_python_use_codec = 1
let g:syntastic_aggregate_errors = 1
let g:syntastic_python_checkers = ["python", "pyflakes", "pep8"]

" ropevim
"let ropevim_extended_complete = 1
"let g:ropevim_autoimport_modules = ["os.*", "sys"]

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
"let g:deoplete#auto_complete_start_length = 1
"let g:deoplete#omni#input_patterns = {}
"let g:deoplete#omni#input_patterns.python = '([^. \t]\.|^\s*@|^\s*from\s.+ import |^\s*from |^\s*import )\w*'
let g:deoplete#sources#jedi#show_docstring = 1
let g:deoplete#sources#jedi#enable_cache = 1
autocmd CompleteDone * pclose!

" tagbar
let g:tagbar_compact = 1
autocmd FileType * nested :call tagbar#autoopen(0)

" nerdtree
"let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
"let NERDTreeMinimalUI=1
"autocmd VimEnter * NERDTree

" indentline
" let g:indentLine_loaded = 1

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" delimitmate
let delimitMate_matchpairs = "(:),[:],{:},<:>"
let delimitMate_nesting_quotes = ['"','`',"'"]
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_expand_inside_quotes = 1
let delimitMate_jump_expansion = 1
let delimitMate_balance_matchpairs = 1
"au FileType c,perl let b:delimitMate_insert_eol_marker = 2

" htmldjango_omnicomplete
"au FileType htmldjango set omnifunc=htmldjangocomplete#CompleteDjango
"let g:htmldjangocomplete_html_flavour = 'html5'

" neocomplete
" let g:neocomplete#enable_at_startup = 1
" let g:neocomplete#enable_smart_case = 1
" let g:neocomplete#enable_auto_close_preview = 1
" let g:neocomplete#fallback_mappings =
" \ ["\<C-x>\<C-o>", "\<C-x>\<C-n>"]
" "let g:neocomplete#skip_auto_completion_time

"autocmd FileType python setlocal omnifunc=jedi#completions
"let g:jedi#completions_enabled = 0
"let g:jedi#auto_vim_configuration = 0
"let g:jedi#smart_auto_mappings = 0
"let g:neocomplete#force_omni_input_patterns.python =
"\ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
"" alternative pattern: '\h\w*\|[^. \t]\.\w*'
