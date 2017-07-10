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
  if &ft =~ 'markdown'
    return
  endif

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
  silent! execute '!curl -fLo "' . a:path . '" --create-dirs "' . a:url . '"'

  if filereadable(a:path)
    return 1
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

function! IsPipInstalled()
  call system('pip --version')
  if v:shell_error ==? 0
    return 1
  endif

  call AddUnavailMsg('Pip-dependent plugins')
endfunction

function! GetSyntasticCheckers(info)
  if a:info.status ==? 'installed' || a:info.status ==? 'updated' ||
        \ a:info.force

    call system('pip install --user pyflakes')
    call system('pip install --user pep8')
    call system('pip install --user vim-vint')
  endif
endfunction

function! PromptExecute(cmd)
  if input('Execute ' . a:cmd . ' ? Type y or n.   ') ==? 'y'
    execute a:cmd
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""
" VARS
""""""""""""""""""""""""""""""""""""""""

let g:path#vim_user_dir = expand('~/.vim')
let g:path#vimrc = expand('~/.vimrc')

let g:path#autoload = expand(g:path#vim_user_dir . '/autoload')
let g:path#plug_man_exec = expand(g:path#vim_user_dir . '/autoload/plug.vim')
let g:path#plug_man_dir = expand(g:path#vim_user_dir . '/plugged')

" let &rtp .= ','.expand(g:path#vim_user_dir . '/ftplugin')
" let &rtp .= ','.expand(g:path#vim_user_dir . '/indent')
" let &rtp .= ','.expand(g:path#vim_user_dir . '/syntax')
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

" theme
Plug 'morhetz/gruvbox'

Plug 'scrooloose/syntastic'
let g:syntastic_aggregate_errors = 1
"let g:syntastic_python_checkers = ['python', 'pyflakes', 'pep8']
let g:syntastic_python_checkers = ['python']
let g:syntastic_vim_checkers = ['vint']
let g:syntastic_sh_checkers = ['sh', 'shellcheck']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_spec_checkers = ['']

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<c-tab>'

Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep'
let g:ack_qhandler = "botright copen 3"
let g:ackpreview = 1
nnoremap <leader>s :Ack!<Space>''<Left>

Plug 'raimondi/delimitmate'
let delimitMate_matchpairs = '(:),[:],{:},<:>'
let delimitMate_nesting_quotes = ['"','`',"'"]
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_expand_inside_quotes = 1
let delimitMate_jump_expansion = 1
let delimitMate_balance_matchpairs = 1

Plug 'majutsushi/tagbar'
let g:tagbar_compact = 1
nnoremap <leader>E :TagbarToggle<CR>
"autocmd FileType python nested :call tagbar#autoopen(0)

Plug 'Shougo/unite.vim'
nnoremap <C-P> :Unite -start-insert -auto-resize buffer file_rec<CR>

" Plug 'Shougo/vimfiler.vim'
" let g:vimfiler_as_default_explorer = 1
" let g:vimfiler_quick_look_command = 'gloobus-preview'
" nnoremap <leader>e :VimFilerExplorer<CR>
" call vimfiler#custom#profile('default', 'context', {
"       \ 'safe' : 0,
"       \ 'preview_action': 'switch',
"       \ })

Plug 'francoiscabrol/ranger.vim'
let g:ranger_map_keys = 0
map <leader>e :Ranger<CR>

Plug 'dhruvasagar/vim-table-mode'
let g:table_mode_corner='|'

"Plug 'sbdchd/neoformat'

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer' }
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:ycm_python_binary_path = 'python2'
nmap <leader>d :YcmCompleter GoToDeclaration<CR>
nmap <leader>D :YcmCompleter GoToDefinition<CR>
nmap <leader>* :YcmCompleter GoToReferences<CR>
nmap <leader>k :YcmCompleter GetDoc<CR>
let g:ycm_semantic_triggers =  {
  \   'c' : ['->', '.'],
  \   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
  \             're!\[.*\]\s'],
  \   'ocaml' : ['.', '#'],
  \   'cpp,objcpp' : ['->', '.', '::'],
  \   'perl' : ['->'],
  \   'php' : ['->', '::'],
  \   'cs,java,javascript,typescript,d,perl6,scala,vb,elixir,go' : ['.'],
  \   'ruby' : ['.', '::'],
  \   'lua' : ['.', ':'],
  \   'erlang' : [':'],
  \   'python' : ['re!(import\s+|from\s+(\w+\s+(import\s+(\w+,\s+)*)?)?)'],
  \ }
let g:ycm_filetype_specific_completion_to_disable = {
      \ 'lua' : 1
      \}


Plug 'hail2u/vim-css3-syntax'
Plug 'othree/html5.vim'
" readline bindings
Plug 'vim-utils/vim-husk'
Plug 'tpope/vim-surround'
Plug 'moll/vim-bbye'
Plug 'tomtom/tcomment_vim'
Plug 'will133/vim-dirdiff'
Plug 'Yggdroot/indentLine'
Plug 'ingydotnet/yaml-vim'
Plug 'hdima/python-syntax'
Plug 'hynek/vim-python-pep8-indent'
Plug 'tpope/vim-eunuch'
" Plug 'tbastos/vim-lua'
Plug 'roxma/vim-paste-easy'
" Plug 'metakirby5/codi.vim'
" Plug 'shougo/vimshell.vim'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'andrewradev/splitjoin.vim'
Plug 'michaeljsmith/vim-indent-object'

" Plug 'joonty/vdebug', { 'branch': 'v2-integration' }
" if !exists('g:vdebug_options')
"   let g:vdebug_options = {}
" endif
" let g:vdebug_options.port = 8172

" Plug 'idanarye/vim-vebugger'
" let g:vebugger_leader='<Leader>z'

" set shiftwidth automatically
Plug 'tpope/vim-sleuth'
" Plug 'ludovicchabant/vim-gutentags'

Plug 'xolox/vim-misc'
" Plug 'xolox/vim-easytags', { 'commit': 'f5746bdfd9942b00c349e53f3f4917ae73bb6797' }
Plug 'Wraul/vim-easytags', { 'branch': 'fix-universal-detection' }
let g:easytags_async = 1
let g:easytags_file = '~/.vim/tags'
let g:easytags_autorecurse = 1
let g:easytags_resolve_links = 1

Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
nmap <leader>a gaii

" jumping with % for xml tags
runtime macros/matchit.vim

call plug#end()

""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""

" language (let it be in the beginning)
set langmenu=none
language messages en_US.utf8

filetype plugin indent on

" FIX lag in terminal vim
set timeoutlen=1000
set ttimeoutlen=50

" backup, swap, undo
set undofile
set backup

" tabs, indent
set tabstop=2
set softtabstop=2
set shiftwidth=2
" set smarttab
" set autoindent
set cindent
set cinoptions+=(0
set expandtab
autocmd FileType * setlocal expandtab

" statusline
"set statusline=%t\ %<%m%H%W%q%=%{GetFileDirectory()}\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set statusline=%F\ %<%m%H%W%q%=\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set laststatus=2        " always show status bar

" highlight
set showmatch           " highlight matching [{()}]
set hlsearch
set cursorline
set colorcolumn=80
" let g:loaded_matchparen = 1
autocmd BufEnter * :highlight ColorColumn ctermbg=8 ctermfg=none cterm=none
autocmd BufEnter * :highlight StatusLineNC cterm=none term=none ctermbg=none ctermfg=0

" folds
set foldcolumn=1        " Add a bit extra margin to the left

" misc
" set iskeyword+=:,::,.
set encoding=utf-8
set ignorecase
set smartcase
set incsearch
set scrolloff=999
" set autoread            " autoreload buffer if changes
set lazyredraw          " redraw only when we need to.
set showcmd             " show command in bottom bar
set wildmenu            " visual autocomplete for command menu
set showfulltag
set hidden
set nocompatible
set confirm
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h
set sessionoptions-=blank
set sessionoptions-=options
set shiftround          " round indentation
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
setlocal shortmess+=I   " hide intro message on start
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.ropeproject/*
set wildignore+=Session.vim,*.pyc
set updatetime=2000

" gui
if has('gui_running')
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  set guioptions+=c  "no graphical popup dialogs
endif

autocmd FileType * syntax on

autocmd FileType * setlocal history=300

autocmd FileType * setlocal formatoptions-=t
autocmd FileType * setlocal formatoptions-=o
autocmd FileType * setlocal formatoptions-=r

" python
let python_highlight_all = 1
autocmd Filetype python setlocal foldmethod=indent
autocmd Filetype python setlocal foldlevel=1
autocmd Filetype python setlocal foldminlines=15
autocmd Filetype python setlocal foldnestmax=2
autocmd FileType python nmap <buffer> <leader>b Oimport pudb; pudb.set_trace()<C-[>
autocmd FileType python setlocal tabstop=4
autocmd FileType python setlocal softtabstop=4
autocmd FileType python setlocal shiftwidth=4

autocmd FileType lua nmap <buffer>
      \ <leader>b Oif require("os").getenv("DISPLAY") ~= ":0.0"
      \ then require("debugger")() end<C-[>
      " \ then require("mobdebug").start() end<C-[>

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

  try
    set guifont=Source\ Code\ Pro\ 10
  catch
    call AddUnavailMsg('Guifont')
    set guifont=DejaVu\ Sans\ Mono\ 10
  endtry
else
  if IsTerm256Colors()
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
function! SudoSaveFile() abort
  execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
  let &modified = v:shell_error
endfunction
cnoremap w!!! call SudoSaveFile()<CR>
cnoremap W!!! w !sudo tee % > /dev/null

" edit config files
command! Rv execute 'source ' . g:path#vimrc
command! Ev execute 'edit ' . g:path#vimrc
command! Et execute 'edit ' . "~/.tmux.conf"
command! Etd execute 'edit ' . "~/.tmuxinator/default.yml"
command! Eb execute 'edit ' . "~/.bashrc"
command! Ep execute 'edit ' . "~/.profile"
command! Ex execute 'edit ' . "~/.Xresources"
command! Es execute 'edit ' . "~/git/linux-utils/wmctrl-session-autostart.sh"
command! Er execute 'edit ' . "~/.config/ranger/rc.conf"
command! Err execute 'edit ' . "~/.config/ranger/rifle.conf"
command! Ea execute 'edit ' . "~/.config/awesome/rc.lua"
command! Eat execute 'edit ' . "~/.config/awesome/themes/copland/theme.lua"

" fast fullscreen split/revert back
nnoremap \| <C-W>\|<C-W>_
nnoremap + <C-W>=

" open 4 splits side by side
function! SetupSplits()
  execute 'silent! e /tmp/blank'
  execute 'only'
  execute 'split'
  execute 'vsplit'
  execute 'wincmd j'
  execute 'vsplit'
  execute 'wincmd k'
endfunction
command! Ss call SetupSplits()

" save current buffer automatically
command! As autocmd CursorHold,CursorHoldI <buffer> update

" split navigation without plugin
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" disable highlighting
nnoremap <leader>h :nohl<CR>

" remove unneeded spaces
nnoremap <leader>oc :s/\([[:graph:]]\+\)[ ]\{2,\}/\1 /g<CR>

" show linenumbers
nnoremap <leader>n :set number!<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call SendMessages()
