return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    filetype = { "markdown", "markdown_inline" },
    heading = {
      backgrounds = {
        'RenderMarkdownH3Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH3Bg',
        'RenderMarkdownH3Bg',
      },
      -- Highlight for the heading and sign icons.
      -- Output is evaluated using the same logic as 'backgrounds'.
      foregrounds = {
        'RenderMarkdownH1',
        'RenderMarkdownH2',
        'RenderMarkdownH3',
        'RenderMarkdownH4',
        'RenderMarkdownH5',
        'RenderMarkdownH6',
      },
    },
  },
}
