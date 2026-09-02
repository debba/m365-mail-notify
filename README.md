# m365-mail-notify

Native GNOME desktop notifications for new email in a Microsoft 365 / Exchange Online inbox,
without running a full mail client.

Useful when company policy says "use Outlook on the web" but you still want to know when
something lands in your inbox. The tool never downloads or stores mail: it only reads the
sender and subject of new messages and shows them as a notification. Clicking the
notification opens Outlook on the web.

## How it works

- **Authentication**: OAuth2 device code flow against `login.microsoftonline.com`.
  No password is ever stored. Tokens are kept in the GNOME keyring (libsecret).
- **Backend `imap`** (default): connects to `outlook.office365.com` with `AUTH=XOAUTH2`
  and waits in **IMAP IDLE**, so notifications are instant and there is no polling.
- **Backend `graph`**: polls the Microsoft Graph inbox endpoint every N seconds.
  Use it if your tenant has IMAP disabled.
- Runs as a **systemd user service** bound to the graphical session and reconnects
  automatically after network drops.

No client secret is involved. By default the tool falls back to well-known public client
IDs (Thunderbird for IMAP, Microsoft Graph PowerShell for Graph), which means the Microsoft
sign-in page shows *those* application names. To have it appear under its own name, register
your own app (see below) and pass `--client-id`.

## Requirements

- GNOME (tested on GNOME 50, Wayland) with a running keyring
- `python3` with `python-gobject` and `python-requests`
- `libnotify`, `libsecret` (`secret-tool`), `xdg-utils`

Arch Linux:

```sh
sudo pacman -S --needed python-gobject python-requests libnotify libsecret xdg-utils
```

Debian/Ubuntu:

```sh
sudo apt install python3-gi gir1.2-notify-0.7 python3-requests libsecret-tools xdg-utils
```

## Install

```sh
git clone https://github.com/debba/m365-mail-notify.git
cd m365-mail-notify
./install.sh
m365-mail-notify login
```

`login` prints a code and opens <https://microsoft.com/devicelogin>; sign in with your
work account and the service starts automatically.

If IMAP is disabled by your organisation:

```sh
m365-mail-notify login --backend graph --interval 60
```

## Use your own app registration (recommended)

Registering an app takes two minutes and makes the sign-in and consent screens show
"m365-mail-notify" (or whatever name you pick) instead of Thunderbird.

1. Open <https://entra.microsoft.com> → **Identity → Applications → App registrations → New registration**.
2. Name: `m365-mail-notify`. Supported account types: *Accounts in this organizational
   directory only* (or *any organizational directory* if you want to reuse it elsewhere).
   Leave the redirect URI empty. Register.
3. **Authentication → Advanced settings → Allow public client flows: Yes**. Save.
4. Optional: **API permissions → Add a permission**:
   - IMAP backend: *APIs my organization uses → Office 365 Exchange Online → Delegated → `IMAP.AccessAsUser.All`*
   - Graph backend: *Microsoft Graph → Delegated → `Mail.Read`*

   Permissions are requested dynamically at sign-in anyway; adding them here just lets an
   admin grant consent for everyone if user consent is restricted.
5. Copy the **Application (client) ID** and the **Directory (tenant) ID** from the Overview page, then:

```sh
m365-mail-notify login --client-id <application-id> --tenant <tenant-id>
```

Both values are stored in `~/.config/m365-mail-notify/config.json` and reused by the service.
If your account has no rights to create app registrations, ask an admin, or fall back to the
default client IDs.

## Usage

```
m365-mail-notify login [--backend imap|graph] [--user EMAIL] [--interval SECONDS]
                       [--client-id ID] [--tenant TENANT]
m365-mail-notify test      # show a test notification
m365-mail-notify logout    # remove tokens and stop the service
m365-mail-notify run       # what the systemd service executes
```

Logs:

```sh
journalctl --user -fu m365-mail-notify
```

## Uninstall

```sh
./uninstall.sh
```

## Notes and limitations

- Only the `INBOX` folder is watched. Mail moved elsewhere by server-side rules is not reported.
- If your tenant blocks user consent for third-party applications, neither backend can
  authenticate. The remaining policy-compliant option is to install Outlook on the web
  as a browser PWA and enable its desktop notifications.
- Exchange drops IDLE connections after about 30 minutes; the client renews them every 25.

## License

MIT
