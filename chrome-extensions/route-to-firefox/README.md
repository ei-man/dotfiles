# Route to Firefox

Chrome only consults the system http handler (`~/.config/mimeapps.list` →
`browser-router.desktop`) for links opened by *other* applications. Links you
click while browsing inside Chrome never leave Chrome. This extension covers
that gap: it catches navigations to YouTube, YouTube Music and Spotify, undoes
them, and hands the URL to `~/.local/bin/browser-router` over native messaging.

## Install

1. `chrome://extensions` → enable **Developer mode**
2. **Load unpacked** → select this directory
3. Confirm the ID reads `mbgcbdkpiljplglemefmplpnnnadafni`

The ID is pinned by the `key` field in `manifest.json`, so it stays the same
wherever the directory lives. It must match `allowed_origins` in
`~/.config/google-chrome/NativeMessagingHosts/com.eimas.browser_router.json`
(stowed from `home/webapps`) or Chrome will refuse the native-messaging
connection.

## Pieces

| Path | Role |
| --- | --- |
| `background.js` | Watches `webNavigation`, restores the tab, forwards the URL |
| `~/.local/bin/browser-router-nm` | Native-messaging host; length-prefixed stdio |
| `~/.local/bin/browser-router` | Decides Firefox profile vs Chrome, focuses the window |

Routed hosts are listed in `ROUTED_HOSTS` in `background.js` and must be kept in
sync with `profile_for()` in `browser-router`.

## Debugging

`chrome://extensions` → **service worker** opens the console. A failed handoff
logs `native host unavailable`; that usually means the ID no longer matches
`allowed_origins`, or `browser-router-nm` is not executable.
