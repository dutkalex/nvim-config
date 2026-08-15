local gitsigns = require("gitsigns")

local ns = vim.api.nvim_create_namespace("blame_rail")

local blame_hunks = function(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return {}
  end

  local result = vim.system({
    "git",
    "blame",
    "--line-porcelain",
    "--",
    file,
  }, {
    text = true,
    cwd = vim.fs.dirname(file),
  }):wait()

  if result.code ~= 0 then
    return {}
  end

  local hunks = {}
  local lines = vim.split(result.stdout, "\n", { plain = true })

  local i = 1
  local buffer_line = 0

  while i <= #lines do
    local sha = lines[i]:match("^([0-9a-f]+) %d+ %d+")
    if not sha then
      i = i + 1
      goto continue
    end

    i = i + 1

    local author

    -- Consume metadata until the source line.
    while i <= #lines do
      local line = lines[i]

      if line:sub(1, 1) == "\t" then
        break
      end

      author = line:match("^author (.+)$") or author
      i = i + 1
    end

    -- The line itself.
    if i <= #lines then
      i = i + 1
    end

    local previous = hunks[#hunks]

    if previous and previous.sha == sha then
      previous.last = buffer_line
    else
      table.insert(hunks, {
        first = buffer_line,
        last = buffer_line,
        sha = sha,
        author = author or sha:sub(1, 8),
      })
    end

    buffer_line = buffer_line + 1

    ::continue::
  end

  return hunks
end

local render = function(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for _, hunk in ipairs(blame_hunks(bufnr)) do
    local function mark(line, text)
      vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
        virt_text = {
          { text, "Comment" },
        },
        virt_text_pos = "overlay",
        virt_text_win_col = vim.api.nvim_win_get_width(0) - 40,
      })
    end

    if hunk.first == hunk.last then
      mark(hunk.first, "── " .. hunk.author)
    else
      mark(hunk.first, "╭─ " .. hunk.author)

      for line = hunk.first + 1, hunk.last - 1 do
        mark(line, "│")
      end

      mark(hunk.last, "╰")
    end
  end
end

local blame_enabled = true

local toggle_blame = function()
  gitsigns.toggle_current_line_blame()
  if blame_enabled then
    render(vim.api.nvim_get_current_buf())
  else
    vim.api.nvim_buf_clear_namespace(
      vim.api.nvim_get_current_buf(),
      ns,
      0,
      -1
    )
  end
  blame_enabled = not blame_enabled
end

return {
  next_hunk = gitsigns.next_hunk,
  prev_hunk = gitsigns.prev_hunk,
  preview_hunk_inline = gitsigns.preview_hunk_inline,
  stage_hunk = gitsigns.stage_hunk,
  reset_hunk = gitsigns.reset_hunk,
  toggle_blame = toggle_blame,
}
