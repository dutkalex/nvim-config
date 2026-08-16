local gitsigns = require("gitsigns")

-- Returns the lines of the output of git blame --line-porcelain
local raw_blame_output = function(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return nil
  end

  local result = vim.system(
    { "git", "blame", "--line-porcelain", "--", file },
    { text = true, cwd = vim.fs.dirname(file) }
  ):wait()

  if result.code ~= 0 then
    return nil
  end

  return vim.split(result.stdout, "\n", { plain = true })
end

-- Starts reading the blame output at line i and returns the hunk info with the offset for the next call
local next_hunk = function(blame_output_lines, i)
  local hunk = {
    commit = nil,
    author = nil,
    line_count = nil,
  }

  -- Read blame info of the first line of code
  while i <= #blame_output_lines do
    local line = blame_output_lines[i]
    i = i + 1

    if line:sub(1, 1) == "\t" then
      break
    end

    local sha = line:match("^([0-9a-f]+) %d+ %d+")
    if sha then
      hunk.commit = sha
    end

    local author = line:match("^author (.+)$")
    if author then
      hunk.author = author
    end

    hunk.line_count = 1
  end

  -- Read next lines until a different commit is found
  while i <= #blame_output_lines do
    local line = blame_output_lines[i]

    local sha = line:match("^([0-9a-f]+) %d+ %d+")
    if sha and sha ~= hunk.commit then
      break
    end

    if line:sub(1, 1) == "\t" then
      hunk.line_count = hunk.line_count + 1
    end

    i = i + 1
  end

  return hunk, i
end

local blame_hunks = function(bufnr)
  local blame_output_lines = raw_blame_output(bufnr)
  if not blame_output_lines then
    return nil
  end

  local hunks = {}
  local i = 1
  local buffer_line = 0

  while i <= #blame_output_lines do
    local hunk, new_i = next_hunk(blame_output_lines, i)
    table.insert(hunks, {
      first = buffer_line,
      last = buffer_line + hunk.line_count - 1,
      sha = hunk.commit,
      author = hunk.author or hunk.commit:sub(1, 8),
    })
    buffer_line = buffer_line + hunk.line_count
    i = new_i
  end

  return hunks
end

local ns = vim.api.nvim_create_namespace("git_blame")
local blame_enabled = false

local show_blame_view = function(bufnr)
  if blame_enabled then
    vim.notify("Blame hunks already activated", vim.log.levels.INFO)
    return
  end

  local hunks = blame_hunks(bufnr)
  if not hunks then
    vim.notify("Blame hunks reconstruction failed", vim.log.levels.INFO)
    return
  end

  for _, hunk in ipairs(hunks) do
    local mark = function(line, text)
      vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
        virt_text = {
          { text, "GitSignsCurrentLineBlame" },
        },
        virt_text_pos = "overlay",
        virt_text_win_col = vim.api.nvim_win_get_width(0) - 40,
        hl_mode = "combine",
      })
    end

    if hunk.first == hunk.last then
      mark(hunk.first, "── " .. hunk.author)
    else
      mark(hunk.first, "╭─ " .. hunk.author)

      for line = hunk.first + 1, hunk.last - 1 do
        mark(line, "│")
      end

      mark(hunk.last, "╰─ ")
    end
  end

  blame_enabled = true
end

local hide_blame_view = function(bufnr)
  if blame_enabled then
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    blame_enabled = false
  end
end

local toggle_blame = function()
  if blame_enabled then
    hide_blame_view(vim.api.nvim_get_current_buf())
  else
    show_blame_view(vim.api.nvim_get_current_buf())
  end

  gitsigns.toggle_current_line_blame()
end

return {
  next_hunk = gitsigns.next_hunk,
  prev_hunk = gitsigns.prev_hunk,
  preview_hunk_inline = gitsigns.preview_hunk_inline,
  stage_hunk = gitsigns.stage_hunk,
  reset_hunk = gitsigns.reset_hunk,
  toggle_blame = toggle_blame,
}
