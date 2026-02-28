# Plan: Option C — Chezmoi-Centric Mac Setup

## Goal

A single minimal bootstrap script installs Homebrew and chezmoi. Everything
else — packages, zsh plugins, editor config — flows from `chezmoi apply`. No
more dual package lists, no Linux dead weight, no dangling scripts.

---

## New Boot Sequence (Fresh Mac)

```
curl -sfL https://raw.githubusercontent.com/sschlesier/shell-setup/main/shell-setup | bash

  shell-setup
    └─ shell-bootstrap
         1. Install Xcode Command Line Tools
         2. Install Homebrew (Apple Silicon path only)
         3. brew install chezmoi
         4. chezmoi init https://github.com/sschlesier/dotfiles.git
         5. chezmoi apply
              └─ run_onchange_brew-bundle.sh  →  brew bundle
              └─ zsh config picks up antidote on first shell launch
              └─ neovim config bootstraps lazy.nvim on first nvim launch
```

After the bootstrap completes, open a new shell and everything is live.

---

## Changes to This Repo (shell-setup)

### shell-bootstrap — rewrite

Strip to Mac-only. Remove:
- `dnf` / `apt-get` blocks
- All three `brewpaths` entries except `/opt/homebrew/bin/brew`
- The full `brew install` package list
- The `pip3 install` block

Replace the package installation with:
1. Check for / install Xcode Command Line Tools
2. Install Homebrew (single path, Apple Silicon)
3. `brew install chezmoi`
4. `chezmoi init` + `chezmoi apply`

### shell-setup — simplify

Remove:
- `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"` (Linux-only, wrong on Mac)
- `curl ... shell-chezmoi` (absorbed into bootstrap)
- `curl ... shell-antidote` (handled by zsh config on first shell launch)
- `curl ... shell-vimplug` (replaced by lazy.nvim)
- `curl ... shell-tmux` (file doesn't exist; remove the reference)

Result: `shell-setup` is just the curl to `shell-bootstrap`.

### Scripts to delete

| Script | Reason |
|---|---|
| `shell-chezmoi` | Logic moves into `shell-bootstrap` |
| `shell-antidote` | Handled by dotfiles zsh config |
| `shell-vimplug` | Replaced by lazy.nvim |

---

## Changes to the Dotfiles Repo

### 1. Add the Brewfile

Move `/Users/scotts/current/brewfile/Brewfile` into the dotfiles repo.
Reconcile it with the current `shell-bootstrap` package list — the Brewfile
is closer to correct but is missing a few things (`sponge`, `eza`, `lf`,
the custom taps). The Brewfile becomes the single source of truth for packages.

Suggested location in dotfiles: `home/dot_Brewfile` (chezmoi renders it to `~/.Brewfile`)

Use `brew bundle --global` so it reads from `~/.Brewfile` automatically.

### 2. Add a chezmoi run script

Create `home/.chezmoiscripts/run_onchange_brew-bundle.sh.tmpl`:

```bash
#!/bin/bash
# runs whenever Brewfile changes (chezmoi tracks the hash)
brew bundle --global
```

This means: run `chezmoi apply` → if `~/.Brewfile` changed → `brew bundle` runs
automatically. No manual step required.

### 3. Replace vim-plug with lazy.nvim

Remove `shell-vimplug` entirely. lazy.nvim bootstraps itself from `init.lua`:

```lua
-- in ~/.config/nvim/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)
```

On first `nvim` launch after `chezmoi apply`, lazy.nvim clones itself and
installs all plugins. Nothing to curl separately.

### 4. antidote — already handled by dotfiles

antidote is already in the Brewfile. The zsh config sources the static plugin
bundle on shell start. The `shell-antidote` script was only needed to generate
the bundle on a fresh machine — antidote handles this automatically if the zsh
config is set up correctly (it generates `~/.zsh_plugins.zsh` on first run if
it doesn't exist).

### 5. pip installs → pipx

Replace the `pip3 install` block with `pipx` entries in the Brewfile:

```ruby
brew "pipx"
```

Then add a second chezmoi run script `run_onchange_pipx.sh` for pipx packages,
or just install them manually after bootstrap. Avoids polluting the system
Python.

---

## pip packages to reconsider

| Package | Action |
|---|---|
| `visidata` | `pipx install visidata` — install in isolated env |
| `openpyxl` | Only needed as a visidata dependency — pipx handles it |
| `pylint` | `pipx install pylint` — or skip if using nvim LSP (pylsp/ruff) |

---

## Brewfile Reconciliation

Items in `shell-bootstrap` not yet in the Brewfile to review:

| Package | Keep? | Notes |
|---|---|---|
| `the_silver_searcher` | Drop | Redundant — `ripgrep` is faster and already in Brewfile |
| `wget` | Maybe | `curl` is built into macOS; wget is habit |
| `httpie` | Maybe | Good for interactive API work; decide based on use |
| `dos2unix` | Drop | Not relevant on Mac-only workflow |
| `parallel` | Keep | Useful; add to Brewfile |
| `sponge` | Keep | Part of `moreutils`; add `brew "moreutils"` to Brewfile |
| `eza` | Keep | Already intended to replace `ls`; add to Brewfile |
| `lf` | Keep | Already in recent commits; add to Brewfile |
| `file` | Drop | Built into macOS |
| `zsh` | Keep | Brew zsh is newer than macOS system zsh |
| `shellcheck` | Keep | Add to Brewfile |
| `font-fira-code-nerd-font` | Keep | Add as `cask "font-fira-code-nerd-font"` |
| custom taps (bombardier, csvutils) | Keep | Add taps + brews to Brewfile |

---

## End State

**This repo** has two files:
- `shell-setup` — one-liner curl to shell-bootstrap
- `shell-bootstrap` — install CLT, Homebrew, chezmoi, run chezmoi apply

**Dotfiles repo** owns everything else:
- `~/.Brewfile` — all packages
- `.chezmoiscripts/run_onchange_brew-bundle.sh` — auto-runs brew bundle
- zsh config — antidote bootstraps on first shell
- `~/.config/nvim/` — lazy.nvim bootstraps on first nvim

One repo to curl, one `chezmoi apply` to rule them all.
