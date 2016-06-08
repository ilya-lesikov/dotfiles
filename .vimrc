""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
""""""""""""""""""""""""""""""""""""""""

function! GetFileDirectory ()
    " get directory of opened file for statusline
    let fileDirectory = expand('%:p:h')
    return fileDirectory
endfunction

function! DeleteTrailingWS()
    " delete trailing spaces on save
    execute 'normal mz'
    %s/\s\+$//ge
    execute 'normal `z'
endfunction
autocmd BufWrite * call DeleteTrailingWS()

function! s:Unavail(name)
    let g:unavail#msg = a:name . ' not available.'
    " WORKAROUND for gvim popping up dialog box
    autocmd VimEnter * echomsg g:unavail#msg
endfunction

function! s:IsTerm256Colors()
    if $KONSOLE_PROFILE_NAME !=? '' || $COLORTERM ==? 'gnome-terminal' ||
                    \ $TERM ==? 'screen' || $TERM ==? 'screen-256color' ||
                    \ $TERM ==? 'xterm-256color'
        return 1
    endif
endfunction

function! s:SetColorScheme(colorscheme, ...)
    " second optional arg: background (default = dark)
    execute 'colorscheme ' . a:colorscheme

    if exists('a:1')
        let &background = a:1
    else
        set background=dark
    endif
endfunction

function! s:IsFeatAvail(feature, msg)
    if has(a:feature)
        return 1
    endif

    call s:Unavail(a:msg)
endfunction

""""""""""""""""""""""""""""""""""""""""
" VARS
""""""""""""""""""""""""""""""""""""""""

if has('win32')
    let g:path#vimfiles = expand('~/vimfiles')
    let g:path#vimrc = expand('~/_vimrc')
else
    let g:path#vimfiles = expand('~/.vim')
    let g:path#vimrc = expand('~/.vimrc')
endif

let &rtp .= ','.expand(g:path#vimfiles)
let g:path#plug = expand(g:path#vimfiles . '/autoload/plug.vim')
let g:path#plugged = expand(g:path#vimfiles . '/plugged')

""""""""""""""""""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""""""""""""""""""

" skip if plugin manager not available
if filereadable(g:path#plug)
    call plug#begin(g:path#plugged)

    " colorschemes
    Plug 'morhetz/gruvbox'

    " general completion
    if s:IsFeatAvail('lua', 'Neocomplete')
        Plug 'shougo/neocomplete.vim'
        " depends
        Plug 'Shougo/vimproc.vim' " not required
        " misc
		Plug 'Shougo/neco-vim' " vimscript
    endif

    " powershell
    if has('win32')
        " completion
        let g:path#poshcomplete = expand(g:path#plugged . '/poshcomplete-vim')
        Plug g:path#poshcomplete
        " depends
        Plug 'Shougo/vimproc.vim'
        Plug 'mattn/webapi-vim'
        " misc
        Plug 'PProvost/vim-ps1'
    endif

    " python
    if s:IsFeatAvail('python', 'Python and python plugins')
        " rope
        Plug 'python-rope/ropevim'
        " jedi
        Plug 'davidhalter/jedi-vim'
        " misc
        Plug 'hdima/python-syntax'
        Plug 'hynek/vim-python-pep8-indent'
    endif

    " snippets
    if s:IsFeatAvail('python', 'Ultisnips')
        " ultisnips
        Plug 'SirVer/ultisnips'
        " depends
        Plug 'honza/vim-snippets'
    endif

    " syntastic
    Plug 'scrooloose/syntastic'
    " css misc
    Plug 'hail2u/vim-css3-syntax'
    " html omnicomplete, misc
    Plug 'othree/html5.vim'
    " readline bindings for cmd mode
    Plug 'vim-utils/vim-husk'
    " colorize indent levels
    Plug 'nathanaelkane/vim-indent-guides'
    " autoclose braces, quotes..
    Plug 'raimondi/delimitmate'
    " fast changing of braces, quotes..
    Plug 'tpope/vim-surround'
    " :Bd don't close split
    Plug 'moll/vim-bbye'
    " tagbar
    Plug 'majutsushi/tagbar'
    " django completion
    "Plug 'mjbrownie/vim-htmldjango_omnicomplete'
    "Plug 'lambdalisue/vim-django-support'

    " jumping with % for xml tags
    runtime macros/matchit.vim

    call plug#end()
else
    call s:Unavail('Plugin manager')
endif

""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
""""""""""""""""""""""""""""""""""""""""

" poshcomplete
if !exists('g:PoshComplete_Port')
    let g:PoshComplete_Port = '1234'
endif
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.ps1 =
    \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'

" neocomplete
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#enable_auto_close_preview = 1
let g:neocomplete#fallback_mappings =
    \ ["\<C-x>\<C-o>", "\<C-x>\<C-n>"]
"let g:neocomplete#skip_auto_completion_time = ''

" jedi
autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
" WORKAROUND to prevent error when appending to list
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.python =
    \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'

" ultisnips
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
let g:UltiSnipsJumpBackwardTrigger='<c-z>'

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
let g:syntastic_python_checkers = ['python', 'pyflakes', 'pep8']
let g:syntastic_vim_checkers = ['vint']
let g:syntastic_sh_checkers = ['sh', 'shellcheck']
let g:syntastic_javascript_checkers = ['eslint']

" indent_guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" delimitmate
let delimitMate_matchpairs = '(:),[:],{:},<:>'
let delimitMate_nesting_quotes = ['"','`',"'"]
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_expand_inside_quotes = 1
let delimitMate_jump_expansion = 1
let delimitMate_balance_matchpairs = 1
"au FileType c,perl let b:delimitMate_insert_eol_marker = 2

