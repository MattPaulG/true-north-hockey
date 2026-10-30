# True North Hockey calendar skills

Claude skills that add [True North Hockey Canada (TNHC)](https://truenorthhockey.com) team schedules to your own calendar. They add one entry per game, skip games that are already there, and report any time or rink changes.

| Skill | For | Season |
|---|---|---|
| [`mnp-hustlers-schedule`](skills/mnp-hustlers-schedule/SKILL.md) | MNP Hustlers (416 league, Thursday) | Winter only (Sep – Apr) |
| [`unhandled-exceptions-schedule`](skills/unhandled-exceptions-schedule/SKILL.md) | Unhandled Exceptions (905 league, Wednesday) | Winter and summer |
| [`tnhc-hockey-schedule`](skills/tnhc-hockey-schedule/SKILL.md) | Either team, or both | Both |

Supported calendars:
- **Apple Calendar:** needs the Claude desktop app on a Mac, or Claude Code on a Mac.
- **Google Calendar or Outlook:** needs that calendar connected to Claude.
- **Anything else:** Claude can give you an `.ics` calendar file to import into any calendar app.

## Install

### Claude app (web, desktop, mobile)

1. Download the zip for your team from the [latest release](../../releases/latest).
2. In Claude, open **Settings > Capabilities**, scroll to **Skills**, and click **Upload skill**.
3. Pick the zip. Don't unzip it first.

This needs a paid Claude plan (Pro, Max, Team or Enterprise), with code execution and file creation turned on.

### Claude Code

Install it as a plugin:

```
/plugin marketplace add MattPaulG/true-north-hockey
/plugin install true-north-hockey@true-north-hockey
```

Or copy a single skill into your personal skills folder:

```
git clone https://github.com/MattPaulG/true-north-hockey.git
cp -r true-north-hockey/skills/mnp-hustlers-schedule ~/.claude/skills/
```

Restart Claude Code after installing.

## Use

Ask in plain words, for example:

- "Add my hockey schedule to my calendar."
- "Update my MNP Hustlers games."

The first time, Claude asks which calendar app you use, which calendar to add games to, and how to title the events. You can skip the questions by saying it all up front, for example "Add the MNP Hustlers games to my Google Calendar called Hockey."

Run it again whenever you want to pick up schedule changes.

## Requirements

- **Reading the schedule needs a browser.** The schedule tables on truenorthhockey.com load with JavaScript, so Claude needs the [Claude in Chrome](https://claude.ai/chrome) extension or the Claude desktop app to read them. Without either, Claude asks you to paste the schedule table into the chat, and still works from there.
- **The team pages change every season.** Each new season gets a new team page with a new `divteamID`. The skills find the new page through the site's Stats & Schedule menu. If a team isn't listed yet, Claude asks you for the link.

## Repository layout

```
skills/<skill-name>/SKILL.md   one folder per skill
.claude-plugin/marketplace.json  Claude Code plugin marketplace entry
scripts/package-skills.sh      builds an uploadable zip per skill into dist/
.github/workflows/release.yml  attaches the zips to each GitHub release
```

To build the zips locally, run `scripts/package-skills.sh`. To publish them, publish a new release on GitHub with a tag such as `v1.1.0`; the release workflow builds the zips and attaches them to the release.

## Contributing

If a rink, league or page layout changes, open an issue or a pull request with the new details. Keep each skill self-contained: the folder name must match the `name` in its `SKILL.md`.

## License

[MIT](LICENSE). Not affiliated with True North Hockey Canada.
