""""""""""""""""""""""""""""""""""""""""
" FUNCTIONS
""""""""""""""""""""""""""""""""""""""""
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

" function! s:WipeBuffersWithoutFiles()
"     let bufs=filter(range(1, bufnr('$')), 'bufexists(v:val) && '.
"                                           \'empty(getbufvar(v:val, "&buftype")) && '.
"                                           \'!filereadable(bufname(v:val))')
"     if !empty(bufs)
"         execute 'bwipeout' join(bufs)
"     endif
" endfunction
" command! BufClean call s:WipeBuffersWithoutFiles()

"function! SetCompletion(completer)
"  if a:complete ==? 'ycm'
"    nnoremap <F5> :call LanguageClient_contextMenu()<CR>
"    " Or map each action separately
"    nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
"    nnoremap <silent> gd <CR>
"    nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
"    autocmd FileType           nnoremap <buffer> <C-]> :YcmCompleter GoTo<CR>
"    autocmd FileType javascript nnoremap <buffer> <C-]> :TernDef<CR>
"    " nmap <leader>d :YcmCompleter GoToDeclaration<CR>
"    nnoremap <buffer> <leader>d :YcmCompleter GoTo<CR>
"    nnoremap <buffer> <leader>D :YcmCompleter GoToDefinition<CR>
"    nnoremap <buffer> <leader>* :YcmCompleter GoToReferences<CR>
"    nnoremap <buffer> <leader>k :YcmCompleter GetDoc<CR>
"    nnoremap <buffer> <leader>K :YcmCompleter GetType<CR>
"  elseif a:complete ==? 'deoplete'
"    nnoremap <buffer> <leader>d :YcmCompleter GoTo<CR>
"    nnoremap <buffer> <leader>D :call LanguageClient#textDocument_definition()<CR>
"    nnoremap <buffer> <leader>* :YcmCompleter GoToReferences<CR>
"    nnoremap <buffer> <leader>k :YcmCompleter GetDoc<CR>
"    nnoremap <buffer> <leader>K :YcmCompleter GetType<CR>
"  endif
"endfunction


""""""""""""""""""""""""""""""""""""""""
" VARS
""""""""""""""""""""""""""""""""""""""""

if has('nvim')
  let g:path#vim_user_dir = expand('~/.config/nvim')
  let g:path#vimrc = expand('~/.config/nvim/init.vim')
else
  let g:path#vim_user_dir = expand('~/.vim')
  let g:path#vimrc = expand('~/.vimrc')
endif


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
Plug 'bititanb/gruvbox'
let g:gruvbox_contrast_dark='none'
" let g:gruvbox_italic=1
function! SetColorScheme(colors, ...)
  " first arg: gui, 256, or tty
  " second optional arg: background (default = dark)

  if a:colors == '256' || a:colors == 'gui'
    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    set termguicolors

    execute 'colorscheme gruvbox'
    " autocmd BufEnter * highlight Normal guibg=0
  elseif a:colors == 'tty'
    execute 'colorscheme desert'
  endif

  if exists('a:1')
    let &background = a:1
  else
    set background=dark
  endif
endfunction

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

"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
"" (Optional) Multi-entry selection UI.
"Plug 'junegunn/fzf'
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"let g:deoplete#custom_blacklist = ['ruby']
"autocmd BufWritePre * if index(g:deoplete#custom_blacklist, &ft) < 0 |
"      \ call deoplete#custom#buffer_option('auto_complete', v:false)
"let g:LanguageClient_serverCommands = {
"    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
"    \ 'javascript': ['javascript-typescript-stdio'],
"    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
"    \ }

