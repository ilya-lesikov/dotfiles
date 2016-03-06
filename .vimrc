""""""""""""""""""""""""""""""""""""""""
" Vundle initialization
""""""""""""""""""""""""""""""""""""""""
set shell=bash          " posix shell needed for vundle
set filetype=off           "  vundle needed
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required

" Plugin 'terryma/vim-multiple-cursors'
" Plugin 'lyokha/vim-xkbswitch'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'bling/vim-airline'
Plugin 'tobes/vim-budget-airline'
Plugin 'majutsushi/tagbar'
Plugin 'ervandew/supertab'
Plugin 'rking/ag.vim'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'Raimondi/delimitMate'
Plugin 'klen/python-mode'
" Plugin 'myusuf3/numbers.vim'
" Plugin 'xolox/vim-easytags'
" Plugin 'godlygeek/tabular'
" Plugin 'tpope/vim-surround'
" Plugin 'tpope/vim-fugitive'
" Plugin 'easymotion/vim-easymotion'
" Plugin 'fholgado/minibufexpl.vim'
" Plugin 'Shougo/unite.vim'
" Plugin 'xolox/vim-misc'
" Plugin 'justinmk/vim-sneak'
" Plugin 'rhysd/clever-f.vim'
" Plugin 'airblade/vim-gitgutter'

