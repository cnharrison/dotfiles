# 🌊 Christopher's Kanagawa dotfiles

This is a super minimal waybar-free sway setup using the Kanagawa colorscheme. There are many like it but this one is mine

### Uses
- Sway, fuzzel, ghostty, fish, neovim, zellij, mako, Kuro

### Features
- [fuzzel](https://codeberg.org/dnkl/fuzzel), [mako](https://github.com/emersion/mako), [Ghostty](https://github.com/ghostty-org) [zellij](https://github.com/zellij-org/zellij) and [bat](https://github.com/sharkdp/bat) themed with [Kanagawa](https://github.com/rebelot/kanagawa.nvim)
- Smart [swaybar](https://man.archlinux.org/man/sway-bar.5) with weather and system info
- Kanagawa-themed version of [emoji-powerline](https://github.com/wyqydsyq/emoji-powerline) [fish](https://github.com/fish-shell/fish-shell) prompt
- [LazyVim](https://www.lazyvim.org/) with Kanagawa theme 
- Kanagawa theme for [Kuro](https://github.com/davidsmorais/kuro)
- Modern CLI tools (bat, [eza](https://github.com/eza-community/eza), [fzf](https://github.com/junegunn/fzf))

## Quick start

1. Clone this repo
2. Install:
```bash
# On Arch-based systems
paru -S sway ghostty fish neovim zellij bat eza fzf mako kuro
```

3. Copy configs:
```bash
cp -r .config/* ~/.config/
cp -r bin/* ~/bin/
```

4. Install Oh My Fish
```bash
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
```

5. Copy configs round 2:
```bash
cp -r .local/* ~/.local/
```

6. Install the Oh My fish theme:
```bash
omf install emoji-powerline-kanagawa
```

7. Make fish your default shell:
```bash
chsh -s $(which fish)
```

## Notes

- Wayland
- You'll want to edit the wallpaper font, and monitor path vars in `.config/sway/config` as well as the outputs in `bin/swaybar-wrapper.sh`
- Update your city for the weather readout in `bin/status.sh`

## Screenshot
![terminal screenshot](https://i.imgur.com/7dENbEl.png)

## Wallpaper
 ![great wave of kanagawa with gradient background](https://i.imgur.com/bWp4T9p.jpeg)

## Todo
- [ ] Modularize the color scheme + display outputs and allow switching with a script
