# Neovim tutorials

## Introduction to Neovim

Welcome to Neovim editor...

## Basic navigation

- Open and close files.
- Navigation commands like moving the cursor and jumping to specific lines.

## Editing text

- Editing commands like inserting text, deleting characters/lines, copying, cutting and pasting.

- Modes in Neovim
  - Insert
  - Visual
  - Normal

## Searching and Replacing

Search for text within a file and navigate search result
Replace operations

## Multiple Buffers and Windows

Work with multiple files using buffers and split windows.
Manage multiple open files.

## Configuration

### Create `init.lua` config file

    mkdir nvim
    cd nvim
    touch init.lua

### Basic configuration

    local opt = vim.opt

    -- line numbers
    opt.relativenumber = true -- show relative line numbers
    opt.number = true -- shows absolute line number on cursor line (when relative number is on)
    ...

### Key Mappings

    -- set leader key to space
    vim.g.mapleader = " "

    local keymap = vim.keymap
    -- use jk to exit insert mode
    keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

    -- clear search highlights
    keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

### Plugin Management

Using lazy.nvim plugin manager

    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
    end
    vim.opt.rtp:prepend(lazypath)

### Theme and Colorscheme

Set Gruvbox theme.

### Status Line and Bufferline

Customize the status line and buffer line with plugins like 'lualine' and 'bufferline'.

### File Explorer

`nvim-tree` or `NERDTree`

### LSP (Language Server Protocol)

### Autocompletion and Snippets

`nvim-cmp` or `coc.nvim`

Customize Neovim's appearance, plugins, and mappings.

## Help for Comptetitive Programmers

### To compile and run C++ code

    local keymap = vim.keymap

    -- Map <F8> to compile and run C++ code
    keymap.set('n', '<F8>', [[:w<CR>:!g++ -Wall -Wextra -std=c++17 -o %< % && ./%< <CR>]], { noremap = true})

    -- Map <F9> to compile and run C++ code with input file
    keymap.set('n', '<F9>', [[:w<CR>:!g++ -Wall -Wextra -std=c++17 -o %< % && ./%< < in <CR>]], { noremap = true})

### Using template file

    vim.cmd([[autocmd BufNewFile *.cpp 0r ~/.config/nvim/templates/template.cpp | $d]])
    vim.cmd([[autocmd BufNewFile *.cc 0r ~/.config/nvim/templates/template.cc | $d]])
    vim.cmd([[autocmd BufNewFile *.c 0r ~/.config/nvim/templates/template.c | $d]])