" tagbar
let g:tagbar_compact = 1
autocmd FileType python nested :call tagbar#autoopen(0)

""""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" FIX lag in terminal vim
set ttimeoutlen=0

" backup, swap, undo
set undofile
set backup
let &undodir = expand(g:path#vimfiles . '/misc')
let &backupdir = expand(g:path#vimfiles . '/misc')
let &directory = expand(g:path#vimfiles . '/misc')

" tabs, indent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set cindent

" statusline
set statusline=%t\ %<%m%H%W%q%=%{GetFileDirectory()}\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set laststatus=2        " always show status bar

" highlight
set showmatch           " highlight matching [{()}]
set hlsearch
set cursorline
set colorcolumn=80

" folds
set foldcolumn=1        " Add a bit extra margin to the left

" misc
set nomagic
set incsearch
set scrolloff=999
set autoread            " autoreload buffer if changes
set lazyredraw          " redraw only when we need to.
set showcmd             " show command in bottom bar
set wildmenu            " visual autocomplete for command menu
set showfulltag
set hidden
set nocompatible
set confirm
set langmenu=none       " english for all prompts
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h
set sessionoptions-=blank
set shiftround          " round indentation
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
setlocal shortmess+=I   " hide intro message on start

" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

" gui
if has('gui_running')
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guioptions+=a  "highlighted text automatically copies to "* register
    set guioptions+=c  "no graphical popup dialogs

    if has('win32')
        " WORKAROUND for maximizing gvim on Windows
        set lines=999
        set columns=999
    endif
endif

autocmd FileType * syntax on

autocmd FileType * setlocal history=300

autocmd FileType * setlocal formatoptions-=t
autocmd FileType * setlocal formatoptions-=o
autocmd FileType * setlocal formatoptions-=r

" python
if s:IsFeatAvail('python', 'Python configuration')
    let python_highlight_all = 1
    autocmd Filetype python setlocal foldmethod=indent
    autocmd Filetype python setlocal foldlevel=1
    autocmd Filetype python setlocal foldminlines=15
    autocmd Filetype python setlocal foldnestmax=2
endif

" restore cursor position on file open
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" | endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLORSCHEME, FONTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('gui_running')

    try
        call s:SetColorScheme('gruvbox')
    catch
        call s:SetColorScheme('desert')
    endtry

    if has('win32')
        set guifont=Courier_New:h10:cRUSSIAN:qDRAFT
    else

        try
            set guifont=Hack\ 10
        catch
            call s:Unavail('Guifont')
            set guifont=DejaVu\ Sans\ Mono\ 10
        endtry

    endif

else

    if has('win32')
        call s:SetColorScheme('industry')
    elseif s:IsTerm256Colors()
        try
            call s:SetColorScheme('gruvbox')
        catch
            call s:SetColorScheme('desert')
        endtry
    else
        call s:SetColorScheme('desert')
    endif

endif

""""""""""""""""""""""""""""""""""""""""
" MAPPINGS, COMMANDS
""""""""""""""""""""""""""""""""""""""""

" :W save the file as root
if has('unix')
    command W w !sudo tee % > /dev/null
endif

" edit vimrc
command Ev execute 'edit ' . g:path#vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TRASH
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
""nmap <leader>d :YcmCompleter GoToDeclaration<CR>
""nmap <leader>D :YcmCompleter GoToDefinition<CR>
""nmap <leader>* :YcmCompleter GoToReferences<CR>
""nmap <leader>k :YcmCompleter GetDoc<CR>

" ropevim
"let ropevim_extended_complete = 1
"let g:ropevim_autoimport_modules = ['os.*', 'sys']

" deoplete
"let g:deoplete#enable_at_startup = 1
"let g:deoplete#enable_smart_case = 1
""let g:deoplete#auto_complete_start_length = 1
""let g:deoplete#omni#input_patterns = {}
""let g:deoplete#omni#input_patterns.python = '([^. \t]\.|^\s*@|^\s*from\s.+ import |^\s*from |^\s*import )\w*'
"let g:deoplete#sources#jedi#show_docstring = 1
"let g:deoplete#sources#jedi#enable_cache = 1
"autocmd CompleteDone * pclose!

" nerdtree
"let NERDTreeIgnore=['\.pyc$', '\.vim$', '\~$']
"let NERDTreeMinimalUI=1
"autocmd VimEnter * NERDTree

" indentline
" let g:indentLine_loaded = 1

" htmldjango_omnicomplete
"au FileType htmldjango set omnifunc=htmldjangocomplete#CompleteDjango
"let g:htmldjangocomplete_html_flavour = 'html5'

"Plug 'klen/python-mode'
"Plug 'Valloric/YouCompleteMe'
"Plug 'scrooloose/nerdtree'
"Plug 'Yggdroot/indentLine'
"Plug 's3rvac/AutoFenc'

"if has('unix')
"    Plug 'Shougo/deoplete.nvim'
"    Plug 'carlitux/deoplete-ternjs'
"    Plug 'zchee/deoplete-jedi'
"    Plug 'Shougo/neco-vim'
"    Plug 'Shougo/neco-syntax'
"endif

"if has('win32')
"    set shell=powershell
"    set shellcmdflag=-command
"endif

"if has('win32')
"    set encoding=cp866
"endif

" don't close window if :bd
"nmap <leader>bd :bp<CR>:bd#<CR>


"if has('win32')
"    set rtp+=~\vimfiles\autoload
"endif
