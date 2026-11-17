return {
  "prochri/telescope-all-recent.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "kkharji/sqlite.lua",
  },
  opts = {
    database = { max_timestamps = 10 },
    scoring = {
      recency_modifier = {
        [1] = { age = 240, value = 100 },
        [2] = { age = 1440, value = 80 },
        [3] = { age = 4320, value = 60 },
        [4] = { age = 10080, value = 40 },
        [5] = { age = 43200, value = 20 },
        [6] = { age = 129600, value = 10 },
      },
      boost_factor = 0.0001,
    },
    default = {
      disable = true,
      use_cwd = true,
      sorting = "frecency",
    },
    pickers = {
      find_files = {
        disable = false,
        use_cwd = true,
        sorting = "frecency",
      },
    },
  },
}
