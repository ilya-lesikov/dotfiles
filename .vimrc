""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VARIABLES
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:path#vim_user_dir = expand('~/.config/nvim')
let g:path#vimrc = expand('~/.config/nvim/init.vim')

let g:path#autoload = expand(g:path#vim_user_dir . '/autoload')
let g:path#plug_man_exec = expand(g:path#vim_user_dir . '/autoload/plug.vim')
let g:path#plug_man_dir = expand(g:path#vim_user_dir . '/plugged')

let &undodir = expand(g:path#vim_user_dir . '/misc')
let &backupdir = expand(g:path#vim_user_dir . '/misc')
let &directory = expand(g:path#vim_user_dir . '/misc')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" HELPER FUNCTIONS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
  if g:unavail#msg#list != []
    let g:unavail#msg = join(g:unavail#msg#list)
    echomsg g:unavail#msg
  endif
  if g:msg#list != []
    let g:msg = join(g:msg#list)
    echomsg g:msg
  endif
endfunction

function! EnsureDirExist(dir)
  if !isdirectory(a:dir)
    call mkdir(a:dir, 'p')
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PREPARE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" create vim-related directories if they do not exist
for dir in [
      \ g:path#vim_user_dir, g:path#plug_man_dir, &undodir, &backupdir, &directory
      \ ]
  call EnsureDirExist(dir)
endfor

"
" Initialize plugin manager and define plugins after this line
call plug#begin(g:path#plug_man_dir)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FEATUREFUL PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" autocompletion, refactoring, LSP/VSCode extensions
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_filetype_map = {
      \ 'helm': 'yaml',
      \ }
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gh :CocDiagnostics<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references-used)
nmap <leader>gs :CocList symbols<CR>
nmap <leader>go :CocList outline<CR>
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Remap for rename current word
nmap <leader>gn <Plug>(coc-rename)
" Remap for format selected region
nmap <leader>gg <Plug>(coc-format-selected)
" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>gr <Plug>(coc-codeaction-selected)
" Remap for do codeAction of current line
nmap <leader>gl <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>gf <Plug>(coc-fix-current)
" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" disable autopreview feature (doesn't work for me now)
let g:coc_enable_locationlist = 0
autocmd User CocLocationsChange CocList --normal location

augroup CocGroup1
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" async on-the-fly linting
Plug 'w0rp/ale'
let g:ale_linters = {
    \ 'c'          : ['clangtidy'],
    \ 'javascript' : ['eslint'],
    \ 'python'     : ['flake8'],
    \ 'chef'       : [''],
    \ 'go'         : ['golangci-lint'],
    \ }
      " \ 'cpp'        : ['clangtidy', 'cpplint'],
let g:ale_python_pylint_options = '-d C0103,C0111,C0321'
let g:ale_python_flake8_options =  '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,E702,E501'
let g:ale_cpp_clangcheck_options = '-extra-arg="-std=c++11"'
let g:ale_cpp_clangtidy_options = '-std=c++11'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '%s       %severity% | %linter% | %code%'
let g:ale_cpp_cpplint_options = '--linelength=120 --filter=-readability/todo,-whitespace/operators'
let g:ale_python_flake8_options = '--ignore=E303,E121,E123,E126,E226,E24,E704,W503,W504,E501 --max-line-length=120'
let g:ale_ruby_rubocop_options = '--except Layout/AlignParameters,Style/Documentation,Metrics/MethodLength,Style/GuardClause,Metrics/AbcSize,Naming/AccessorMethodName,Layout/MultilineMethodCallIndentation,Metrics/LineLength,Metrics/BlockLength'
let g:ale_sh_shellcheck_exclusions = 'SC1090'
let g:ale_yaml_yamllint_options = '-d "{extends: default, rules: {line-length: {max: 120}, indentation: {indent-sequences: consistent}, document-start: disable}}"'
let g:ale_go_golangci_lint_options = '-p bugs,error,unused -D wrapcheck,goerr113,ineffassign,errorlint'
let g:ale_go_golangci_lint_package = 1
let g:ale_echo_delay = 200
autocmd BufEnter PKGBUILD,.env
    \   let b:ale_sh_shellcheck_exclusions = 'SC2034,SC2154,SC2164'
nmap <silent> <leader>lp <Plug>(ale_previous_wrap)
nmap <silent> <leader>ln <Plug>(ale_next_wrap)

" fast file search + help, history, registers search and more
Plug 'Shougo/denite.nvim', {'do': ':UpdateRemotePlugins'}
nnoremap <C-A-p> :ccl<CR>:Denite file/rec<CR>
nnoremap <C-p> :ccl<CR>:Denite file/rec/hidden<CR>
nnoremap <leader>p :ccl<CR>:Denite buffer<CR>

autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
    nnoremap <silent><buffer><expr> <CR>
               \ denite#do_map('do_action')
endfunction
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
    inoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
    " imap <silent><buffer> <tab> <Plug>(denite_filter_quit)
    inoremap <silent><buffer><expr> <esc>
               \ denite#do_map('quit')
    inoremap <silent><buffer> <C-j>
               \ <Esc><C-w>p:call cursor(line('.')+1,0)<CR><C-w>pA
    inoremap <silent><buffer> <C-k>
               \ <Esc><C-w>p:call cursor(line('.')-1,0)<CR><C-w>pA
endfunction

" faster grep alternative integration
Plug 'mileszs/ack.vim'
let g:ackprg = 'rg --vimgrep --hidden'
let g:ack_qhandler = "botright copen 10"
let g:ackpreview = 1
let g:ackhighlight = 1
nnoremap <leader>s :Ack!<Space>'

" search and replace recursively
Plug 'dyng/ctrlsf.vim'
" let g:ctrlsf_default_view_mode = 'compact'
let g:ctrlsf_follow_symlinks = 0
let g:ctrlsf_ackprg = "rg"
let g:ctrlsf_mapping = {
     \ "quit"    : "",
     \ "pquit"   : "",
     \ "popen"   : "",
     \ "popenf"  : "",
     \ "tab"     : "",
     \ "tabb"    : "",
     \ "open"    : "o",
     \ "openb"   : "O",
     \ }
nnoremap <leader>rr :CtrlSF -hidden<Space>
nnoremap <leader>rc :CtrlSFClose<CR>
function! g:CtrlSFAfterMainWindowInit()
    setl wrap
endfunction

" show changed lines in git
Plug 'mhinz/vim-signify'
" don't run on cursorhold, it slows down vim
autocmd User SignifyAutocmds autocmd! signify CursorHold,CursorHoldI

" text alignment
Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
nmap <leader>ag gaii

" make tables (no table-like alignments, only fully formatted tables created)
Plug 'dhruvasagar/vim-table-mode'
let g:table_mode_corner='|'
let g:table_mode_map_prefix = '<Leader>t'

" only for 'sexy' multiline comments (<leader>cs)
" and usual multiline (<lead>cm) + some automatic stuff
Plug 'scrooloose/nerdcommenter'
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
" For all the other comments
Plug 'tyru/caw.vim'
let g:caw_hatpos_skip_blank_line = 1
let g:caw_wrap_skip_blank_line = 1

" autoclose quotes, parentheses, brackets..
Plug 'ervandew/matchem'
" replace quotes, parens, brackets...
Plug 'tpope/vim-surround'

" diff whole directories
Plug 'will133/vim-dirdiff'
" diff on blocks of code
Plug 'AndrewRadev/linediff.vim'

" gnupg encryption and transparent decryption support
Plug 'jamessan/vim-gnupg'

" ansible vault files decryption support
Plug 'thiagoalmeidasa/vim-ansible-vault'

" case-preserving search and replace
Plug 'tpope/vim-abolish'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EYE-CANDY PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" colorscheme/theme
Plug 'gruvbox-community/gruvbox'

" show number of search matches
Plug 'henrik/vim-indexed-search'

" modify tab bar
Plug 'gcmt/taboo.vim'
let g:taboo_tab_format="  %f  "

" colorized indentation
Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_indent_levels = 12
let g:indent_guides_guide_size = 2
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 1
autocmd VimEnter,Colorscheme,BufEnter * :hi IndentGuidesOdd  guibg=NONE ctermbg=NONE
autocmd VimEnter,Colorscheme,BufEnter * :hi IndentGuidesEven guibg=#303030 ctermbg=4

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SMALL PLUGINS TO FIX SHITTY OUT-OF-THE-BOX VIM EXPERIENCE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" faster folding via not updating the folds too often
Plug 'Konfekt/FastFold'
" fastfold required:
set sessionoptions-=folds

" helpers for unix (:Gmove, ...)
Plug 'tpope/vim-eunuch'

" sudo write support
Plug 'lambdalisue/suda.vim'

" :Bd[elete] command
Plug 'moll/vim-bbye'

" change between paste and editing modes automatically
Plug 'roxma/vim-paste-easy'

" hide annoying swap dialogues
Plug 'gioele/vim-autoswap'

" repeat more things with .
Plug 'tpope/vim-repeat'

" use automatically detected indentation of opened file
Plug 'roryokane/detectindent'
augroup DetectIndent
  autocmd!
  let blacklist = ['go']
  autocmd BufReadPost if index(blacklist, &ft) < 0 | DetectIndent
augroup END

" cyrillic localization hacks [russian language]
Plug 'lyokha/vim-xkbswitch'
if $DISPLAY == ""
	let g:XkbSwitchEnabled = 0
else
  set keymap=russian-jcukenwin
  set iminsert=0
  set imsearch=0
	let g:XkbSwitchEnabled = 1
  " set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
	" let g:XkbSwitchIMappings = ['ru']
  " let g:XkbSwitchNLayout = 'us'
  " let g:XkbSwitchAssistNKeymap = 1    " for commands r and f
  " let g:XkbSwitchAssistSKeymap = 1    " for search lines
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SYNTAX/INDENT/FOLDING PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" NOTE: Blacklist in polyglot overriden with specific plugins languages
" big collection of syntax files

let g:polyglot_disabled = []
if has('nvim-0.5.1')
  " experimental syntax highlighting
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
else
  Plug 'sheerun/vim-polyglot'
  " changing filetype to yaml.ansible breaks coc-yaml
  let g:polyglot_disabled += ['ansible']

  " better lua indentation/syntax (at least it was in ~2015?)
  Plug 'raymond-w-ko/vim-lua-indent'
  let g:polyglot_disabled += ['lua']

  " python indentation
  Plug 'Vimjas/vim-python-pep8-indent'
  let g:polyglot_disabled += ['python']
endif

" latex editing package
Plug 'lervag/vimtex'
let g:tex_flavor = 'latex'
let g:polyglot_disabled += ['latex']

" json package
Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal=1
let g:polyglot_disabled += ['json']

" python folding
Plug 'tmhedberg/SimpylFold'
" python 3 better syntax highlightning + refactoring capabilities
" does not support python 2 or python < 3.5
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
let g:polyglot_disabled += ['python']

" .editorconfig integration
Plug 'editorconfig/editorconfig-vim'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" POST-PLUGIN TASKS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" now after defining plugins let plugin manager do the job
call plug#end()

" jumping with % for xml tags
runtime macros/matchit.vim

" more denite configuration
call denite#custom#var('file/rec', 'command', ['rg', '--files'])
call denite#custom#source('file/rec', 'matchers', ['matcher/substring',
      \ 'matcher/ignore_current_buffer'])

call denite#custom#alias('source', 'file/rec/hidden', 'file/rec')
call denite#custom#var('file/rec/hidden', 'command', ['rg', '--files', '--hidden'])
call denite#custom#source('file/rec/hidden', 'matchers', ['matcher/substring',
      \ 'matcher/ignore_current_buffer'])

