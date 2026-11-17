local gitsigns = require("gitsigns")
local utils = require("config.utils")

local M = {}

---@brief Show the diff corresponding to the git hunk under the cursor
M.preview_hunk_inline = utils.if_not_oil(gitsigns.preview_hunk_inline)

---@brief Jump the cursor to the next git hunk
M.next_hunk = utils.if_not_oil(gitsigns.next_hunk)

---@brief Jump the cursor to thr previous git hunk
M.prev_hunk = utils.if_not_oil(gitsigns.prev_hunk)

---@brief Add the git hunk under the cursor to the staging area
M.stage_hunk = utils.if_not_oil(gitsigns.stage_hunk)

---@brief Remove the git hunk under the cursor from the staging area
M.reset_hunk = utils.if_not_oil(gitsigns.reset_hunk)

---@brief Add all the git hunks of the file to the staging area
M.stage_buffer_hunks = utils.if_not_oil(gitsigns.stage_buffer)

---@brief Remove all the git hunks of the file from the staging area
M.reset_buffer_hunks = utils.if_not_oil(gitsigns.reset_buffer)

return M
