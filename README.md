# Sway: Essential Fixes

This document details the necessary packages and configurations to enable **GUI Authentication (Polkit)**, **Screen Sharing**, and **Login Persistence (Keyring)** on a minimal Sway setup.

## 1. Install Dependencies

Run the following command to install the required backends and utilities:

```bash
# Polkit, Portals, and Keyring
sudo pacman -S polkit polkit-gnome xdg-desktop-portal xdg-desktop-portal-wlr slurp pipewire wireplumber gnome-keyring libsecret
```

---

## 2. Configuration Fixes

### A. Setup Polkit (GUI Authentication)
**Problem:** GUI apps requiring root access (like Timeshift, GParted) do not prompt for a password.

1.  **Autostart Agent:** Add the GNOME Polkit agent to your Sway config.
2.  **Fix Root Apps (Wayland):** Wayland blocks root apps by default. To run apps like Timeshift, use a wrapper script or command:
    ```bash
    # Allow root to access local XWayland display
    xhost +SI:localuser:root && pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY timeshift-gtk
    ```

### B. Setup Screen Sharing
**Problem:** Browsers and apps cannot detect the screen for sharing.

1.  **Configure Portals:** Create/Edit `~/.config/xdg-desktop-portal/portals.conf`:
    ```ini
    [preferred]
    default=wlr
    org.freedesktop.impl.portal.Settings=gtk
    ```

### C. Setup Keyring (Login Persistence)
**Problem:** Browsers (Chrome, Brave) and Electron apps (VS Code, Figma) log out after every restart.
**Why:** These apps look for a secure system keyring to store session cookies/passwords. Without `gnome-keyring` unlocking automatically via PAM, the apps cannot save or retrieve your credentials.

**The Fix:** Edit `/etc/pam.d/login` to unlock the keyring when you log in.

**File:** `/etc/pam.d/login`
```bash
#%PAM-1.0

auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so    # <--- Unlocks keyring on auth

account    include      system-local-login

session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start  # <--- Starts daemon

password   include      system-local-login
password   optional     pam_gnome_keyring.so    # <--- Updates keyring if user pass changes
```
