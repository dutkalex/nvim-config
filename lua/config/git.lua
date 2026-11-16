local gitsigns = require("gitsigns")

return {
  next_hunk = gitsigns.next_hunk,
  prev_hunk = gitsigns.prev_hunk,
  preview_hunk_inline = gitsigns.preview_hunk_inline,
  stage_hunk = gitsigns.stage_hunk,
  stage_buffer_hunks = gitsigns.stage_buffer,
  reset_hunk = gitsigns.reset_hunk,
  reset_buffer_hunks = gitsigns.reset_buffer,
}
