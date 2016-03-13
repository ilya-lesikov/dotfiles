""""""""""""""""""""""""""""""""""""""""
" Vundle initialization
""""""""""""""""""""""""""""""""""""""""
set shell=bash          " posix shell needed for vundle
set filetype=off           "  vundle needed
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required

Plugin 'tomasr/molokai'
Plugin 'morhetz/gruvbox'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'majutsushi/tagbar'
Plugin 'rking/ag.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'klen/python-mode'

" All of your Plugins must be added before this line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""
" Vim settings
""""""""""""""""""""""""""""""""""""""""

" default paths
set rtp+=~/.vim " set runtime path to add .vim
set tags=~/.vim/tags

set undofile
set undodir=~/.vim/undodir

set backup
set writebackup
set backupdir=~/.vim/backups,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim/backups,~/tmp,/var/tmp,/tmp

" tabs/spaces and indentation
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4
set expandtab       " tabs are spaces
set smarttab            " Be smart when using tabs ;)
set autoindent
set smartindent

" statusline
set statusline=%t%<%m%H%W%q%=%{GetFileDirectory()}\ %l-%L\ %p%%
set laststatus=2        " always show status bar

" search, highlighting
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase
set smartcase           " When searching try to be smart about cases
set magic               " For regular expressions turn magic on

" folding
set foldenable          " enable folding
set foldmethod=manual   " fold based on indent level
set foldcolumn=1        " Add a bit extra margin to the left

" disable error signals
set noerrorbells        " disable errors
set novisualbell        " disable errors
set vb t_vb=            " disable errors
set confirm             " prompts instead of errors

set scrolloff=999       " Set 7 lines to the cursor - when moving vertically using j/k
set textwidth=80
set nowrap
set autoread            " autoreload buffer if changes
set lazyredraw          " redraw only when we need to.
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set encoding=utf8
set ffs=unix,dos,mac
set matchtime=5         " bracket blinking
set showfulltag
set hidden              " buffers don't close
set nocompatible        " nocompatible with vi
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set colorcolumn=+1
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h,n~/.vim/viminfo

setlocal shortmess+=I   " hide intro message on start
colorscheme industry
syntax enable
" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

" pymode recommended
set complete+=t
set commentstring=#%s
set define=^\s*\\(def\\\\|class\\)

" autocommenting disabled
autocmd FileType * setlocal formatoptions-=r formatoptions-=o formatoptions+=t formatoptions+=c formatoptions+=n formatoptions+=w formatoptions+=l

" maximum history items
autocmd FileType * setlocal history=300

" mouse support
if has('mouse')
  set mouse=a
endif

" python specific
let g:loaded_python_provider = 1
let g:loaded_python3_provider = 1
let g:python_host_skip_check = 1
let g:python3_host_skip_check = 1
let python_highlight_all = 1


""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
""""""""""""""""""""""""""""""""""""""""

" get directory of opened file for statusline
function! GetFileDirectory ()
    let fileDirectory = expand("%:p:h")
    return fileDirectory
endfunction

" delete trailing spaces on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

autocmd BufWrite * :call DeleteTrailingWS()

""""""""""""""""""""""""""""""""""""""""
" MAPPINGS
""""""""""""""""""""""""""""""""""""""""

" map leader
let mapleader = ","
let g:mapleader = ","

" search highlight disabling
nnoremap <leader>/ :nohlsearch<CR>

" :W save the file as root
command W w !sudo tee % > /dev/null

" move by visually wrapped lines too
nnoremap j gj
nnoremap k gk

" move between splits (windows)
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" insert blank new line and go back to normal mode
nmap <leader>O O<Down><Esc>
nmap <leader>o o<Up><Esc>

" history forward/backward in command line
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" next/previous buffers
nnoremap <silent> <C-P> :bp<cr>
nnoremap <silent> <C-N> :bn<cr>

" buffer last
nmap <leader>bp :b #<cr>

" unjoin (split) line
map <leader>j i<Enter><Esc>

" delete buffer without closing split (windows)
nmap <leader>bd :bp<bar>bd #<cr>

" faster horizontal navigation
nnoremap <S-H> zHgm
nnoremap <S-L> zLgm

" space insert space after char, shift+space insert before
nmap <space> a<space><Left><Esc>
nmap <leader><space> i<space><Right><Esc>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GVIM SETTINGS (GRAPHICAL, GUI)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
    colorscheme molokai
    set background=dark
    set guifont=Hack\ 10
    " ,Hack:h14,Bitstream\ Vera\ Sans\ Mono:h14
    " set gfn=Source\ Code\ Pro:h12
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guioptions+=a  "highlighted text automatically copies to "* register
    set guioptions+=c  "no graphical popup dialogs
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" tagbar
nmap <leader>tt :TagbarToggle<CR>

" nerdtree
map <leader>te :NERDTreeToggle<CR>

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

" pymode
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
