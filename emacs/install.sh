#!/bin/sh
#
# emacs
#
# Sets up emacs-plus as a login daemon plus a Spotlight-launchable client app.
# Idempotent: safe to re-run after an emacs-plus upgrade.

set -e

# Resolve the emacs-plus install regardless of the pinned version (@29, @30, ...).
EMACS_APP="$(brew --prefix)/opt/$(brew list --formula | grep -m1 '^emacs-plus')/Emacs.app"
EMACS_BIN="$(brew --prefix)/bin/emacs"
EMACSCLIENT_BIN="$(brew --prefix)/bin/emacsclient"

if [ ! -d "$EMACS_APP" ]; then
  echo "  emacs-plus not found via brew; skipping. Install with: brew install d12frosted/emacs-plus/emacs-plus@29"
  exit 0
fi

# 1. Symlink the full GUI app into /Applications (fallback / non-daemon use).
if [ ! -e "/Applications/Emacs.app" ]; then
  ln -s "$EMACS_APP" "/Applications/Emacs.app"
  echo "  linked /Applications/Emacs.app -> $EMACS_APP"
fi

# 2. LaunchAgent: start the daemon at login.
PLIST="$HOME/Library/LaunchAgents/com.asierzapata.emacs.daemon.plist"
cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.asierzapata.emacs.daemon</string>
  <key>ProgramArguments</key>
  <array>
    <string>$EMACS_BIN</string>
    <string>--fg-daemon</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/emacs-daemon.out.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/emacs-daemon.err.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>$(brew --prefix)/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
</dict>
</plist>
PLIST_EOF
echo "  wrote $PLIST"

# (Re)load the daemon LaunchAgent.
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "  loaded emacs daemon LaunchAgent"

# 3. Client launcher app for Spotlight.
CLIENT_APP="/Applications/Emacs Client.app"
rm -rf "$CLIENT_APP"
mkdir -p "$CLIENT_APP/Contents/MacOS" "$CLIENT_APP/Contents/Resources"

cat > "$CLIENT_APP/Contents/MacOS/emacs-client" <<CLIENT_EOF
#!/bin/sh
exec "$EMACSCLIENT_BIN" -c -n -a "" "\$@"
CLIENT_EOF
chmod +x "$CLIENT_APP/Contents/MacOS/emacs-client"

# Borrow the emacs-plus icon so it looks right in Spotlight / the Dock.
if [ -f "$EMACS_APP/Contents/Resources/Emacs.icns" ]; then
  cp "$EMACS_APP/Contents/Resources/Emacs.icns" "$CLIENT_APP/Contents/Resources/Emacs.icns"
fi

cat > "$CLIENT_APP/Contents/Info.plist" <<INFO_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Emacs Client</string>
  <key>CFBundleDisplayName</key>
  <string>Emacs Client</string>
  <key>CFBundleIdentifier</key>
  <string>com.asierzapata.emacs-client</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleExecutable</key>
  <string>emacs-client</string>
  <key>CFBundleIconFile</key>
  <string>Emacs.icns</string>
  <key>LSUIElement</key>
  <false/>
</dict>
</plist>
INFO_EOF

# Nudge Spotlight to index the new app immediately.
touch "$CLIENT_APP"
mdimport "$CLIENT_APP" 2>/dev/null || true
echo "  built '$CLIENT_APP'"

echo "  done. Spotlight: 'Emacs Client' (fast, daemon) or 'Emacs' (full app)."
