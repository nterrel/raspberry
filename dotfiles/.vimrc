" --- Some configurations for my tiny vim installation ---

" --- sane defaults ---
set nocompatible
set encoding=utf-8
set hidden
set backspace=indent,eol,start
set clipboard=unnamedplus    " harmless if unsupported

" --- UI ---
set ruler
set showcmd
set laststatus=2
set wildmenu
set wildmode=longest:full,full
set incsearch
set hlsearch
set ignorecase
set smartcase

" --- filetype ---
filetype plugin indent on

" --- indentation ---
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" --- quality of life ---
set nowrap
set scrolloff=3
set sidescrolloff=5
set noerrorbells
set visualbell
set ttimeoutlen=50

" Quick toggle search highlight with <F3>
nnoremap <F3> :set hlsearch!<CR>

" Make Y behave like D/C (yank to end of line)
nnoremap Y y$

" Set indention tabs to display dot character
" set list
" set listchars=tab:▸\ ,trail:·
