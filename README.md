# dotfiles

Cross-platform dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/), themed with [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) across every tool.

## Structure

```
dotfiles/
├── Brewfile              # Homebrew packages, casks, and extensions
├── shared/               # Cross-platform configuration
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .gitignore_global
│   ├── .fzf.zsh
│   ├── .claude/
│   ├── .gemini/
│   └── .config/
│       ├── bat/          # Syntax-highlighted cat replacement
│       ├── delta/        # Git diff pager
│       ├── gh/           # GitHub CLI
│       ├── glow/         # Terminal markdown renderer
│       ├── lazygit/      # Git TUI
│       ├── mise/         # Polyglot runtime manager
│       ├── mprocs/       # Parallel process runner
│       ├── nvim/         # Neovim (Lazy.nvim, 21 plugins)
│       ├── ohmyposh/     # Prompt theme
│       ├── stormy/       # Weather CLI
│       ├── tmux/         # Terminal multiplexer
│       ├── yazi/         # Terminal file manager
│       └── zsh/          # 17 modular zsh config files
├── mac/                  # macOS-specific overrides
│   └── .config/
│       ├── btop/         # System monitor
│       ├── ghostty/      # Terminal emulator
│       └── tmux/         # macOS tmux keybindings
└── linux/                # Linux-specific overrides
    └── .config/
        └── tmux/         # Linux tmux keybindings
```

Stow creates symlinks from these directories into `$HOME`. Shared configs are deployed first, then OS-specific configs layer on top.

## Installation

### Prerequisites

- [Homebrew](https://brew.sh/) (macOS)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)

### macOS

```bash
git clone https://github.com/james-gonzalez/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle install
stow shared mac
```

### Linux

```bash
git clone https://github.com/james-gonzalez/dotfiles.git ~/dotfiles
cd ~/dotfiles
# Install stow via your package manager
stow shared linux
```

> Pairs well with [Omarchy](https://omarchy.org/) as a base.

## What's Inside

### Shell (Zsh)

[Zinit](https://github.com/zdharma-continuum/zinit) plugin manager with 17 modular config files under `.config/zsh/`:

| Module | Purpose |
|--------|---------|
| `fzf.zsh` | FZF config with Catppuccin colors and file previews |
| `plugins.zsh` | Plugin management with auto-install |
| `folders.zsh` | Quick navigation (`work`, `learn`, `play`, `cfg`) |
| `cd.zsh` | `...` through `.........` for parent directories |
| `yazi.zsh` | File manager wrapper that cds on exit |
| `nvim.zsh` | `nv` — open files with fzf preview |
| `cht.zsh` | Cheat sheet lookup via cht.sh |
| `grep.zsh` | `grep` aliased to `rg` |
| `terraform.zsh` | Terraform completions |
| `pnpm.zsh` | PNPM completions |

**Zinit plugins:** zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, forgit, cd-gitroot, fzf-tab, plus 11 Oh My Zsh snippets (git, brew, aws, kubectl, jump, autojump, etc.)

**Modern CLI replacements:**

| Traditional | Replacement |
|-------------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) |
| `cat` | [bat](https://github.com/sharkdp/bat) |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `find` | [fd](https://github.com/sharkdp/fd) |

### Neovim

Lazy.nvim with 21 plugins, based on Kickstart.nvim:

- **LSP** — Mason + lspconfig + fidget for progress
- **Completion** — Blink.cmp with fuzzy matching
- **Fuzzy finder** — fzf-lua for files, grep, LSP references, TODO comments
- **Formatting** — Conform.nvim
- **Linting** — nvim-lint
- **Treesitter** — vim, lua, html, css, terraform, go, python
- **Git** — Gitsigns (line blame, hunks)
- **UI** — Catppuccin, lualine, which-key, snacks, todo-comments
- **Editing** — autopairs, mini, dial, marks, guess-indent

**Leader:** `Space` | Arrow keys disabled (hjkl enforced)

### Tmux

Catppuccin theme with popup-driven workflows:

| Keybinding | Action |
|------------|--------|
| `<prefix>f` | Toggle floating scratch shell (persists across toggles) |
| `<prefix>g` | Lazygit popup |
| `<prefix>G` | GitHub Dash popup |
| `<prefix>m` | Create new session |
| `` <prefix>` `` | Switch session (fzf) |
| `<prefix>X` | Kill session (fzf) |
| `<prefix>!` | Quick popup shell |
| `<prefix>j` | Node REPL |
| `<prefix>o` | Lazydocker (macOS) |
| `<prefix>t` | btop monitor (macOS) |

**Plugins:** tpm, tmuxifier, tmux-sensible, vim-tmux-navigator, tmux-spotify, tmux-fuzzback, tmux-fzf-url

### Terminal (Ghostty — macOS)

- Catppuccin Mocha theme
- JetBrainsMono Nerd Font, 14pt
- Block cursor, non-blinking

### Prompt (Oh My Posh)

- Path with git repo name highlighted
- Git status (branch, working changes, staging, stash count)
- Execution time (right-aligned)
- Node version with package manager icon

### Git

- GPG commit signing enabled
- Delta as pager with Catppuccin theme
- Git LFS, interactive rebase tool
- SSH URL rewriting for personal repos

### Runtime Management (Mise)

| Category | Tools |
|----------|-------|
| Languages | Node (LTS), Python, Go, Rust |
| AI | gemini-cli, claude-code, mcp-hub |
| Infrastructure | terraform, terragrunt, aws-cli, aws-vault, rancher |
| Package managers | pnpm, yarn, uv |

### Brewfile

8 taps, 84 brews, 18 casks, 51 VSCode extensions, 4 Go tools — run `brew bundle install` to install everything.

## Secrets

API keys and tokens are stored in the **macOS Keychain**, not in dotfiles. The `~/.zsh_secrets` file (not tracked) reads from Keychain at shell startup:

```bash
# Add a secret
security add-generic-password -a "$USER" -s "KEY_NAME" -w "value" -U login.keychain-db

# Secrets are loaded automatically via ~/.zsh_secrets → sourced by .zshrc
```

## Updating

```bash
# Refresh Brewfile from current state
brew bundle dump --file=~/dotfiles/Brewfile --force --describe

# Update tmux plugins
# <prefix>I inside tmux

# Update Neovim plugins
# :Lazy update inside Neovim

# Update Zinit plugins
zinit update --all

# Update Mise runtimes
mise upgrade
```