call denite#custom#source('buffer', 'matchers', ['matcher/substring'])
" Change ignore_globs (they have to be enabled in matchers still)
let s:denite_options = {
     \ 'prompt' : '>',
     \ 'split': 'floating',
     \ 'start_filter': 1,
     \ 'smartcase': 1,
     \ 'auto_resize': 1,
     \ 'source_names': 'short',
     \ 'highlight_filter_background': 'CursorLine',
     \ 'highlight_matched_char': 'Question',
     \ }
call denite#custom#option('default', s:denite_options)

" treesitter
if has('nvim-0.5.1')
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
}
EOF
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLORSCHEME SETUP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" detect terminal capabilities and set colorscheme
function! SetColorScheme(colors, ...)
  " first arg: gui, 256, or tty
  " second optional arg: background (default = dark)
  if a:colors == '256' || a:colors == 'gui'
    " set t_8f=[38;2;%lu;%lu;%lum
    " set t_8b=[48;2;%lu;%lu;%lum
    " let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    set termguicolors
    execute 'colorscheme gruvbox'
  elseif a:colors == 'tty'
    execute 'colorscheme desert'
  endif

  if exists('a:1')
    let &background = a:1
  else
    set background=dark
  endif
endfunction

if IsTerm256Colors()
  try
    call SetColorScheme('256')
  catch
    call AddUnavailMsg('Terminal colorscheme')
    call SetColorScheme('tty')
  endtry
