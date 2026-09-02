#!/usr/bin/env bash
set -uo pipefail
systemctl --user disable --now m365-mail-notify.service 2>/dev/null
secret-tool clear application m365-mail-notify key tokens 2>/dev/null
rm -f "$HOME/.local/bin/m365-mail-notify" \
      "$HOME/.config/systemd/user/m365-mail-notify.service" \
      "$HOME/.local/share/applications/m365-mail-notify.desktop"
rm -rf "$HOME/.config/m365-mail-notify"
systemctl --user daemon-reload
echo "Removed."