" Plug 'osyo-manga/vim-monster'
" let g:monster#completion#backend = 'solargraph'

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --all' }
let g:ycm_confirm_extra_conf = 0
" let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']
let g:ycm_show_diagnostics_ui = 0
let g:ycm_max_num_candidates = 100
let g:ycm_complete_in_comments = 1
let g:ycm_python_binary_path = 'python3'
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_semantic_triggers =  {
  \ 'css'        : [ 're!^\s{1,6}', 're!:\s+' ],
  \ 'scss'       : [ 're!^\s{1,6}', 're!:\s+' ],
  \ 'c'          : ['->', '.'],
  \ 'objc'       : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s', 're!\[.*\]\s'],
  \ 'ocaml'      : ['.', '#'],
  \ 'cpp,objcpp' : ['->', '.', '::'],
  \ 'perl'       : ['->'],
  \ 'php'        : ['->', '::'],
  \ 'ruby'       : ['.', '::'],
  \ 'lua'        : ['.', ':'],
  \ 'erlang'     : [':'],
  \ 'python'     : ['re!(import\s+|from\s+(\w+\s+(import\s+(\w+,\s+)*)?)?)'],
  \ 'cs,java,javascript,typescript,d,perl6,scala,vb,elixir,go,groovy' : ['.'],
  \ }
autocmd FileType scss setlocal omnifunc=csscomplete#CompleteCSS
let g:ycm_filetype_specific_completion_to_disable = {
      \ 'lua' : 1,
      \ 'vimwiki' : 1,
      \ 'groovy' : 1,
      \}
" let g:ycm_filetype_whitelist = {
" 			\ "c":1,
" 			\ "cpp":1,
" 			\ "objc":1,
" 			\ "sh":1,
" 			\ "zsh":1,
" 			\ "zimbu":1,
" 			\ "python":1,
" 			\ }
nnoremap <leader>d :YcmCompleter GoTo<CR>
nnoremap <leader>D :YcmCompleter GoToDefinition<CR>
nnoremap <leader>* :YcmCompleter GoToReferences<CR>
nnoremap <leader>k :YcmCompleter GetDoc<CR>
nnoremap <leader>K :YcmCompleter GetType<CR>
"let g:ycm_filetype_blacklist = { 'ruby': 1 }

" Plug 'artur-shaik/vim-javacomplete2'
" autocmd FileType groovy setlocal omnifunc=javacomplete#Complete

"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
"" (Optional) Multi-entry selection UI.
"Plug 'junegunn/fzf'
"autocmd Filetype ruby set completefunc=LanguageClient#complete

Plug 'w0rp/ale'
      " \ 'cpp'        : ['clangtidy', 'cpplint'],
let g:ale_linters = {
      \ 'c'          : ['clangtidy'],
      \ 'javascript' : ['eslint'],
      \ 'python'     : ['flake8'],
      \ 'chef'       : [''],
      \ }
let g:ale_python_pylint_options = '-d C0103,C0111,C0321'
let g:ale_python_flake8_options =  '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,E702,E501'
let g:ale_cpp_clangcheck_options = '-extra-arg="-std=c++11"'
let g:ale_cpp_clangtidy_options = '-std=c++11'
" let g:ale_cpp_clangtidy_checks = []
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '%s       %severity% | %linter% | %code%'
" let g:ale_echo_msg_format = "%linter% %s"
let g:ale_cpp_cpplint_options = '--linelength=120 --filter=-readability/todo,-whitespace/operators'
let g:ale_python_flake8_options = '--ignore=E303,E121,E123,E126,E226,E24,E704,W503,W504,E501 --max-line-length=120'
let g:ale_ruby_rubocop_options = '--except Layout/AlignParameters,Style/Documentation,Metrics/MethodLength,Style/GuardClause,Metrics/AbcSize,Naming/AccessorMethodName,Layout/MultilineMethodCallIndentation,Metrics/LineLength'
let g:ale_sh_shellcheck_exclusions = 'SC1090'
autocmd BufEnter PKGBUILD,.env
      \   let b:ale_sh_shellcheck_exclusions = 'SC2034,SC2154,SC2164'
" let g:ale_c_cppcheck_options = '--enable=style --suppress="unusedStructMember" --suppress="unreadVariable"'
nmap <silent> <leader>lp <Plug>(ale_previous_wrap)
nmap <silent> <leader>ln <Plug>(ale_next_wrap)

