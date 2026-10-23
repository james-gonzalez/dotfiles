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
│       ├── nvim/         # Neovim (Kickstart-based, Lazy.nvim)
│       ├── ohmyposh/     # Prompt theme
│       ├── stormy/       # Weather CLI
│       ├── tmux/         # Terminal multiplexer
│       ├── yazi/         # Terminal file manager
├── mac/                  # macOS-specific overrides
│   └── .config/
│       ├── btop/         # System monitor
│       ├── ghostty/      # Terminal emulator
│       └── tmux/         # macOS tmux keybindings
└── linux/                # Linux-specific overrides
    └── .config/
        ├── hypr/         # Hyprland WM (bindings, monitors, look & feel, idle, lock)
        └── waybar/       # Status bar layout and styles
```

Stow creates symlinks from these directories into `$HOME`. Shared configs are deployed first, then OS-specific configs layer on top.

## Installation

### Prerequisites

- [Homebrew](https://brew.sh/) (macOS)
- [GNU Stow](https://www.gnu.org/software/stow/) (`brew install stow`)

### macOS

```bash
git clone https://github.com/james-gonzalez/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
brew bundle install
stow -t ~ shared mac
```

### Linux

```bash
git clone https://github.com/james-gonzalez/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
# Install stow via your package manager
stow -t ~ shared linux
```

> Pairs well with [Omarchy](https://omarchy.org/) as a base.

## What's Inside

### Shell (Zsh)

[Zinit](https://github.com/zdharma-continuum/zinit) plugin manager, configured entirely in `.zshrc`.

**Zinit plugins:** zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, forgit, cd-gitroot, plus Oh My Zsh snippets (git loaded eagerly; lxd, brew, aws, cp, git-auto-fetch, git-commit, jump, kubectl in turbo mode). Directory jumping via zoxide (`cd`).

**Modern CLI tools** (`ls`, `cat`, `tree` are aliased; `rg`/`fd` used directly):

| Traditional | Replacement |
|-------------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) |
| `cat` | [bat](https://github.com/sharkdp/bat) |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `find` | [fd](https://github.com/sharkdp/fd) |

### Neovim

Lazy.nvim, based on Kickstart.nvim (`init.lua` → `lua/config/*`, plugin specs in `lua/plugins/`):

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

Minimal blue theme; Claude Code agent status shown per window.

| Keybinding | Action |
|------------|--------|
| `<prefix>f` / `<prefix>F` | Toggle floating scratch shell, 60% / 95% (persists across toggles) |
| `<prefix>a` | Fuzzy window switcher (fzf, shows Claude status) |
| `<prefix>o` | Lazydocker popup (macOS) |
| `<prefix>t` | btop popup (macOS) |

OS-specific bindings live in `<os>/.config/tmux/tmux.os.conf` (optional).

**Plugins:** tpm

### Terminal (Ghostty — macOS)

- Ayu Mirage theme
- JetBrainsMono Nerd Font, 14pt
- Block cursor, non-blinking

### Prompt (Oh My Posh)

- Path with git repo name highlighted
- Git status (branch, working changes, staging, stash count)
- Execution time (right-aligned)
- Node version with package manager icon

### Git

- GPG commit signing enabled
- Delta as pager with Catppuccin Mocha theme; `~/.gitignore_global` as global excludes
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

Homebrew packages, casks, VSCode extensions and Go tools; language runtimes and CLIs like go, uv, aws-cli and aws-vault come from mise instead. Run `brew bundle install` to install everything.

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
brew bundle dump --file=~/dev/dotfiles/Brewfile --force --describe

# Update tmux plugins
# <prefix>I inside tmux

# Update Neovim plugins
# :Lazy update inside Neovim

# Update Zinit plugins
zinit update --all

# Update Mise runtimes
mise upgrade
```
