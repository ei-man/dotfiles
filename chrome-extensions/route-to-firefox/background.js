// Catch navigations to YouTube / YouTube Music / Spotify inside Chrome and hand
// them to ~/.local/bin/browser-router, which opens them in the matching Firefox
// profile. Chrome never consults the system http handler for its own
// navigations, so this extension is the only way those links leave Chrome.

const HOST = "com.eimas.browser_router";

// Hosts the router owns. Keep in sync with profile_for() in browser-router.
const ROUTED_HOSTS = [
  "youtube.com",
  "youtu.be",
  "youtube-nocookie.com",
  "spotify.com",
];

// webNavigation filters, built from the same list.
const URL_FILTERS = ROUTED_HOSTS.flatMap((host) => [
  { hostEquals: host, schemes: ["http", "https"] },
  { hostSuffix: "." + host, schemes: ["http", "https"] },
]);

// Debounce: one navigation can surface as several events, and each one would
// otherwise spawn its own Firefox handoff.
const recent = new Map();
const DEBOUNCE_MS = 3000;

function isRouted(url) {
  let host;
  try {
    host = new URL(url).hostname.toLowerCase();
  } catch {
    return false;
  }
  return ROUTED_HOSTS.some((h) => host === h || host.endsWith("." + h));
}

function seenRecently(tabId, url) {
  const now = Date.now();
  for (const [key, at] of recent) {
    if (now - at > DEBOUNCE_MS) recent.delete(key);
  }
  const key = `${tabId}|${url}`;
  if (recent.has(key)) return true;
  recent.set(key, now);
  return false;
}

// Put the tab back where it was before the navigation we're stealing. A tab
// that has nowhere to go back to was opened solely for this link, so close it —
// unless it's the last one, which would take the whole window down with it.
async function restoreTab(tabId) {
  const tab = await chrome.tabs.get(tabId);
  const current = tab.url || "";

  const disposable =
    !current ||
    current === "about:blank" ||
    current.startsWith("chrome://") ||
    isRouted(current); // already on a routed page: navigating back would loop

  if (!disposable) {
    await chrome.tabs.update(tabId, { url: current });
    return;
  }

  const siblings = await chrome.tabs.query({ windowId: tab.windowId });
  if (siblings.length > 1) {
    await chrome.tabs.remove(tabId);
  } else {
    await chrome.tabs.update(tabId, { url: "about:blank" });
  }
}

chrome.webNavigation.onBeforeNavigate.addListener(
  async ({ tabId, frameId, url }) => {
    if (frameId !== 0 || tabId < 0) return;
    if (seenRecently(tabId, url)) return;

    // Cancel Chrome's navigation first — the sooner this lands, the less
    // chance the page starts painting.
    try {
      await restoreTab(tabId);
    } catch (err) {
      console.warn("route-to-firefox: could not restore tab", err);
    }

    try {
      await chrome.runtime.sendNativeMessage(HOST, { url });
    } catch (err) {
      console.error("route-to-firefox: native host unavailable", err);
    }
  },
  { url: URL_FILTERS },
);
