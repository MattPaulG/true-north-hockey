---
name: tnhc-hockey-schedule
description: Add True North Hockey (TNHC) game schedules for Unhandled Exceptions or MNP Hustlers to the user's own calendar (Apple, Google, Outlook, or an importable .ics file), skipping games already there.
---

# TNHC hockey schedule to calendar

Add the user's upcoming TNHC games to their own calendar. Add one entry per game, and never add a game that is already there. Never edit or delete events that already exist. If an existing game's time or rink has changed, report it so the user can fix it.

## 1. Ask the setup questions

Check the request, earlier messages and memory first. Don't ask for anything the user has already told you. Otherwise, ask with AskUserQuestion, all in one call:

1. **Team:** Unhandled Exceptions (Wednesday), MNP Hustlers (Thursday), or both.
2. **Calendar app:** Apple Calendar (Mac), Google Calendar, Outlook / Microsoft 365, or "Other / just give me a file".
3. **Which calendar:** the name of the calendar to add games to, e.g. "Family" or "Hockey". Skip this for the file option.
4. **Event title:** `<Team> vs <Opponent>` (default), or with a prefix such as `Hockey - <Team> vs <Opponent>`.

After the first run, suggest in one line that they ask Claude to remember their hockey calendar setup, so future runs skip the questions.

## 2. Find this season's team page

| Team | Night | League | Division (2026/27) | Last known page (Winter 2026/27) |
|---|---|---|---|---|
| Unhandled Exceptions | Wednesday | 905 Winter | 905 Wednesday - Recreational Group 4 | https://truenorthhockey.com/Stats/StatsTeamStats?divteamID=1404 |
| MNP Hustlers | Thursday | 416 Winter | 416 Thursday - Recreational Group 6 | https://truenorthhockey.com/Stats/StatsTeamStats?divteamID=1161 |

**Each new season gets a new team page with a new team ID (`divteamID`)**, so a saved link only works for one season. Division group numbers can change too.

1. **Which season applies.** TNHC runs a winter season (September to about April) and a summer season (about May to August), each with its own team pages.
   - **Unhandled Exceptions** play both seasons, so there is a current page all year.
   - **MNP Hustlers** play winter only. From May to August there are no Hustlers games: tell the user the next winter schedule usually appears around September, and skip the team. In late August or September, still check whether the new winter schedule has been posted.
   - Around a season change (late April/May, late August/September), check both the ending and the starting season, so no games are missed.
2. **Try the last known page.** Use it only if the heading shows the right team **and** the current season. For example, "Winter 2026/27" covers Sep 2026 to Apr 2027.
3. **Otherwise find the new page.**
   - Open https://truenorthhockey.com and follow the Stats & Schedule menu to the current season's league for the team: the 905 league (Winter or Summer) for Unhandled Exceptions, normally Wednesday; 416 Winter, Thursday for MNP Hustlers. The summer league may use a different night, so if the team isn't on Wednesday, check the other nights in that league.
   - Read those links from the homepage menu, because they can change too. (In 2026/27 they were /Stats/StatsDivisionTeams?leagueID=2&divgroupID=6 and leagueID=1&divgroupID=7.)
   - On that page, find the link with the team's name. That link is this season's team page.
4. **If the team isn't listed** (the schedule isn't posted yet, or the team changed nights or leagues), say so. Ask the user for the new team page link. Don't guess, and don't use another team's page.
5. **Whenever you use a page other than the last known one,** give its link in the report, so the user can update this skill.

## 3. Read the schedule

The schedule table is filled in by the page's JavaScript, so WebFetch returns only the headers. Use a real browser instead: Claude in Chrome, or the built-in browser in the Claude desktop app. If several Chrome browsers are connected, ask which one to use.
- Open the team page and extract the rows with JavaScript:
  `const t=document.body.innerText; t.substring(t.indexOf('Schedule'), t.indexOf('Team Roster')).replace(/\t+/g,' | ')`
  If the output is cut off, extract again starting from the last date shown.
- Close any tab you opened.
- If no browser is available, tell the user. Ask them to open the team page and paste the schedule table into the chat, then continue from that.