else
  call SetColorScheme('tty')
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" language (let it be in the beginning)
language en_US.utf8
set langmenu=none
set encoding=utf-8

filetype plugin indent on
syntax on
set hidden

" redraw only when we need to
set lazyredraw
" coc.nvim requires lower value of this to show diagnostics faster on cursorhold
set updatetime=300

" to avoid error "pattern uses more memory than 'maxmempattern'" on big files
set mmp=10000

" cursor always in the center
set scrolloff=999

" indentation
set expandtab
set tabstop=2
set shiftwidth=2
" round indentation to 'shiftwidth'
set shiftround
" Simple indentation method: continue from the same indent as previous line.
" Should not interfere with filetype-based indentation, unlike other methods
set autoindent
" set cindent
" set cinoptions+=(0

set ignorecase
set smartcase

" show a dialog (y/n) instead of failing on some actions
set confirm
" hide intro message on start
set shortmess+=I

set undofile
" make backup on :w, needed to avoid possible lose of data if vim crashes on :w
set backup
" don't change inode on save, helps with docker mounts not detecting file changes
set backupcopy=yes
" configure how much of history, marks, registers, etc can be remembered
set shada=!,'100,<200,s100,h
" don't same some things in :mksession
set sessionoptions-=blank,options

" cyrillic localization hacks [russian language]
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=-1
" set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EYE-CANDY SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" show effects of some commands (e.g. substitute) in real-time
set inccommand=nosplit

