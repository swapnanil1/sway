# Gaming

* **FreeSync / VRR**: `output * adaptive_sync on` in `20-output.conf`. It engages
  for fullscreen windows; no driver snippet is needed.
* **Tearing**: outputs allow it and game windows opt in (`70-rules.conf`), so a
  game that asks for immediate presentation gets the lowest latency. Everything
  else stays vsynced.
* **No compositor to switch off**: sway presents a fullscreen window directly.
* **Idle**: fullscreen windows inhibit the idle lock, so a controller-only
  session is never locked.
* **Game mode** (`Mod+Shift+G`): notifications paused, idle daemon stopped, and
  every binding off except `Mod+1…0` and the key that leaves. It only touches
  the user session.
* **Workspaces**: games open on 5, the Steam client on 6, and Steam's dialogs float.
* Most games run through XWayland; that is normal and needs no setup.

Anti-cheat does not look at the compositor. Whether a title runs depends on the
game; avoid injecting overlays or Vulkan layers into anti-cheat games.
