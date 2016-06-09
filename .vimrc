" 10 = normal version, with plugin manager, but w/o need to manually build
" anything. Depends: windows - powershell; linux - curl.
" 20 = full version, requires mingw/gcc for build. Depends: windows -
" powershell; linux - curl, gcc.
" Change the variable and restart vim
let g:vim#version = 10

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

function! Unavail(name)
    let g:unavail#msg = a:name . ' not available.'
    " WORKAROUND for gvim popping up dialog box
    autocmd VimEnter * echomsg g:unavail#msg
endfunction

function! Msg(msg)
    let g:msg#msg = a:msg
    " WORKAROUND for gvim popping up dialog box
    autocmd VimEnter * echomsg g:msg#msg
endfunction

functio! IsTerm256Colors()
    if $KONSOLE_PROFILE_NAME !=? '' || $COLORTERM ==? 'gnome-terminal' ||
                    \ $TERM ==? 'screen' || $TERM ==? 'screen-256color' ||
                    \ $TERM ==? 'xterm-256color'
        return 1
    endif
endfunction

function! SetColorScheme(colorscheme, ...)
    " second optional arg: background (default = dark)
    execute 'colorscheme ' . a:colorscheme

    if exists('a:1')
        let &background = a:1
    else
        set background=dark
    endif
endfunction

function! IsFeatAvail(feature, msg)
    if has(a:feature)
        return 1
    endif

    call Unavail(a:msg)
endfunction

function! IsPlugManInst()
    if filereadable(g:path#plug_man_exec)
        return 1
    endif

    call Unavail('Plugin manager')
endfunction

function! DownloadFile(url, path)
    if has('win32')
        silent! execute '!powershell -Command "& {(New-Object Net.WebClient).DownloadFile(\"' . a:url . '\", $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(\"' . a:path . '\"))}"'

        if filereadable(a:path)
            return 1
        endif
    else
        silent! execute '!curl -fLo "' . a:path . '" --create-dirs "' . a:url . '"'

        if filereadable(a:path)
            return 1
        endif
    endif
endfunction

function! GetPlugMan()
    if has('win32')
        call EnsureDirExist(g:path#autoload)
        let g:uri#plug_man = 'https://raw.githubusercontent.com/junegunn/
                    \vim-plug/master/plug.vim'
        if DownloadFile(g:uri#plug_man, g:path#plug_man_exec)
            call Msg('Plugin manager installed.')
        else
            call Msg('Plugin manager failed to install.')
        endif
    endif
endfunction

function! EnsureDirExist(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
    endif
endfunction

function! GetVimProcLibs()
    if has('win32')
    else
        silent! execute '!curl -fLo "' . a:path . '" --create-dirs "' . a:url . '"'
        let g:uri#vimproc_dll_32 = system('curl -s https://api.github.com/repos/Shougo/vimproc.vim/releases | grep browser_download_url | sed -n 1p | cut -d '"' -f 4')
        silent! execute '!curl -s '

""""""""""""""""""""""""""""""""""""""""
" VARS
""""""""""""""""""""""""""""""""""""""""

if has('win32')
    let g:path#vim_user_dir = expand('~/vimfiles')
    let g:path#vimrc = expand('~/_vimrc')
else
    let g:path#vim_user_dir = expand('~/.vim')
    let g:path#vimrc = expand('~/.vimrc')
endif

let g:path#autoload = expand(g:path#vim_user_dir . '/autoload')
let g:path#plug_man_exec = expand(g:path#vim_user_dir . '/autoload/plug.vim')
let g:path#plug_man_dir = expand(g:path#vim_user_dir . '/plugged')

let &rtp .= ','.expand(g:path#vim_user_dir)

let &undodir = expand(g:path#vim_user_dir . '/misc')
let &backupdir = expand(g:path#vim_user_dir . '/misc')
let &directory = expand(g:path#vim_user_dir . '/misc')

for dir in [g:path#vim_user_dir, g:path#plug_man_dir, &undodir, &backupdir, &directory]
    call EnsureDirExist(dir)
endfor

""""""""""""""""""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""""""""""""""""""

if !IsPlugManInst()
    call GetPlugMan()
    autocmd VimEnter * PlugInstall
endif

call plug#begin(g:path#plug_man_dir)

" colorschemes
Plug 'morhetz/gruvbox'

" general completion
if IsFeatAvail('lua', 'Neocomplete')
    Plug 'shougo/neocomplete.vim'
    " depends
    if has('win32') || g:vim#version = 20
        Plug 'Shougo/vimproc.vim' " not required
    endif
    " misc
    Plug 'Shougo/neco-vim' " vimscript
endif

" powershell
if has('win32')
    " completion
    let g:path#poshcomplete = expand(g:path#plug_man_dir . '/poshcomplete-vim')
    Plug g:path#poshcomplete
    " depends
    Plug 'Shougo/vimproc.vim'
    Plug 'mattn/webapi-vim'
    " misc
    Plug 'PProvost/vim-ps1'
endif

" python
if IsFeatAvail('python', 'Python and python plugins')
    " rope
    Plug 'python-rope/ropevim'
    " jedi
    Plug 'davidhalter/jedi-vim'
    " misc
    Plug 'hdima/python-syntax'
    Plug 'hynek/vim-python-pep8-indent'
endif

" snippets
if IsFeatAvail('python', 'Ultisnips')
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

" tagbar
let g:tagbar_compact = 1
autocmd FileType python nested :call tagbar#autoopen(0)

""""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""

" language (let it be in the beginning)
set langmenu=none
if has('win32')
    language messages EN
else
    language messages en_US.utf8
endif

" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

filetype plugin indent on

" FIX lag in terminal vim
set ttimeoutlen=0

" backup, swap, undo
set undofile
set backup

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
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h
set sessionoptions-=blank
set shiftround          " round indentation
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
setlocal shortmess+=I   " hide intro message on start

" gui
if has('gui_running')
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
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
if IsFeatAvail('python', 'Python configuration')
    let python_highlight_all = 1
    autocmd Filetype python setlocal foldmethod=indent
    autocmd Filetype python setlocal foldlevel=1
    autocmd Filetype python setlocal foldminlines=15
    autocmd Filetype python setlocal foldnestmax=2
endif

" restore cursor position on file open
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" | endif

" delete trailing spaces
autocmd BufWrite * call DeleteTrailingWS()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLORSCHEME, FONTS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('gui_running')

    try
        call SetColorScheme('gruvbox')
    catch
        call SetColorScheme('desert')
    endtry

    if has('win32')
        set guifont=Courier_New:h10:cRUSSIAN:qDRAFT
    else

        try
            set guifont=Hack\ 10
        catch
            call Unavail('Guifont')
            set guifont=DejaVu\ Sans\ Mono\ 10
        endtry

    endif

else

    if has('win32')
        call SetColorScheme('industry')
    elseif IsTerm256Colors()
        try
            call SetColorScheme('gruvbox')
        catch
            call SetColorScheme('desert')
        endtry
    else
        call SetColorScheme('desert')
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

" ropevim
"let ropevim_extended_complete = 1
"let g:ropevim_autoimport_modules = ['os.*', 'sys']

" htmldjango_omnicomplete
"au FileType htmldjango set omnifunc=htmldjangocomplete#CompleteDjango
"let g:htmldjangocomplete_html_flavour = 'html5'
