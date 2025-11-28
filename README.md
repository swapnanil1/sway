# Sway: Essential Fixes

This document details the necessary packages and configurations to enable GUI authentication prompts (Polkit) and Wayland screen sharing on a minimal Sway setup.

## 1. Install Dependencies

Run the following command to install the required backends and utilities:

```bash
# Polkit (Auth) and Portals (Screen Sharing)
sudo pacman -S polkit polkit-gnome xdg-desktop-portal xdg-desktop-portal-wlr slurp pipewire wireplumber
```

---

## 2. Configuration Fixes

### A. Setup Polkit (GUI Authentication)
**Problem:** GUI apps requiring root access (like Timeshift, GParted) do not prompt for a password.

  **Autostart Agent:** Add the GNOME Polkit agent to your Sway config 
  **Fix Root Apps (Wayland):** Wayland blocks root apps by default. To run apps like Timeshift, use a wrapper script or command:
    ```bash
    # Allow root to access local XWayland display
    xhost +SI:localuser:root && pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY timeshift-gtk
    ```

### B. Setup Screen Sharing
**Problem:** Browsers and apps cannot detect the screen for sharing.

  **Configure Portals:** Create/Edit `~/.config/xdg-desktop-portal/portals.conf`:
    ```ini
    [preferred]
    default=wlr
    org.freedesktop.impl.portal.Settings=gtk
    ```



```
