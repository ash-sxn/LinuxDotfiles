# GNOME Customization Guide

This guide will help you customize your GNOME desktop environment to achieve a modern, stylish look similar to the Reddit examples you shared. GNOME is highly customizable through extensions, themes, icons, and various settings.

## Table of Contents
1. [Understanding GNOME's Customization System](#understanding-gnomes-customization-system)
2. [Essential Tools](#essential-tools)
3. [Custom Theme Setup](#custom-theme-setup)
4. [Icon Packs](#icon-packs)
5. [GNOME Extensions](#gnome-extensions)
6. [Desktop Layout and Dock](#desktop-layout-and-dock)
7. [Custom Fonts](#custom-fonts)
8. [Terminal Customization](#terminal-customization)
9. [Widget Setup](#widget-setup)
10. [Wallpapers](#wallpapers)
11. [Full Setup Example](#full-setup-example)

## Understanding GNOME's Customization System

GNOME's customization system consists of several components:

- **GNOME Tweaks**: A tool that provides access to advanced GNOME settings
- **GNOME Extensions**: Add-ons that modify or extend GNOME's functionality
- **GTK Themes**: Control the appearance of application windows, buttons, and controls
- **Shell Themes**: Modify the appearance of the GNOME Shell (top bar, Activities overview, etc.)
- **Icon Themes**: Change the appearance of icons throughout the system
- **Fonts**: Customize text appearance system-wide

These components work together to create a cohesive desktop experience. Unlike some other desktop environments, GNOME focuses on a clean, minimal aesthetic by default, but it can be extensively customized.

## Essential Tools

Before we start customizing, let's install some essential tools:

```bash
# For Debian/Ubuntu-based systems
sudo apt install gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager git curl

# For Fedora
sudo dnf install gnome-tweaks gnome-extensions-app gnome-shell-extension-manager git curl

# For Arch Linux
sudo pacman -S gnome-tweaks gnome-shell-extensions git curl
```

You'll also want to install the Extension Manager, which you can get from Flathub:

```bash
flatpak install flathub com.mattjakeman.ExtensionManager
```

## Custom Theme Setup

Based on the screenshots you shared, you'll want to use a modern, dark theme with blue accents. Here's how to set up a custom theme:

### Installing WhiteSur Theme (similar to the examples)

1. First, install required dependencies:

```bash
# For Debian/Ubuntu
sudo apt install sassc libglib2.0-dev git meson

# For Fedora
sudo dnf install sassc glib2-devel git meson

# For Arch
sudo pacman -S sassc glib2 git meson base-devel
```

2. Clone the WhiteSur theme repository:

```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
```

3. Install the theme with blue accent color and dark variant:

```bash
./install.sh -c dark -a blue -m -l
```

### Applying the Theme

1. Open GNOME Tweaks
2. Go to "Appearance"
3. Set "Applications" to "WhiteSur-dark-blue"
4. Set "Shell" to "WhiteSur-dark-blue" (you may need to enable "User themes" extension first)

## Icon Packs

The screenshots show a clean, modern icon set. You can use Tela circle icons which match this style:

```bash
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme
./install.sh blue
```

Then apply the icon theme in GNOME Tweaks:
1. Open GNOME Tweaks
2. Go to "Appearance"
3. Set "Icons" to "Tela-circle-blue-dark"

## GNOME Extensions

Here are the essential extensions to achieve the look in the screenshots:

1. **Dash to Dock** or **Dash to Panel** - Transforms the dash into a dock or panel
2. **Blur my Shell** - Adds blur effects to various shell components
3. **User Themes** - Allows shell theme customization
4. **Just Perfection** - Customize GNOME Shell elements
5. **GSConnect** - Connect to Android devices
6. **ArcMenu** - Application menu for GNOME
7. **Vitals** - System monitoring
8. **OpenWeather** - Weather information in the top bar

Install using Extension Manager or from https://extensions.gnome.org/

### Configuring Extensions

#### Dash to Dock
1. Position on screen: Bottom
2. Icon size: 48px
3. Enable "Show Applications icon"
4. Background opacity: 80%
5. Enable "Customize opacity"
6. Enable "Custom color"
7. Set color to match your wallpaper or #1a1a1a with 75% opacity

#### Blur my Shell
1. Enable Blur for Panel, Overview, and Dash
2. Set Sigma (blur amount) to around 15
3. Set Brightness to around 0.6

#### Just Perfection
1. Reduce top bar height to around 36px
2. Hide certain elements like the search icon
3. Adjust animation speed to taste

## Desktop Layout and Dock

To achieve the look in your examples:

1. Configure Dash to Dock:
   - Position on screen: Bottom
   - Intelligent auto hide: On
   - Icon size limit: 48px
   - Background opacity: 60-80%
   - Use custom color: #1a1a1a or to match your wallpaper

2. Top Bar Customization (using Just Perfection extension):
   - Reduce top bar height: 36px
   - Hide unwanted elements
   - Add clock to center

## Custom Fonts

The screenshots appear to use a clean sans-serif font. You can install and use fonts like Roboto, Ubuntu, or SF Pro:

```bash
# Installing SF Pro-like fonts (Inter is a good alternative)
sudo apt install fonts-inter # Ubuntu/Debian
sudo dnf install inter-fonts # Fedora
sudo pacman -S inter-font # Arch
```

Apply in GNOME Tweaks:
1. Go to "Fonts"
2. Interface Text: Inter Regular 10
3. Document Text: Inter Regular 11
4. Monospace Text: JetBrains Mono or Fira Code 10
5. Legacy Window Titles: Inter Bold 11
6. Enable "Antialiasing": Subpixel
7. Enable "Hinting": Slight

## Terminal Customization

For a terminal like the one in the screenshots:

1. Open Terminal preferences
2. Set custom background opacity (80-90%)
3. Use a dark background color (#1a1a1a or similar)
4. Enable custom padding (24px)
5. Use a monospace font (JetBrains Mono or Fira Code)
6. Install and configure Oh My Zsh or Starship prompt for a nicer terminal prompt

## Widget Setup

For system info widgets and clock:

1. Install Conky:
```bash
sudo apt install conky-all # Ubuntu/Debian
sudo dnf install conky # Fedora
sudo pacman -S conky # Arch
```

2. Create a custom Conky configuration file:
```bash
mkdir -p ~/.config/conky
nano ~/.config/conky/conky.conf
```

3. Use a Conky configuration template (search for "Conky themes" online)

4. Set Conky to autostart by creating a `.desktop` file in `~/.config/autostart/`

## Wallpapers

The screenshots use modern, dark wallpapers with blue/teal accents:

1. You can find similar wallpapers on:
   - https://unsplash.com/
   - https://wallhaven.cc/
   - https://www.pexels.com/

2. Search for "minimal dark blue abstract wallpaper"

3. Apply the wallpaper:
   - Right-click on desktop > "Change Background"
   - Or use GNOME Tweaks > "Appearance" > "Background"

## Full Setup Example

Here's a complete script to achieve a look similar to the screenshots:

```bash
#!/bin/bash

# Install required packages
sudo apt install gnome-tweaks gnome-shell-extensions git sassc libglib2.0-dev meson conky-all

# Install Extension Manager
flatpak install flathub com.mattjakeman.ExtensionManager

# Install WhiteSur theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -c dark -a blue -m -l
cd ..

# Install Tela Circle icons
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme
./install.sh blue
cd ..

# Install fonts
sudo apt install fonts-inter fonts-jetbrains-mono

# Download a nice wallpaper
mkdir -p ~/Pictures/Wallpapers
wget -O ~/Pictures/Wallpapers/blue-abstract.jpg "https://images.unsplash.com/photo-1579546929518-9e396f3cc809"

# Create a Conky config
mkdir -p ~/.config/conky
cat > ~/.config/conky/conky.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'Inter:size=10',
    gap_x = 30,
    gap_y = 60,
    minimum_height = 5,
    minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
}

conky.text = [[
${color dodgerblue}${font Inter:size=40}${time %H:%M}${font}${color}
${color white}${font Inter:size=14}${time %A %d %B %Y}${font}${color}

${color dodgerblue}SYSTEM ${hr 2}${color}
${color white}Hostname: $nodename
Kernel: $kernel
Uptime: $uptime
${color dodgerblue}CPU ${hr 2}${color}
${color white}CPU: ${cpu cpu0}% ${cpubar cpu0}
${color dodgerblue}MEMORY ${hr 2}${color}
${color white}RAM: $mem/$memmax - $memperc% ${membar}
${color dodgerblue}DISK ${hr 2}${color}
${color white}Root: ${fs_used /}/${fs_size /} ${fs_bar /}
Home: ${fs_used /home}/${fs_size /home} ${fs_bar /home}
]]
EOF

# Set up autostart for Conky
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/conky.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Conky
Exec=conky -d -c ~/.config/conky/conky.conf
Terminal=false
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Set GNOME settings
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-dark-blue"
gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-dark-blue"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-blue-dark"
gsettings set org.gnome.desktop.interface font-name "Inter 10"
gsettings set org.gnome.desktop.interface document-font-name "Inter 11"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrains Mono 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Inter Bold 11"
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Pictures/Wallpapers/blue-abstract.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$USER/Pictures/Wallpapers/blue-abstract.jpg"

echo "Setup complete! Please log out and log back in for changes to take effect."
```

Save this script, make it executable with `chmod +x setup_gnome.sh`, and run it to apply all customizations.

Remember that achieving exactly the look in the screenshots may require additional tweaking to match your preferences. 