Each row reads: Date | Time | Rink | Home | [score] | Away | [score]. Skip "Bye Week" rows and games before today. The opponent is whichever team is not the user's. The game is Home if the user's team is listed first, Away otherwise.

**Times are PM, Eastern time (America/Toronto).** The site shows 12-hour times without AM/PM, and games run from about 7:00 to 11:xx PM. A time of 12:xx means midnight, so the game starts at 12:xx AM on the following calendar day. Year: in a winter season, Sep–Dec is the first year and Jan–Apr the second; a summer season falls within one year. Each game lasts 1 hour.

## 4. Rink → location

Write the location as `<Rink> - <Arena>, <address>`:
- CAA Centre, 7575 Kennedy Rd S, Brampton, ON L6W 4T2:
  - "Blue Rink" → `Blue Rink`
  - "Red Rink" → `Red Rink`
  - "Spectator" → `Spectator Rink`
  - "Tire World - Gold" → `Gold Rink (Tire World)`
- The Rinx, 65 Orfus Rd, Toronto, ON M6A 1L7: "Rinx N" → `Pad N - The Rinx`
- Ford Performance Centre, 400 Kipling Ave, Toronto, ON M8V 3L1: "Ford PC N" → `Pad N - Ford Performance Centre`
- Any other rink: look up the arena's address with WebSearch and use the same pattern.

Event notes: `Home. <division>` or `Away. <division>`.

## 5. Add to the calendar

First list the games already in the calendar for the season's date range. A game counts as already present if an event on the same date contains both the user's team name and the opponent's name. For a game that is already present, compare its time and rink with the schedule and report any differences. Then add only the missing games.

### Apple Calendar
This needs the Claude desktop app on the user's Mac, using AppleScript (osascript).
- Confirm the calendar name exists: `tell application "Calendar" to return name of every calendar`.
- Read existing events. Try a date-range filter first: `every event of calendar "X" whose start date > d1 and start date < d2`. On large calendars this can fail with an empty error. If it does, read summaries by index range in chunks of 50, working back from the end (`summary of events A thru B of calendar "X"`), and keep going until you are past the season's start. Then read `{start date, location}` for the matching indices as a contiguous range.
- Create one event per osascript call. Batching many events in one call can time out. Build dates with property setters, never by parsing a date string, and don't name variables `div` or `day`:

```applescript
set sd to current date
set day of sd to 1
set year of sd to 2026
set month of sd to 11
set day of sd to 4
set hours of sd to 20
set minutes of sd to 45
set seconds of sd to 0
tell application "Calendar" to make new event at end of events of calendar "Hockey" with properties {summary:"Unhandled Exceptions vs Snipers HC", start date:sd, end date:sd + 3600, location:"Gold Rink (Tire World) - CAA Centre, 7575 Kennedy Rd S, Brampton, ON L6W 4T2", description:"Away. 905 Wednesday - Recreational Group 4"}
```

- If a call fails without an error message, the event may still have been created. Re-read the newest events before retrying.

### Google Calendar
- Use the Google Calendar connector. If it isn't connected, search the connector registry and offer the connection. If the user doesn't want to connect it, use the .ics option instead.
- List the user's calendars and match the name they gave.
- List events in the season's date range, then create the missing ones with timeZone `America/Toronto`.

### Outlook / Microsoft 365
- Use a Microsoft 365 / Outlook calendar connector, with the same steps as Google. If none is available, use the .ics option.

### Other app, or no connection: .ics file
- Write one `.ics` file containing the remaining games for the season.
  - Each event gets a stable UID: `tnhc-<divteamID>-<YYYYMMDD>@truenorthhockey`. If the user imports an updated file later, most calendar apps recognize the same UID and update the existing event instead of adding a duplicate.
  - Use `DTSTART;TZID=America/Toronto` and include a VTIMEZONE block for America/Toronto.
- Send the file to the user. Tell them to open it, or import it into their calendar app, and to pick the right calendar when prompted.

## 6. Report

Keep the report short:
- A table of the games added (date, time, opponent, home/away, rink), or "No new games".
- Any games whose time or rink changed versus what was already in the calendar.
- Any rink you had to look up.
- Any new team page link used this season.

Don't recap the steps you took.
