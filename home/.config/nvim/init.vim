""" Main Configurations
filetype plugin indent on
set encoding=utf-8
set fileencoding=utf-8
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
set incsearch ignorecase smartcase hlsearch
set wildmode=longest,list,full wildmenu
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set ruler laststatus=2 showcmd showmode
" set list listchars=trail: ,tab: -
" set list listchars=eol:~,tab:>.,trail:~,extends:>,precedes:<,space:_
" set list listchars=trail:•,extends:>,precedes:<
set showbreak=↪\ 
set list
" set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set listchars=tab:\|\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set fillchars+=vert:\|
set wrap breakindent
set textwidth=0
set hidden
set background=dark
" Show Fileline numbers
" set number
set title

" Show `` in markdown files
set conceallevel=0

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

""" Remapping of Record Mode
nnoremap <C-q> q
nmap q <Nop>

