# Arch Linux + SwayWM 
## Sway Install + Dependencies 
### Install Sway + ly + Polkit
```
sudo pacman -S --needed swaybg swaylock swayidle waybar wofi brightnessctl grim slurp pavucontrol alacritty xorg-xwayland wayland-protocols polkit  ly
```
### Required For Icons, Screenshare & Authentication
```
sudo pacman -S ttf-font-awesome ttf-jetbrains-mono-nerd xorg-xhost xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard gvfs lxqt-policykit
```
### Config ly-greeter
```
sudo dpkg-reconfigure ly && systemctl daemon-reload
systemctl enable ly.service
```

### Install a GUI Filemanager , TextEditor & ImageViewer
Recommended
```
sudo pacman -S --needed thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman engrampa gvfs xed xreader android-file-transfer
```
Optional Extras
```
sudo pacman -S --needed catfish tumbler file-roller engrampa caja squashfs-tools libopenraw libgepub libgsf poppler-glib ffmpegthumbnailer   
```
### Dynamic Autotiling for Sway, Notification deamon (AUR Stuff) , Pomodoro Gnome & Waybar 
```
paru -S autotiling swaync flameshot-git pix i3-gnome-pomodoro-git
```
For Bluetooth Support
```
paru -S bluetuith
```
### Set Theme for gtk and qt
GTK - Theme
```
mkdir .themes
cd .themes
git clone https://github.com/dracula/gtk.git
mv gtk Dracula
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
```
GTK - Icons
```
sudo pacman -S papirus-icon-theme
gsettings set org.gnome.desktop.interface icon-theme "Papirus"
```
Set gtk theme with lxappearance
```
sudo pacman -S --needed lxappearance
```
QT 

```
sudo pacman -S qt6ct kvantum
```
Setup Environment variables (useful setting force wayland flags globally )
```sudo nvim /etc/environment```
```
QT_QPA_PLATFORMTHEME=qt6ct 
ELECTRON_OZONE_PLATFORM_HINT=wayland
```