" Plug 'neomake/neomake'
" let g:neomake_vim_enabled_makers = []
" let g:neomake_open_list = 2

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = '<c-s>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-m>'

Plug 'mileszs/ack.vim'
let g:ackprg = 'ag --vimgrep'
" let g:ack_qhandler = "botright copen 3"
let g:ack_qhandler = "botright copen 10"
let g:ackpreview = 1
let g:ackhighlight = 1
nnoremap <leader>s :Ack!<Space>''<Left>

Plug 'yuttie/comfortable-motion.vim'
let g:comfortable_motion_air_drag = 13
let g:comfortable_motion_friction = 0.0
let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_impulse_multiplier = 3
nnoremap <silent> <C-d> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>
nnoremap <silent> <C-f> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 4)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -4)<CR>

" show changed lines for VCS
Plug 'mhinz/vim-signify'
" let g:signify_realtime = 1
let g:signify_realtime = 0

Plug 'majutsushi/tagbar'
let g:tagbar_compact = 1
nnoremap <leader>E :TagbarToggle<CR>
"autocmd FileType python nested :call tagbar#autoopen(0)

Plug 'bititanb/ranger.vim'
let g:ranger_map_keys = 0
" function! RangerOpen()
"   execute 'tabnew'
"   execute 'Ranger'
" endfunction
nmap <leader>e :Ranger<CR>

" " advanced matcher for denite
" Plug 'nixprime/cpsm', { 'do': 'PY3=ON ./install.sh' }
Plug 'Shougo/denite.nvim'
      " \ ['ag', "--ignore=/third_party/", "--ignore=/build/",
nnoremap <C-P> :ccl<CR>:Denite -smartcase file_rec<CR>
nnoremap <leader>p :ccl<CR>:Denite -smartcase buffer<CR>

Plug 'dhruvasagar/vim-table-mode'
let g:table_mode_corner='|'

Plug 'brooth/far.vim'
let g:far#preview_window_layout='right'
let g:far#window_layout='tab'
" let g:far#source="agnvim"
" let g:far#debug = 1
function! s:FarClear()
  let n = bufnr('$')
  while n > 0
    if getbufvar(n, '&ft') == 'far_vim'
      exe 'bd ' . n
    endif
    let n -= 1
  endwhile
endfun
command! FarClear call s:FarClear()

" only for 'sexy' multiline comments (<leader>cs)
" and usual multiline (<lead>cm) + some automatic stuff
Plug 'scrooloose/nerdcommenter'
let g:NERDSpaceDelims = 1
" For all the other comments
Plug 'tyru/caw.vim'
let g:caw_hatpos_skip_blank_line = 1
let g:caw_wrap_skip_blank_line = 1

" Plug 'Yggdroot/indentLine'
" let g:indentLine_char = '┊'
" let g:indentLine_concealcursor = ''
" Plug 'thaerkh/vim-indentguides'
Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_indent_levels = 12
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme,BufEnter * :hi IndentGuidesOdd  guibg=#303030 ctermbg=4
autocmd VimEnter,Colorscheme,BufEnter * :hi IndentGuidesEven guibg=#303030 ctermbg=4
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2

Plug 'roryokane/detectindent'
augroup DetectIndent
  autocmd!
  autocmd BufReadPost *  DetectIndent
augroup END

" quickfix window options
" Plug 'blueyed/vim-qf_resize'

" build from vim
" Plug 'tpope/vim-dispatch'
" nnoremap <leader>m :w \| Make

" Plug 'benmills/vimux'

Plug 'junegunn/vim-easy-align'
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
nmap <leader>a gaii

Plug 'lervag/vimtex'

" sudo
Plug 'lambdalisue/suda.vim'

" big collection of syntax files
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['lua']

