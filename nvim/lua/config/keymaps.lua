local map = vim.keymap.set

local todo_state = {
  buf = nil,
  win = nil,
}

local function close_todo_float()
  if todo_state.win and vim.api.nvim_win_is_valid(todo_state.win) then
    vim.api.nvim_win_close(todo_state.win, true)
    todo_state.win = nil
  end
end

local function toggle_todo_float()
  if todo_state.win and vim.api.nvim_win_is_valid(todo_state.win) then
    close_todo_float()
    return
  end

  if not todo_state.buf or not vim.api.nvim_buf_is_valid(todo_state.buf) then
    todo_state.buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_name(todo_state.buf, "todo-float")
    vim.bo[todo_state.buf].buftype = "nofile"
    vim.bo[todo_state.buf].bufhidden = "hide"
    vim.bo[todo_state.buf].swapfile = false
    vim.bo[todo_state.buf].filetype = "markdown"

    vim.api.nvim_buf_set_lines(todo_state.buf, 0, -1, false, {
      "# TODO",
      "",
      "- [ ] finish this",
      "- [ ] add more tasks",
      "",
      "q or <leader>l to close",
    })

    vim.keymap.set("n", "q", close_todo_float, {
      buffer = todo_state.buf,
      silent = true,
      desc = "Close todo float",
    })

    vim.keymap.set("n", "<leader>l", close_todo_float, {
      buffer = todo_state.buf,
      silent = true,
      desc = "Close todo float",
    })
  end

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  todo_state.win = vim.api.nvim_open_win(todo_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Todo List ",
    title_pos = "center",
  })

  vim.wo[todo_state.win].number = false
  vim.wo[todo_state.win].relativenumber = false
  vim.wo[todo_state.win].cursorline = true
  vim.wo[todo_state.win].wrap = true
end

map("n", "<leader>t", ":split | term<CR>")
map("n", "<leader>T", ":vsplit | term<CR>")
map("n", "<leader>h", ":nohlsearch<CR>")
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>l", toggle_todo_float, { desc = "Toggle floating todo list" })
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })
map("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })

map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

map("n", "<C-j>", ":m .+1<CR>==")
map("n", "<C-k>", ":m .-2<CR>==")
map("v", "<C-j>", ":m '>+1<CR>==gv")
map("v", "<C-k>", ":m '<-2<CR>==gv")

map("n", "gb", "<C-o>", { desc = "Go back in jump list" })
map("n", "gf", "<C-i>", { desc = "Go forward in jump list" })
map("n", "%", "%", { desc = "Jump to matching bracket" })
map("n", "<leader>%", "%", { desc = "Jump to matching bracket" })
map("n", "<leader>r", ":e!<CR>")

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = args.buf })
  end,
})

vim.defer_fn(function()
  vim.keymap.set("n", "d", "\"dd", { noremap = true, desc = "Delete to d register" })
  vim.keymap.set("n", "D", "\"dD", { noremap = true, desc = "Delete line to d register" })
  vim.keymap.set("n", "c", "\"dc", { noremap = true, desc = "Change to d register" })
  vim.keymap.set("n", "C", "\"dC", { noremap = true, desc = "Change line to d register" })
  vim.keymap.set("n", "x", "\"dx", { noremap = true, desc = "Delete char to d register" })

  vim.keymap.set("v", "d", "\"dd", { noremap = true, desc = "Delete to d register" })
  vim.keymap.set("v", "c", "\"dc", { noremap = true, desc = "Change to d register" })
  vim.keymap.set("v", "x", "\"dx", { noremap = true, desc = "Delete to d register" })

  vim.keymap.set("n", "<leader>d", "\"dP", { noremap = true, desc = "Paste from d register" })
  vim.keymap.set("v", "<leader>d", "\"dp", { noremap = true, desc = "Paste from d register" })
end, 100)
