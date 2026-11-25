# Rofl's Self Destruct

Adds an **Ignore for this session** button to enchant / bind safety popups. Click it once and matching warnings auto-accept until you `/reload`, log out, or run `/rsd reset`.

Nothing is saved between sessions (no SavedVariables).

## What it ignores

Only these StaticPopup warnings, and only after you click **Ignore for this session**:

- Replace enchant
- Bind on enchant
- Trade replace enchant
- Action will bind item
- Replace tradeskill enchant

## What it won't ignore

- Any other confirmation, loot, vendor, mail, or group popup
- The same warnings again after `/reload` or logout (until you click Ignore again)
- Warnings before you’ve clicked Ignore this session

## Commands

| Command | Effect |
|---------|--------|
| `/rsd reset` | Show warnings again this session |
| `/rsd status` | Check whether ignore is on |
| `/rsd` | Help |