" autoclose quotes, parens, brackets..
Plug 'ervandew/matchem'
" git commands
Plug 'tpope/vim-fugitive'
" show docs
Plug 'Shougo/echodoc.vim'
" command mode readline bindings
Plug 'vim-utils/vim-husk'
" replace quotes, parens, brackets...
Plug 'tpope/vim-surround'
" :Bdelete command
Plug 'moll/vim-bbye'
Plug 'will133/vim-dirdiff'
Plug 'roxma/vim-paste-easy'
Plug 'michaeljsmith/vim-indent-object'
Plug 'gioele/vim-autoswap'
Plug 'raymond-w-ko/vim-lua-indent'
" show number of search matches
Plug 'henrik/vim-indexed-search'
" helpers for unix (:Gmove, ...)
Plug 'tpope/vim-eunuch'

" encryption support
Plug 'jamessan/vim-gnupg'

Plug 'tpope/vim-repeat'

Plug 'modille/groovy.vim'

" change filetype for range of lines
Plug 'inkarkat/vim-ingo-library'
Plug 'inkarkat/vim-SyntaxRange'

Plug 'zainin/vim-mikrotik'

" Plug 'pseewald/vim-anyfold'
" let g:anyfold_activate=1
" let g:anyfold_fold_display=1
" let g:anyfold_fold_toplevel=1

" chef autofiletype
" Plug 'dougireton/vim-chef'

" diff on blocks of code
Plug 'AndrewRadev/linediff.vim'

Plug 'lyokha/vim-xkbswitch'
if $DISPLAY == ""
	let g:XkbSwitchEnabled = 0
else
  set keymap=russian-jcukenwin
  set iminsert=0
  set imsearch=0
  " set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
	let g:XkbSwitchEnabled = 1
	" let g:XkbSwitchIMappings = ['ru']
 "  let g:XkbSwitchNLayout = 'us'
  " let g:XkbSwitchAssistNKeymap = 1    " for commands r and f
  " let g:XkbSwitchAssistSKeymap = 1    " for search lines
endif

" Plug 'ierton/xkb-switch'

" Plug 'reedes/vim-lexical'
" augroup lexical
"   autocmd!
"   autocmd FileType *.md,markdown,mkd call lexical#init()
"   autocmd FileType textile call lexical#init()
"   autocmd FileType text call lexical#init()
" augroup END
" let g:lexical#spelllang = ['en_us','ru_ru',]

" modify tab bar
Plug 'gcmt/taboo.vim'
let g:taboo_tab_format="  %p%m  "

Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal=1

" colorize hex codes in code
Plug 'KabbAmine/vCoolor.vim'
" Plug 'ap/vim-css-color'
" Plug 'chrisbra/Colorizer'
" let g:colorizer_auto_color = 1

" Plug 'tbabej/taskwiki'
" Plug 'blindFS/vim-taskwarrior'
" Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
let g:vimwiki_hl_cb_checked = 1
" let g:taskwiki_sort_order='priority-,-status+,end+,due+,project+'
" let g:taskwiki_sort_orders={"T": "priority-"}
" " let wiki = {}
" " let wiki.path = '~/my_wiki/'
" " let wiki.nested_syntaxes = {'python': 'python', 'c++': 'cpp'}
" " let g:vimwiki_list = [wiki]

" jumping with % for xml tags
runtime macros/matchit.vim

call plug#end()

" call denite#custom#var('file_rec', 'command',
"       \ ['ag',
"       \ '--follow', '--nocolor', '--nogroup', '-g', ''])
call denite#custom#source(
      \ 'file_rec', 'matchers', ['matcher_substring'])
call denite#custom#source(
      \ 'buffer', 'matchers', ['matcher_substring'])

" call denite#custom#option('_', 'highlight_mode_insert', 'CursorLine')
" call denite#custom#option('_', 'highlight_matched_range', 'None')
" call denite#custom#option('_', 'highlight_matched_char', 'None')

" call neomake#configure#automake('rw', 1000)

""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""

" language (let it be in the beginning)
set langmenu=none
language en_US.utf8

filetype plugin indent on

" russian
" set keymap=russian-jcukenwin
" set iminsert=0
" set imsearch=-1
" set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

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
autocmd FileType make setlocal noexpandtab
autocmd FileType cbot setlocal noexpandtab
" autocmd BufEnter * silent! lcd %:p:h

