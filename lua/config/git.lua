local gitsigns = require("gitsigns")
local utils = require("config.utils")

return {
  preview_hunk_inline = utils.if_not_oil(gitsigns.preview_hunk_inline),
  next_hunk = utils.if_not_oil(gitsigns.next_hunk),
  prev_hunk = utils.if_not_oil(gitsigns.prev_hunk),
  stage_hunk = utils.if_not_oil(gitsigns.stage_hunk),
  reset_hunk = utils.if_not_oil(gitsigns.reset_hunk),
  stage_buffer_hunks = utils.if_not_oil(gitsigns.stage_buffer),
  reset_buffer_hunks = utils.if_not_oil(gitsigns.reset_buffer),
}
