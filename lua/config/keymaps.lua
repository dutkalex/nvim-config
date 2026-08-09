-- Global keymaps (all file types, no plugin needed)

-- Shift selection
vim.keymap.set("n", "<S-Up>",    "v<Up>",    { silent = true })
vim.keymap.set("n", "<S-Down>",  "v<Down>",  { silent = true })
vim.keymap.set("n", "<S-Left>",  "v<Left>",  { silent = true })
vim.keymap.set("n", "<S-Right>", "v<Right>", { silent = true })

vim.keymap.set("v", "<S-Up>",    "<Up>",    { silent = true })
vim.keymap.set("v", "<S-Down>",  "<Down>",  { silent = true })
vim.keymap.set("v", "<S-Left>",  "<Left>",  { silent = true })
vim.keymap.set("v", "<S-Right>", "<Right>", { silent = true })

vim.keymap.set("i", "<S-Up>",    "<Esc>v<Up>",    { silent = true })
vim.keymap.set("i", "<S-Down>",  "<Esc>v<Down>",  { silent = true })
vim.keymap.set("i", "<S-Left>",  "<Esc>v<Left>",  { silent = true })
vim.keymap.set("i", "<S-Right>", "<Esc>v<Right>", { silent = true })

-- Fast navigation with Alt+Arrows
vim.keymap.set("n", "<A-Up>", ":-10<CR>")
vim.keymap.set("n", "<A-Down>", ":+10<CR>")
vim.keymap.set("n", "<A-Left>", "b")
vim.keymap.set("n", "<A-Right>", "w")

vim.keymap.set("n", "<C-A-Up>", "gg")
vim.keymap.set("n", "<C-A-Down>", "G")
vim.keymap.set("n", "<C-A-Left>", "^")
vim.keymap.set("n", "<C-A-Right>", "$")

-- Alt line moves
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")

vim.keymap.set("n", "<S-A-Up>", ":m-2<CR>")
vim.keymap.set("n", "<S-A-Down>", ":m+1<CR>")

-- Tab indents
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")