" highlight matching [{()}]
set showmatch

" statusline
set statusline=%m%H%W%q\ %{expand('%:~')}%<%=\ [%{&ft},\ %{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %p%%\ %l-%L
" always show status bar
set laststatus=2

" highlight columns
set colorcolumn=120
autocmd BufWinEnter * highlight ColorColumn ctermbg=8 ctermfg=none cterm=none

" highlight trailing white space
autocmd BufWinEnter * highlight default link TrailingWhiteSpace Tabline
autocmd BufWinEnter * match TrailingWhiteSpace /\s\+$/
" don't highlight trailing whitespace in Insert mode
autocmd InsertEnter * match TrailingWhiteSpace /\s\+\%#\@<!$/
autocmd InsertLeave * match TrailingWhiteSpace /\s\+$/

set foldmethod=manual

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LANGUAGE-SPECIFIC SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" DSLs
autocmd FileType yaml setlocal indentexpr=""
autocmd FileType make setlocal noexpandtab softtabstop=0

" text
" enable spelling for text files
autocmd FileType markdown,text,tex,rst setlocal spell spelllang=en,ru

" python
" standard syntax highlighting configuration
let python_highlight_all = 1
autocmd FileType python setlocal tabstop=2
autocmd FileType python setlocal shiftwidth=2
" python debuggers
autocmd FileType python nmap <buffer> <leader>b Ofrom IPython.terminal import debugger; debugger.set_trace()<C-[>
autocmd FileType python nmap <buffer> <leader>B Oimport pudb; pudb.set_trace()<C-[>

" ruby debugger
autocmd FileType ruby nmap <buffer> <leader>b Orequire 'pry-byebug'; binding.pry<C-[>

" js debugger
autocmd FileType javascript nmap <buffer> <leader>b Odebugger;<C-[>

" c/cpp debugger
autocmd FileType c,cpp nmap <buffer> <leader>b Oraise(SIGTRAP);<C-[>

" php debugger
autocmd FileType php nmap <buffer> <leader>b Orequire('/bin/psysh'); eval(\Psy\sh());<C-[>

" go
" debugger
autocmd FileType go nmap <buffer> <leader>b Oruntime.Breakpoint()<C-[>
" autoimports
autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCOMMANDS, UNRELATED TO EVERYTHING ELSE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" restore cursor position on file open
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
    \ exe "normal! g`\"" | endif

" vimdiff auto diffupdate
augroup AutoDiffUpdate
  au!
  autocmd InsertLeave * if &diff | diffupdate | let b:old_changedtick = b:changedtick | endif
  autocmd TextChanged *
        \ if &diff &&
        \    (!exists('b:old_changedtick') || b:old_changedtick != b:changedtick) |
        \   let b:old_changedtick = b:changedtick | diffupdate |
        \ endif
augroup END

" autoadjust quickfix window size
au FileType qf call AdjustWindowHeight(3, 10)
function! AdjustWindowHeight(minheight, maxheight)
    let l = 1
    let n_lines = 0
    let w_width = winwidth(0)
    while l <= line('$')
        " number to float for division
        let l_len = strlen(getline(l)) + 0.0
        let line_width = l_len/w_width
        let n_lines += float2nr(ceil(line_width))
        let l += 1
    endw
    exe max([min([n_lines, a:maxheight]), a:minheight]) . "wincmd _"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM COMMANDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" save with sudo
command! W execute ':w suda://%'
" open with sudo
command! E execute ':e suda://%'

" edit config files
command! Rv execute 'source ' . g:path#vimrc
command! Ev execute 'edit ' . g:path#vimrc

" enable autosaving of current file
command! EnableAutosave autocmd TextChanged,InsertLeave <buffer> silent! update

" remove unneeded spaces
command! RemoveTrailingSpaces silent! %s/\s\+$//g

" easy loading of Session.vim in current dir
command! LoadSession call LoadSession()
function! LoadSession()
  let l:pwd = getcwd()
  execute 'source ' . l:pwd . '/Session.vim'
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" expand split to full screen
nnoremap \| <C-W>\|<C-W>_
" restore split size
nnoremap + <C-W>=

" clear highlighting
nnoremap <leader>h :nohl<CR>

" replace last yanked string with ...
nnoremap <leader>rf :%s/<C-R>"//gc<Left><Left><Left>

" workaround to leave insert mode in terminal on ESC
tnoremap <Esc> <C-\><C-n>

function! DeleteHiddenBuffers()
  let tpbl=[]
  let closed = 0
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    if getbufvar(buf, '&mod') == 0
      silent execute 'bwipeout' buf
      let closed += 1
    endif
  endfor
  echo "Closed ".closed." hidden buffers"
endfunction
command! DeleteHiddenBuffers call DeleteHiddenBuffers()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" POST-EVERYTHING
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" print all collected user messages from this script (see HELPER FUNCTIONS)
call SendMessages()
