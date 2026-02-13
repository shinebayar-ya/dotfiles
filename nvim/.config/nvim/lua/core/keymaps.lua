-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

-- Map <leader>r to compile and run C++
keymap.set('n', '<leader>r', [[:w<CR>:!g++ -Wall -Wextra -std=c++17 -o %< % && ./%< <CR>]], { noremap = true })

-- Map <leader>i to compile and run C++ with input file
keymap.set('n', '<leader>i', [[:w<CR>:!g++ -Wall -Wextra -std=c++17 -o %< % && ./%< < in <CR>]], { noremap = true })

-- parenthesis in insert mode
keymap.set('i', '{', '{}<Left><CR><ESC>ko', { desc = 'double parenthesis' })

-- use jk to exit insert mode
keymap.set('i', 'jk', '<ESC>', { desc = 'Exit insert mode with jk' })

-- clear search highlights
keymap.set('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights' })

keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save it' })
keymap.set('n', '<leader>q', ':wq<CR>', { desc = 'Save it and Exit.' })

-- Do not yank with x
keymap.set('n', 'x', '"_x')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Delete a word backwards
keymap.set('n', 'dw', 'vb"_d')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G') 

-- New tab
keymap.set('n', 'te', ':tabedit<Return>', { silent = true })
 
-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w', { silent = true })
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { silent = true })

-- Move window
keymap.set('n', '<Space>', '<C-w>w')
keymap.set('n', 's<left>', '<C-w>h')
keymap.set('n', 's<up>', '<C-w>k')
keymap.set('n', 's<down>', '<C-w>j')
keymap.set('n', 's<right>', '<C-w>l')
keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sl', '<C-w>l')
