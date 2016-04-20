""""""""""""""""""""""""""""""""""""""""
" Vundle initialization
""""""""""""""""""""""""""""""""""""""""
set shell=bash          " posix shell needed for vundle
set filetype=off           "  vundle needed
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required

"Plugin 'tomasr/molokai'
Plugin 'w0ng/vim-hybrid'
Plugin 'morhetz/gruvbox'

Plugin 'Valloric/YouCompleteMe'
"Plugin 'scrooloose/nerdtree'
"Plugin 'scrooloose/nerdcommenter'
"Plugin 'rking/ag.vim'
"Plugin 'ctrlpvim/ctrlp.vim'

" All of your Plugins must be added before this line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""
" Vim settings
""""""""""""""""""""""""""""""""""""""""

" no lag in terminal vim
set timeoutlen=1000
set ttimeoutlen=0

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

" wrapping
set wrap
set linebreak
set nolist              " list disables linebreak
set textwidth=0
set wrapmargin=0

" disable error signals
set noerrorbells        " disable errors
set novisualbell        " disable errors
set vb t_vb=            " disable errors
set confirm             " prompts instead of errors

set scrolloff=7       " Set 7 lines to the cursor - when moving vertically using j/k
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
set colorcolumn=80
set viminfo='50,<100,s100,:1000,/1000,@1000,f1,h,n~/.vim/viminfo
set complete+=t

setlocal shortmess+=I   " hide intro message on start
syntax enable
" cyrillic support
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=0

" autocommenting disabled
autocmd FileType * setlocal formatoptions-=r formatoptions-=o formatoptions-=t formatoptions+=c formatoptions+=n formatoptions+=w formatoptions+=l

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
" MAPPINGS (keys, bindings)
""""""""""""""""""""""""""""""""""""""""

" map leader
" let mapleader = "\"
" let g:mapleader = "\"

" search highlight disabling
"nnoremap <leader>/ :nohlsearch<CR>

" :W save the file as root
command W w !sudo tee % > /dev/null

" move by visually wrapped lines too
"nnoremap j gj
"nnoremap k gk

" delete buffer without closing split (windows)
"nmap <leader>bd :bp<bar>bd #<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DEPENDENT ON $TERM SETTINGS (graphical, gui, gvim, terminal, console, tty)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running")
    set background=dark
    set guifont=Hack\ 10
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    set guioptions+=a  "highlighted text automatically copies to "* register
    set guioptions+=c  "no graphical popup dialogs
else
    if $KONSOLE_PROFILE_NAME != '' || $COLORTERM == 'gnome-terminal' || $TERM == 'screen' || $TERM == 'screen-256color'
        " colorscheme hybrid
        colorscheme gruvbox
        set background=dark
    else
        colorscheme industry
        set background=dark
    endif
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETTINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""



