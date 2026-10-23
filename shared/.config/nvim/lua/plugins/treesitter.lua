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
  "terraform",
  "hcl",

  -- Python
  "python",

  -- Docs
  "markdown",
  "markdown_inline",

  -- git
  "diff",
  "gitignore",

  -- Shell
  "bash",

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
      require("nvim-treesitter").install(ensure_installed)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "javascriptreact", "typescriptreact" },
    opts = {},
  },
}
