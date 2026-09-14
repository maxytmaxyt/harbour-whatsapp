# Contributing to harbour-whatsapp

Thanks for taking the time to contribute! 🎉
This guide explains how to get set up, what we're looking for, and how the review process works.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How can I contribute?](#how-can-i-contribute)
- [Development setup](#development-setup)
- [Project conventions](#project-conventions)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Reporting bugs](#reporting-bugs)
- [Requesting features](#requesting-features)

---

## Code of Conduct

Be respectful. Sailfish OS is a niche ecosystem — everyone here is a volunteer. Constructive criticism is welcome; personal attacks are not.

---

## How can I contribute?

- 🐛 **Bug fixes** — always welcome
- 🌍 **Translations** — add a new `.ts` file under `translations/`
- 🎨 **QML / UI improvements** — Silica-native look & feel is the goal
- 🔔 **Daemon / notification improvements** — the Python background daemon is still basic
- 📖 **Documentation** — improve the README, add inline comments, write a wiki page
- 🧪 **Testing on real hardware** — report which devices work and which don't

---

## Development setup

### Prerequisites

| Tool | Purpose |
|---|---|
| [Sailfish SDK](https://docs.sailfishos.org/Tools/Sailfish_SDK/) | Build environment (Scratchbox2 + Sailfish IDE) |
| Sailfish OS device or emulator | Runtime testing |
| `git` | Version control |
| Python 3 | Only needed if you work on the daemon |

### Clone and build

```bash
# 1. Fork the repo on GitHub, then clone your fork
git clone https://github.com/<your-username>/harbour-whatsapp.git
cd harbour-whatsapp

# 2. Add the upstream remote
git remote add upstream https://github.com/maxytmaxyt/harbour-whatsapp.git

# 3. Build via Sailfish SDK CLI
sfdk build

# 4. Deploy to a connected device
sfdk deploy --sdk
```

### Running the daemon manually (for testing)

```bash
# On the Sailfish device as the nemo user:
python3 src/daemon/harbour-whatsapp-daemon.py
```

---

## Project conventions

### QML style

- Use **Sailfish Silica** components (`import Sailfish.Silica 1.0`) — no plain Qt Quick controls
- Keep page logic inside the page file; avoid global state where possible
- IDs are `camelCase`, property names are `camelCase`
- One component per file

### Python daemon

- Target **Python 3** (as available on Sailfish OS)
- Keep dependencies minimal — only stdlib and `dbus-python`
- Resource budget: ≤ 5 % CPU, ≤ 64 MB RAM (enforced by the systemd unit)

### Commit messages

Follow the conventional format:

```
<type>(<scope>): <short summary>

[optional body]
```

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `ui` | Visual / QML change |
| `i18n` | Translation change |
| `ci` | Workflow / build change |
| `docs` | Documentation only |
| `refactor` | Code change without behaviour change |
| `chore` | Dependency bump, file rename, etc. |

Examples:
```
feat(cover): show unread count from D-Bus
fix(mainpage): retry button not visible on dark theme
i18n: add Finnish translation
```

### Branch naming

```
fix/<short-description>
feat/<short-description>
i18n/<language-code>
```

---

## Submitting a Pull Request

1. **Create a branch** off `main`:
   ```bash
   git checkout -b feat/my-improvement
   ```

2. **Make your changes** and commit them with a descriptive message.

3. **Keep your branch up to date**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

4. **Test on a real device or the emulator** before opening the PR.

5. **Push and open the PR** against `main`:
   ```bash
   git push origin feat/my-improvement
   ```

6. **Fill in the PR description** — what does it change and why?

7. CI will automatically build RPMs for `aarch64`, `armv7hl`, and `i486`. All three must pass before merge.

---

## Reporting bugs

Open an [Issue](https://github.com/maxytmaxyt/harbour-whatsapp/issues) and include:

- Sailfish OS version (`Settings → About device`)
- Device model
- What you expected vs. what happened
- Steps to reproduce
- Relevant log output if available:
  ```bash
  journalctl --user -u harbour-whatsapp-daemon.service -n 50
  ```

---

## Requesting features

Open an [Issue](https://github.com/maxytmaxyt/harbour-whatsapp/issues) with the label **enhancement** and describe:

- What you want the app to do
- Why it fits the scope of a Sailfish-native wrapper
- Any implementation ideas you already have

---

## Adding a translation

1. Copy `translations/harbour-whatsapp-de.ts` to `translations/harbour-whatsapp-<lang>.ts`  
   (e.g. `harbour-whatsapp-fi.ts` for Finnish)
2. Translate the `<translation>` values inside the XML
3. Add the new file to `harbour-whatsapp.pro` under `TRANSLATIONS`
4. Open a PR with the title `i18n: add <Language> translation`

---

*Happy hacking! ⚓*