" All of your Plugins must be added before this line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""
" Vim settings
""""""""""""""""""""""""""""""""""""""""
set rtp+=~/.vim " set runtime path to add .vim
set history=500
set autoread
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4
set expandtab       " tabs are spaces
" set number              " show line numbers
" set relativenumber
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set scrolloff=999               " Set 7 lines to the cursor - when moving vertically using j/k
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set foldenable          " enable folding
" set foldlevelstart=10   " open most folds by default
" set foldnestmax=10      " 10 nested fold max
set foldmethod=manual   " fold based on indent level
set ruler               "Always show current position
set ignorecase
set smartcase           " When searching try to be smart about cases 
set magic               " For regular expressions turn magic on
set noerrorbells        " disable errors
set novisualbell        " disable errors
set vb t_vb=            " disable errors
set t_Co=256            " 256 colors
set encoding=utf8
set ffs=unix,dos,mac
set smarttab            " Be smart when using tabs ;)
" set linebreak
set autoindent
set smartindent
set matchtime=5         " bracket blinking
set laststatus=2        " always show status bar
set showfulltag     
set hidden              " buffers don't close
set undodir=~/.vim/undodir
set undofile
set shortmess+=I        
set confirm             " prompts instead of errors
set nocompatible        " nocompatible with vi
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
syntax enable
" set termencoding=utf8
set foldcolumn=1        " Add a bit extra margin to the left
set tags=~/.vim/tags
" set ch=2                " make cmd line 2 strings high
 
" Set backup directory
set backup
set backupdir=~/.vim/backups,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim/backups,~/tmp,/var/tmp,/tmp
set writebackup

" pymode recommended
set complete+=t
" set formatoptions+=t
" set wrap
set commentstring=#%s
set define=^\s*\\(def\\\\|class\\)

" set linebreak

" autocmd FileType * setlocal textwidth=79

set textwidth=80
set nowrap

" autocommenting disabled
autocmd FileType * setlocal formatoptions-=r formatoptions-=o formatoptions+=t formatoptions+=c formatoptions+=n formatoptions+=w formatoptions+=l 

if has('mouse')
  set mouse=a
endif

" Python specific
let g:loaded_python_provider = 1
let g:loaded_python3_provider = 1
let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1
let python_highlight_all = 1

" mapleader
let mapleader = ","
let g:mapleader = ","

" turn off search highlight
nnoremap <leader>/ :nohlsearch<CR>

" :W sudo saves the file
command W w !sudo tee % > /dev/null 

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" new line without insert mode
nmap <leader>O O<Esc>
nmap <leader>o o<Esc>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
"Remember info about open buffers on close
set viminfo^=%


" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()

" Set font according to system
if has("mac") || has("macunix")
    set gfn=Source\ Code\ Pro:h15,Hack:h14,Menlo:h15
elseif has("win16") || has("win32")
    set gfn=Source\ Code\ Pro:h12,Hack:h14,Bitstream\ Vera\ Sans\ Mono:h11
elseif has("linux")
    set gfn=Source\ Code\ Pro:h12,Hack:h14,Bitstream\ Vera\ Sans\ Mono:h11
elseif has("unix")
    set gfn=Monospace\ 11
endif

" Bash like keys for the command line
cnoremap <C-A>		<Home>
cnoremap <C-E>		<End>
" cnoremap <C-K>		<C-U>
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>
cnoremap <C-G> <C-A>

" map pr/next buffers and pr/next tab
nnoremap <silent> <C-P> :bp<cr>
nnoremap <silent> <C-N> :bn<cr>
" nnoremap <silent> <C-P> gT
" nnoremap <silent> <C-N> gt

" buffer last
nmap <leader>bp :b #<cr>

" unjoin line
map K i<Enter><Esc>

" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

" automatically wrap line when merging them
" nnoremap J Jgql
nmap <leader>j Jgql

" delete buffer without closing window
nmap <leader>bq :bp<bar>bd #<cr>

" new empty buffer
nmap <leader>bn :enew<cr>

" save buffer
nmap <leader>bw :w<cr>

" buffers list
nmap <leader>bl :ls<cr>

" faster horizontal navigation
nnoremap <S-H> zHgm
nnoremap <S-L> zLgm

" move to the first char instead of beginning of line
nnoremap 0 ^

" space insert space after char, shift+space insert before
nmap <space> a<space><Esc>h
nmap <leader><space> i<space><Esc>l

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GVIM SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")
    " set background=dark
    " colorscheme peaksea
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guioptions+=a  "highlighted text automatically copies to "* register
    set guioptions+=c  "no graphical popup dialogs
    colorscheme mac_classic
else
    colorscheme desert
    let g:colors_name="desert"
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tagbar
nmap <leader>tt :TagbarToggle<CR>

" nerdtree
map <leader>te :NERDTreeToggle<CR>

" multiline
" let g:multi_cursor_start_key='<leader>n'
" highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse guibg=Green

" nerdcommenter
let g:NERDSpaceDelims=1

" ctrlp
let g:ctrlp_map = ''
let g:ctrlp_switch_buffer = 'Et'
let g:ctrlp_show_hidden = 0
let g:ctrlp_use_caching = 1
let g:ctrlp_switch_buffer = ''
nmap <leader>sf :CtrlP<cr>
nmap <leader>sb :CtrlPBuffer<cr>

" airline
let g:airline#extensions#default#section_truncate_width = {}
let g:airline#extensions#whitespace#show_message = 0
" let g:airline#extensions#budgetairline#enabled
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#fnamemod = ':t'

" autocmd FileType * AirlineTheme term
" autocmd FileType * AirlineToggleWhitespace

" xkbswitch
" let g:XkbSwitchEnabled = 1
" let g:XkbSwitchIMappings = ['ru']
" let g:XkbSwitchAssistNKeymap = 1    " for commands r and f
" let g:XkbSwitchAssistSKeymap = 1    " for search lines
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0
" let g:XkbSwitchNLayout = 'us'
" " autocmd BufEnter * let b:XkbSwitchILayout = 'us'
" let g:XkbSwitchILayout = 'us'
" let b:XkbSwitchILayout = 'us'


" python mode
let g:pymode=1
let g:pymode_warnings=1
let g:pymode_indent=1
let g:pymode_folding=1
let g:pymode_motion=1
let g:pymode_doc = 1
let g:pymode_doc_bind = '<leader>mk'
let g:pymode_virtualenv = 1
let g:pymode_run = 1
let g:pymode_run_bind = '<leader>mr'
let g:pymode_breakpoint_bind = '<leader>mb'
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_cmd = ''
let g:pymode_lint = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_unmodified = 0
let g:pymode_lint_on_fly = 0
let g:pymode_lint_message = 1
let g:pymode_lint_checkers = ['pyflakes', 'pep8', 'mccabe']
let g:pymode_lint_ignore = "E501,W"
let g:pymode_lint_select = "E501,W0011,W430"
let g:pymode_lint_sort = []
let g:pymode_lint_cwindow = 1
let g:pymode_lint_signs = 1
let g:pymode_lint_todo_symbol = 'WW'
let g:pymode_lint_comment_symbol = 'CC'
let g:pymode_lint_visual_symbol = 'RR'
let g:pymode_lint_error_symbol = 'EE'
let g:pymode_lint_info_symbol = 'II'
let g:pymode_lint_pyflakes_symbol = 'FF'
let g:pymode_rope = 1
let g:pymode_rope_lookup_project = 0
let g:pymode_rope_project_root = ""
let g:pymode_rope_ropefolder='.ropeproject'
let g:pymode_rope_show_doc_bind = '<C-c>d'
let g:pymode_rope_regenerate_on_write = 1
let g:pymode_rope_completion = 1
let g:pymode_rope_complete_on_dot = 1
let g:pymode_rope_completion_bind = '<C-Space>'
let g:pymode_rope_autoimport = 0
let g:pymode_rope_autoimport_import_after_complete = 0
let g:pymode_rope_goto_definition_bind = '<C-c>g'
let g:pymode_rope_goto_definition_cmd = 'new'
let g:pymode_rope_rename_bind = '<C-c>rr'
let g:pymode_rope_rename_module_bind = '<C-c>r1r'
let g:pymode_rope_organize_imports_bind = '<C-c>ro'
let g:pymode_rope_autoimport_bind = '<C-c>ra'
let g:pymode_rope_module_to_package_bind = '<C-c>r1p'
let g:pymode_rope_extract_method_bind = '<C-c>rm'
let g:pymode_rope_extract_variable_bind = '<C-c>rl'
let g:pymode_rope_use_function_bind = '<C-c>ru'
let g:pymode_rope_move_bind = '<C-c>rv'
let g:pymode_rope_change_signature_bind = '<C-c>rs'
let g:pymode_syntax = 1
let g:pymode_syntax_slow_sync = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_print_as_function = 0
let g:pymode_syntax_highlight_async_await = g:pymode_syntax_all
let g:pymode_syntax_highlight_equal_operator = g:pymode_syntax_all
let g:pymode_syntax_highlight_stars_operator = g:pymode_syntax_all
let g:pymode_syntax_highlight_self = g:pymode_syntax_all
let g:pymode_syntax_highlight_self = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all
let g:pymode_syntax_string_formatting = g:pymode_syntax_all
let g:pymode_syntax_string_format = g:pymode_syntax_all
let g:pymode_syntax_string_templates = g:pymode_syntax_all
let g:pymode_syntax_doctests = g:pymode_syntax_all
let g:pymode_syntax_builtin_objs = g:pymode_syntax_all
let g:pymode_syntax_builtin_types = g:pymode_syntax_all
let g:pymode_syntax_highlight_exceptions = g:pymode_syntax_all
let g:pymode_syntax_docstrings = g:pymode_syntax_all


