return {
  {
    "opdavies/toggle-checkbox.nvim",
    keys = {
      {
        "<leader>tt",
        function()
          require("toggle-checkbox").toggle()
        end,
        desc = "Toggle checkbox",
      },
    },
  },
}