" matchparen plugin (CARE it can slow vim TOO MUCH)
" when loaded_matchparen = 1 then the plugin is disabled
" let g:loaded_matchparen = 1
" let g:matchparen_timeout = 200
" let g:matchparen_insert_timeout = 200

" statusline
"set statusline=%t\ %<%m%H%W%q%=%{GetFileDirectory()}\ [%{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %l-%L\ %p%%
set statusline=%F\ %<%m%H%W%q%=\ [%{&ft},\ %{&ff},\ %{strlen(&fenc)?&fenc:'none'}]\ %p%%\ %l-%L
set laststatus=2        " always show status bar

" highlight
set showmatch           " highlight matching [{()}]
set hlsearch
set inccommand=nosplit
" WARN cursorline might slow vim down A LOT
"set cursorline
set colorcolumn=80
autocmd BufEnter * :highlight ColorColumn ctermbg=8 ctermfg=none cterm=none
autocmd BufEnter * :highlight StatusLineNC cterm=none term=none ctermbg=none ctermfg=0

" filetype detect
autocmd BufNewFile,BufRead *.cbot.txt,*.cb.txt :set filetype=cbot
autocmd BufNewFile,BufRead Dockerfile* :set filetype=dockerfile

" folds
" set foldcolumn=1        " Add a bit extra margin to the left
" set foldopen-=block
" set foldlevelstart=999
set foldlevel=1
set foldmethod=indent
set foldnestmax=2
set foldminlines=0
" HACK: disable folding in vimdiff
if &diff
  set diffopt=filler,context:1000000
endif
autocmd Filetype * setlocal nofoldenable

" colors
" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
if has('gui_running')
  try
    call SetColorScheme('gui')
  catch
    call AddUnavailMsg('Gui colorscheme')
    call SetColorScheme('tty')
  endtry

  try
    set guifont=monospace\ 12
  catch
    call AddUnavailMsg('Guifont')
    set guifont=DejaVu\ Sans\ Mono\ 12
  endtry
else
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
endif

