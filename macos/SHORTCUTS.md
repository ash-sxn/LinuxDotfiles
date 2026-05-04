# macOS keyboard cheat sheet

Terminology:

- `Command` = main macOS app shortcut key
- `Option` = Alt
- `Control` = actual Ctrl key

This setup uses `Control` heavily inside Ghostty and tmux.

## Ghostty

Custom prefix: `Ctrl+s`, then the next key.

- `Ctrl+s r` reload config
- `Ctrl+s x` close current surface
- `Ctrl+s n` new window
- `Ctrl+s c` new tab
- `Ctrl+s Shift+l` next tab
- `Ctrl+s Shift+h` previous tab
- `Ctrl+s ,` move tab left
- `Ctrl+s .` move tab right
- `Ctrl+s 1..9` jump to tab 1..9
- `Ctrl+s \` split right
- `Ctrl+s -` split down
- `Ctrl+s h/j/k/l` move between splits
- `Ctrl+s z` zoom split
- `Ctrl+s e` equalize splits

## tmux

Default tmux prefix: `Ctrl+b`

- `Ctrl+b Ctrl+p` pane up
- `Ctrl+b Ctrl+n` pane down
- `Ctrl+b Ctrl+a` pane left
- `Ctrl+b Ctrl+e` pane right

Useful tmux defaults still available:

- `Ctrl+b %` vertical split
- `Ctrl+b "` horizontal split
- `Ctrl+b c` new window
- `Ctrl+b n` next window
- `Ctrl+b p` previous window
- `Ctrl+b d` detach
- `Ctrl+b [` copy mode

TPM plugin manager:

- `Ctrl+b I` install tmux plugins after TPM is installed

## Neovim

Custom mappings from this repo:

- `;` in normal mode opens `:`
- `jk` in insert mode exits to normal mode

NvChad basics:

- `Space` is leader
- `:Telescope` for find/search workflows
- `:Mason` for LSP/tool installs

## Shell aliases

- `ll` -> `eza -lah`
- `ls` -> `eza`
- `la` -> `eza -la`
- `cat` -> `bat`
- `grep` -> `rg`
- `cls` -> `clear`

## Mac keyboard adaptation notes

- Prefer explicit `Ctrl` bindings in Ghostty and tmux instead of relying on old
  Linux Alt muscle memory.
- `Option+Left` and `Option+Right` often act like word movement in Mac terminal
  apps, but terminal behavior depends on the app and key translation settings.
- `Command` generally stays outside terminal multiplexers and terminal-native
  shortcuts unless an app explicitly binds it.
