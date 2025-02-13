# 🌊 Christopher's Kanagawa dotfiles

This is a super minimal waybar-free sway setup using the Kanagawa colorscheme. There are many like it but this one is mine

### Uses
- Sway, ghostty, fish, neovim, zellij, mako, waybar

### Features
- Everything themed with [Kanagawa](https://github.com/rebelot/kanagawa.nvim)
- Smart swaybar with weather and system info
- Kanagawa-themed version of emoji-powerline `fish` prompt
- Modern CLI tools (`bat`, `eza`, `fzf`)

## Quick start

1. Clone this repo
2. Install:
```bash
# On Arch-based systems
paru -S sway ghostty fish neovim zellij bat eza fzf mako
```

3. Copy the configs:
```bash
cp -r .config/* ~/.config/
cp -r bin/* ~/bin/
cp -r .local/* ~/.local/
```

4. Install Oh My Fish and the theme:
```bash
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
omf install ~/.local/share/emoji-powerline-kanagawa
```

5. Make fish your default shell:
```bash
chsh -s $(which fish)
```

## Notes

- Wayland
- You'll want to edit the wallpaper font, and monitor path vars in `.config/sway/config` as well as the outputs in `bin/swaybar-wrapper.sh`

## Screenshot
![terminal screenshot](https://i.imgur.com/7dENbEl.png)

## Wallpaper
 ![great wave of kanagawa with gradient background](https://i.imgur.com/bWp4T9p.jpeg)

## Todo
- [ ] Modularize the color scheme + allow switching with a script
- [ ] Modularize the display outputs + allow switching with a script