" misc
" set iskeyword+=:,::,.
set encoding=utf-8
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
set viminfo='50,<100,s100,:30000,/1000,@1000,f1,h
set sessionoptions-=blank
set sessionoptions-=options
set shiftround          " round indentation
set backspace=indent,eol,start
set omnifunc=syntaxcomplete#Complete
setlocal shortmess+=I   " hide intro message on start
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.ropeproject/*
set wildignore+=Session.vim,*.pyc
set updatetime=2000
"set completeopt-=preview
let maplocalleader='\'

" gui
if has('gui_running')
  set guioptions-=m  "remove menu bar
  set guioptions-=T  "remove toolbar
  set guioptions-=r  "remove right-hand scroll bar
  set guioptions-=L  "remove left-hand scroll bar
  set guioptions+=c  "no graphical popup dialogs
endif

autocmd FileType markdown,text,tex setlocal spell spelllang=en,ru

autocmd FileType * syntax on
" autocmd Filetype * setlocal conceallevel=0
autocmd FileType * setlocal history=300
autocmd FileType * setlocal formatoptions-=t
autocmd FileType * setlocal formatoptions-=o
autocmd FileType * setlocal formatoptions-=r

" python
let python_highlight_all = 1
" autocmd Filetype python setlocal foldmethod=indent
" autocmd Filetype python setlocal foldlevel=1
" autocmd Filetype python setlocal foldminlines=15
" autocmd Filetype python setlocal foldnestmax=2
autocmd FileType python nmap <buffer> <leader>B Oimport pudb; pudb.set_trace()<C-[>
autocmd FileType python nmap <buffer> <leader>b Ofrom IPython.terminal import debugger; debugger.set_trace()<C-[>
autocmd FileType python setlocal tabstop=4
autocmd FileType python setlocal softtabstop=4
autocmd FileType python setlocal shiftwidth=4

" ruby
autocmd FileType ruby nmap <buffer> <leader>b Orequire 'pry-byebug'; binding.pry<C-[>

autocmd FileType javascript nmap <buffer> <leader>b Odebugger;<C-[>

autocmd FileType c,cpp nmap <buffer> <leader>b Oraise(SIGTRAP);<C-[>
autocmd FileType php nmap <buffer> <leader>b Orequire('/bin/psysh'); eval(\Psy\sh());<C-[>

autocmd FileType lua nmap <buffer>
      \ <leader>b Oif require("os").getenv("DISPLAY") ~= ":0.0"
      \ then require("debugger")() end<C-[>
      " \ then require("mobdebug").start() end<C-[>

" restore cursor position on file open
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
      \ exe "normal! g`\"" | endif

" delete trailing spaces
autocmd BufWritePre * call DeleteTrailingWS()

""""""""""""""""""""""""""""""""""""""""
" MAPPINGS, COMMANDS
""""""""""""""""""""""""""""""""""""""""

" :W save the file as root
" function! SudoSaveFile() abort
"   execute (has('gui_running') ? '' : 'silent') 'write !env SUDO_EDITOR=tee sudo -e % >/dev/null'
"   let &modified = v:shell_error
" endfunction
" cnoremap w!!! call SudoSaveFile()<CR>
" cnoremap W!!! w !sudo tee % > /dev/null

" edit config files
command! Rv execute 'source ' . g:path#vimrc
command! Ev execute 'edit ' . g:path#vimrc
command! Em execute 'edit ' . "~/.tmux.conf"
command! Ems execute 'edit ' . "~/.tmuxinator/default.yml"
command! Eb execute 'edit ' . "~/.bashrc"
command! Ep execute 'edit ' . "~/.profile"
command! Ex execute 'edit ' . "~/.Xresources"
command! Et execute 'edit ' . "~/.config/alacritty/alacritty.yml"
command! Es execute 'edit ' . "~/git/linux-utils/wmctrl-session-autostart.sh"
command! Est execute 'edit ' . "~/git/linux-utils/wmctrl-session-tmux.sh"
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
command! As autocmd TextChanged,InsertLeave <buffer> silent! update

" autosave markdown
autocmd TextChanged,InsertLeave *.md,markdown,*.tex,tex silent! update

" disable highlighting
nnoremap <leader>h :nohl<CR>

" remove unneeded spaces
nnoremap <leader>oc :s/\([[:graph:]]\+\)[ ]\{2,\}/\1 /g<CR>

" show linenumbers
nnoremap <leader>n :set number!<CR>

" replace last yanked string with ...
nnoremap <leader>r :%s/<C-R>"//gc<Left><Left><Left>

" leave insert mode in terminal
tnoremap <Esc> <C-\><C-n>

" " toggle folding for file
" nnoremap <leader>f :set foldenable!<CR>

" fast load session from current dir
function! LoadSession()
  let l:pwd = getcwd()
  execute 'source ' . l:pwd . '/Session.vim'
endfunction
command! Ls call LoadSession()

nnoremap <leader>me :call TermMake('')<Left><Left>
function! TermMake(build_command)
  let l:command = expand(a:build_command . " && wmctrl -s 3 && sleep 0.2 && xdotool key F5")
  let g:TermMake_last_build_command = l:command
  split
  enew
  call termopen(l:command)
  startinsert
endfunction

nnoremap <leader>ml :call TermMakeLast()<CR>
function! TermMakeLast()
  split
  enew
  call termopen(g:TermMake_last_build_command)
  startinsert
endfunction

" for chef
augroup chefftdetect
    au BufNewFile,BufRead */recipes/*.rb set filetype=ruby.chef
    au BufNewFile,BufRead */cookbooks/*.rb set filetype=ruby.chef
    au BufNewFile,BufRead */attributes/*.rb set filetype=ruby.chef
    au BufNewFile,BufRead */resources/*.rb set filetype=ruby.chef
    au BufNewFile,BufRead */test/*.rb set filetype=ruby.chef
    au BufNewFile,BufRead */spec/*.rb set filetype=ruby.chef
augroup end

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call SendMessages()
