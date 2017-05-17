" 10 = normal version, with plugin manager, but w/o need to manually build
" anything. Depends: windows - powershell; linux - curl.
" 20 = full version, requires mingw/gcc for build. Depends: windows -
" powershell; linux - curl, gcc.
" Change the variable and restart vim

let g:vim#version = 10

""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
""""""""""""""""""""""""""""""""""""""""

function! SudoSaveFile() abort
  execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
  let &modified = v:shell_error
endfunction

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

let g:unavail#msg#list = []
function! AddUnavailMsg(name)
    let g:unavail#msg#list = add(g:unavail#msg#list, expand(a:name . ' not available.'))
endfunction

let g:msg#list = []
function! AddMsg(msg)
    let g:msg#list = add(g:msg#list, expand(a:msg))
endfunction

function! IsTerm256Colors()
    if $KONSOLE_PROFILE_NAME !=? '' || $COLORTERM ==? 'gnome-terminal' ||
                    \ $TERM ==? 'screen' || $TERM ==? 'screen-256color' ||
                    \ $TERM ==? 'xterm-256color'
        return 1
    endif
endfunction

function! SendMessages()
    " WORKAROUND with autocmd for gvim popping up dialog box
    if g:unavail#msg#list != []
        let g:unavail#msg = join(g:unavail#msg#list)
        autocmd VimEnter * echomsg g:unavail#msg
    endif
    if g:msg#list != []
        let g:msg = join(g:msg#list)
        autocmd VimEnter * echomsg g:msg
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

    call AddUnavailMsg(a:msg)
endfunction

function! IsPlugManInst()
    if filereadable(g:path#plug_man_exec)
        return 1
    endif

    call AddUnavailMsg('Plugin manager')
endfunction

function! DownloadFile(url, path)
    if has('win32')
        silent! execute '!powershell -Command "& {Invoke-WebRequest -Uri \"' . a:url . '\" -OutFile \"' . a:path . '\"}"'

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
    call EnsureDirExist(g:path#autoload)
    let g:uri#plug_man = 'https://raw.githubusercontent.com/junegunn/
                \vim-plug/master/plug.vim'
    if DownloadFile(g:uri#plug_man, g:path#plug_man_exec)
        call AddMsg('Plugin manager installed.')
        autocmd VimEnter * call PromptExecute('PlugInstall')
    else
        call AddMsg('Plugin manager failed to install.')
    endif
endfunction

function! DelNewLines(text)
    let g:delnewlines#result = substitute(a:text, "\n", "", "g")
    return g:delnewlines#result
endfunction

function! EnsureDirExist(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
    endif
endfunction

function! GetVimProcLibs(info)
    if a:info.status ==? 'installed' || a:info.status ==? 'updated' ||
                \ a:info.force

        if has('win32')
            let g:uri#vimproc_dll_32 = system('powershell -Command "& { $json = Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/Shougo/vimproc.vim/releases | ConvertFrom-Json ; $json.assets.browser_download_url | Select-Object -Index 0 }"')
            let g:uri#vimproc_dll_64 = system('powershell -Command "& { $json = Invoke-WebRequest -UseBasicParsing -Uri https://api.github.com/repos/Shougo/vimproc.vim/releases | ConvertFrom-Json ; $json.assets.browser_download_url | Select-Object -Index 1 }"')

            " fix newlines in powershell output
            let g:uri#vimproc_dll_32 = DelNewLines(g:uri#vimproc_dll_32)
            let g:uri#vimproc_dll_64 = DelNewLines(g:uri#vimproc_dll_64)

            let g:path#vimproc_dll_32 = expand(g:path#plug_man_dir . '/vimproc.vim/lib/vimproc_win32.dll')
            let g:path#vimproc_dll_64 = expand(g:path#plug_man_dir . '/vimproc.vim/lib/vimproc_win64.dll')

            call DownloadFile(g:uri#vimproc_dll_32, g:path#vimproc_dll_32)
            call DownloadFile(g:uri#vimproc_dll_64, g:path#vimproc_dll_64)
        else
            " TODO
            "!make
        endif
    endif
endfunction

function! GetRopeModule(info)
    if a:info.status ==? 'installed' || a:info.status ==? 'updated' ||
                \ a:info.force

        if has('win32')
            " TODO
        else
            call system('pip install --user ropevim')
        endif
    endif
endfunction

function! IsPipInstalled()
    if has('win32')
        " TODO
    else
        call system('pip --version')
        if v:shell_error ==? 0
            return 1
        endif
    endif

    call AddUnavailMsg('Pip-dependent plugins')
endfunction

function! GetSyntasticCheckers(info)
    if a:info.status ==? 'installed' || a:info.status ==? 'updated' ||
                \ a:info.force

        if has('win32')
            " TODO
        else
            call system('pip install --user pyflakes')
            call system('pip install --user pep8')
            call system('pip install --user vim-vint')
        endif
    endif
endfunction

function! PromptExecute(cmd)
    if input('Execute ' . a:cmd . ' ? Type y or n.   ') ==? 'y'
        execute a:cmd
    endif
endfunction

function! SetPythonPathForRope()
    let $PYTHONPATH = join(split(expand("$HOME/.local/lib/*/site-packages")), ":")
endfunction

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
endif

call plug#begin(g:path#plug_man_dir)

" colorschemes
Plug 'morhetz/gruvbox'

" general completion
if IsFeatAvail('lua', 'Lua-based plugins')
    Plug 'shougo/neocomplete.vim'
    " depends
    " TODO
    "if has('win32') || g:vim#version == 20
    "    Plug 'Shougo/vimproc.vim', {'do': function('GetVimProcLibs')} " not required
    "endif
    " misc
    Plug 'Shougo/neco-vim' " vimscript
endif

" powershell
if has('win32')
    " completion
    let g:path#poshcomplete = expand(g:path#plug_man_dir . '/poshcomplete-vim')
    Plug g:path#poshcomplete
    " depends
    " TODO
    Plug 'Shougo/vimproc.vim', {'do': function('GetVimProcLibs')}
    Plug 'mattn/webapi-vim'
    " misc
    Plug 'PProvost/vim-ps1'
endif

" python
if IsFeatAvail('python', 'Python-based plugins')
    if IsPipInstalled()
        " syntastic
        Plug 'scrooloose/syntastic', {'do': function('GetSyntasticCheckers')}
        " rope
        Plug 'python-rope/ropevim', {'do': function('GetRopeModule')}
        call SetPythonPathForRope()
    endif
    " jedi
    Plug 'davidhalter/jedi-vim'
    " misc
    Plug 'hdima/python-syntax'
    Plug 'hynek/vim-python-pep8-indent'
    " ultisnips
    Plug 'SirVer/ultisnips'
    " depends
    Plug 'honza/vim-snippets'
endif

" silver searcher
if executable('ag')
    Plug 'mileszs/ack.vim'
endif

" css misc
Plug 'hail2u/vim-css3-syntax'
" html omnicomplete, misc
Plug 'othree/html5.vim'
" readline bindings for cmd mode
Plug 'vim-utils/vim-husk'
" colorize indent levels
" Plug 'nathanaelkane/vim-indent-guides'
" autoclose braces, quotes..
Plug 'raimondi/delimitmate'
" fast changing of braces, quotes..
Plug 'tpope/vim-surround'
" :Bd don't close split
Plug 'moll/vim-bbye'
" tagbar
Plug 'majutsushi/tagbar'
" unite
Plug 'Shougo/unite.vim'
" vimfiler
Plug 'Shougo/vimfiler.vim'
" comments
Plug 'tpope/vim-commentary'
" yaml support
Plug 'chase/vim-ansible-yaml'
Plug 'will133/vim-dirdiff'
Plug 'Yggdroot/indentLine'


" jumping with % for xml tags
runtime macros/matchit.vim

call plug#end()

"""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
""""""""""""""""""""""""""""""""""""""""

" TODO check if poshcomplete installed at all
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
if isdirectory(expand(g:path#plug_man_dir . '/neocomplete.vim'))
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_auto_close_preview = 1
    let g:neocomplete#fallback_mappings =
        \ ["\<C-x>\<C-o>", "\<C-x>\<C-n>"]
    "let g:neocomplete#skip_auto_completion_time = ''
else
    call AddUnavailMsg('Neocomplete')
endif

" jedi
if isdirectory(expand(g:path#plug_man_dir . '/jedi-vim'))
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
else
    call AddUnavailMsg('Jedi')
endif

" ultisnips
if isdirectory(expand(g:path#plug_man_dir . '/ultisnips'))
    let g:UltiSnipsExpandTrigger = '<tab>'
    let g:UltiSnipsJumpForwardTrigger = '<tab>'
    let g:UltiSnipsJumpBackwardTrigger = '<c-z>'
else
    call AddUnavailMsg('UltiSnips')
endif

" syntastic
if isdirectory(expand(g:path#plug_man_dir . '/syntastic'))
    let g:syntastic_aggregate_errors = 1
    "let g:syntastic_python_checkers = ['python', 'pyflakes', 'pep8']
    let g:syntastic_python_checkers = ['python']
    let g:syntastic_vim_checkers = ['vint']
    let g:syntastic_sh_checkers = ['sh', 'shellcheck']
    let g:syntastic_javascript_checkers = ['eslint']
    let g:syntastic_spec_checkers = ['']
else
    call AddUnavailMsg('Syntastic')
endif

" " indent_guides
" if isdirectory(expand(g:path#plug_man_dir . '/vim-indent-guides'))
"     let g:indent_guides_enable_on_vim_startup = 1
"     let g:indent_guides_start_level = 2
"         "let g:indent_guides_guide_size = 1
"             let g:indent_guides_auto_colors = 0
"     autocmd BufEnter * :hi IndentGuidesOdd  guibg=red   ctermbg=0
"     autocmd BufEnter * :hi IndentGuidesEven guibg=green ctermbg=4

" else
"     call AddUnavailMsg('IndentGuides')
" endif

" delimitmate
if isdirectory(expand(g:path#plug_man_dir . '/delimitmate'))
    let delimitMate_matchpairs = '(:),[:],{:},<:>'
    let delimitMate_nesting_quotes = ['"','`',"'"]
    let delimitMate_expand_cr = 1
    let delimitMate_expand_space = 1
    let delimitMate_expand_inside_quotes = 1
    let delimitMate_jump_expansion = 1
    let delimitMate_balance_matchpairs = 1
else
    call AddUnavailMsg('DelimitMate')
endif

" tagbar
if isdirectory(expand(g:path#plug_man_dir . '/tagbar'))
    let g:tagbar_compact = 1
    nnoremap <F4> :TagbarToggle<CR>
    "autocmd FileType python nested :call tagbar#autoopen(0)
else
    call AddUnavailMsg('Tagbar')
endif

" ropevim
if isdirectory(expand(g:path#plug_man_dir . '/ropevim'))
    "let ropevim_extended_complete = 1
    "let g:ropevim_autoimport_modules = ['os.*', 'sys']
else
    call AddUnavailMsg('Ropevim')
endif

" ack (ag)
if isdirectory(expand(g:path#plug_man_dir . '/ack.vim'))
    let g:ackprg = 'ag --vimgrep'
    let g:ack_qhandler = "botright copen 5"
else
    call AddUnavailMsg('Ack')
endif

" unite
if isdirectory(expand(g:path#plug_man_dir . '/unite.vim'))
    nnoremap <C-P> :Unite -start-insert -auto-resize buffer file_rec<CR>
else
    call AddUnavailMsg('Unite')
endif

" vimfiler
if isdirectory(expand(g:path#plug_man_dir . '/vimfiler.vim'))
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_quick_look_command = 'gloobus-preview'
    nnoremap <F3> :VimFilerExplorer <CR>
    call vimfiler#custom#profile('default', 'context', {
     \ 'safe' : 0,
     \ 'preview_action': 'switch',
     \ })
else
    call AddUnavailMsg('Vimfiler')
endif

" yaml syntax indent
if isdirectory(expand(g:path#plug_man_dir . '/vim-ansible-yaml'))
    let g:ansible_options = {'ignore_blank_lines': 0}
else
    call AddUnavailMsg('Vim-ansible-yaml')
endif

""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""

" language (let it be in the beginning)
set langmenu=none
if has('win32')
    language messages EN
else
    language messages en_US.utf8
endif

filetype plugin indent on

" FIX lag in terminal vim
set timeoutlen=1000
set ttimeoutlen=50

" backup, swap, undo
set undofile
set backup

" tabs, indent
set tabstop=4
set softtabstop=4
set shiftwidth=4
" set smarttab
" set autoindent
set cindent

" statusline
set statusline=%t\ %<%m%H%W%q%=%{GetFileDirectory()}\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set laststatus=2        " always show status bar

" highlight
set showmatch           " highlight matching [{()}]
set hlsearch
set cursorline
set colorcolumn=80
let g:loaded_matchparen = 1
autocmd BufEnter * :highlight ColorColumn ctermbg=4 ctermfg=none cterm=none
autocmd BufEnter * :highlight StatusLineNC cterm=none term=none ctermbg=none ctermfg=0

" folds
set foldcolumn=1        " Add a bit extra margin to the left

" misc
set ignorecase
set smartcase
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
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.ropeproject/*
set wildignore+=Session.vim,*.pyc

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
autocmd FileType * setlocal expandtab

autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2

" python
if IsFeatAvail('python', 'Python configuration')
    let python_highlight_all = 1
    autocmd Filetype python setlocal foldmethod=indent
    autocmd Filetype python setlocal foldlevel=1
    autocmd Filetype python setlocal foldminlines=15
    autocmd Filetype python setlocal foldnestmax=2
    autocmd FileType python map <buffer> <F1> oimport pudb; pudb.set_trace()<C-[>

endif

" restore cursor position on file open
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
            \ exe "normal! g`\"" | endif

" delete trailing spaces
autocmd BufWrite * call DeleteTrailingWS()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
            call AddUnavailMsg('Guifont')
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
    cnoremap w!!! call SudoSaveFile()<CR>
    cnoremap W!!! w !sudo tee % > /dev/null
endif

" edit vimrc
command Ev execute 'edit ' . g:path#vimrc

" set paste
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" faster split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TRASH
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" POST-OPERATIONS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call SendMessages()
