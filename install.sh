#!/usr/bin/env bash
# Installs m365-mail-notify for the current user (no root required).
set -euo pipefail
cd "$(dirname "$0")"

for dep in python3 secret-tool xdg-open systemctl; do
  command -v "$dep" >/dev/null || { echo "missing dependency: $dep" >&2; exit 1; }
done
python3 -c 'import gi, requests; gi.require_version("Notify", "0.7"); from gi.repository import Notify' 2>/dev/null \
  || { echo "missing Python modules: python-gobject, python-requests (and libnotify)" >&2; exit 1; }

install -Dm755 m365-mail-notify         "$HOME/.local/bin/m365-mail-notify"
install -Dm644 m365-mail-notify.service "$HOME/.config/systemd/user/m365-mail-notify.service"
install -Dm644 m365-mail-notify.desktop "$HOME/.local/share/applications/m365-mail-notify.desktop"

systemctl --user daemon-reload
systemctl --user enable m365-mail-notify.service

echo "Installed. Now run:  m365-mail-notify login"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "note: add \$HOME/.local/bin to your PATH";; esac
