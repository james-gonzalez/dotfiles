local ensure_installed = {
  -- JavaScript
  "javascript",
  "json",
  "typescript",
  "tsx",
  "astro",

  -- Other web dev
  "css",
  "html",
  "regex",

  -- Go
  "go",
  "gomod",
  "gowork",
  "gosum",

  -- Neovim
  "lua",
  "luadoc",
  "query",
  "vim",
  "vimdoc",

  -- Config
  "toml",
  "yaml",

  -- Docs
  "markdown",
  "markdown_inline",

  -- git
  "diff",
  "gitignore",

  -- Shell
  "bash",
  "tmux",

  -- Other
  "supercollider",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = ensure_installed,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        incremental_selection = { enable = true },
        indent = { enable = true },
      }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "javascriptreact", "typescriptreact" },
    opts = {},
  },
}
