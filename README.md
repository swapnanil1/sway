# Arch Linux + SwayWM 
## Sway Install + Dependencies 
### Install Sway + ly + Polkit
```
paru -S --needed swaybg swaylock swayidle waybar wofi brightnessctl grim slurp pavucontrol alacritty xorg-xwayland wayland-protocols polkit  ly
```
### Required For Icons, Screenshare & Authentication
```
paru -S ttf-font-awesome xorg-xhost xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard network-manager-applet gvfs polkit-kde-agent
```
### Config ly-greeter
```
sudo dpkg-reconfigure ly && systemctl daemon-reload
systemctl enable ly.service
```

### Install a GUI Filemanager , TextEditor & ImageViewer
```
paru -S --needed thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman catfish gvfs tumbler file-roller engrampa xarchiver caja squashfs-tools libopenraw libgepub libgsf poppler-glib ffmpegthumbnailer xarchiver xed pix
```
### Dynamic Autotiling for Sway & Notification deamon 
```
paru -S autotiling swaync flameshot-git
```
### Set Theme for gtk and qt
GTK - Theme
```
cd .themes
git clone git clone https://github.com/dracula/gtk.git
mv gtk Dracula
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
```
GTK - Icons
```
paru -S papirus-icon-theme
gsettings set org.gnome.desktop.interface icon-theme "papirus-icon-theme"
```
QT 

```
paru -S qt6ct kvantum
```
Set ```QT_QPA_PLATFORMTHEME=qt6ct```
in /etc/environment
