# AutoCombatLogClassic

World of Warcraft Classic TBC Anniversary addon that automatically starts combat logging (`/combatlog`) when entering a TBC raid or heroic dungeon.

## Features

- **Automatic start** of combat logging when entering a supported instance
- **Automatic resume** after a disconnect while inside the instance
- **Advanced Combat Logging** auto-enabled if disabled (required by Warcraft Logs)
- **Manual stop only** — logs are never stopped automatically
- **RaidWarning notification** displayed on screen when logging starts / resumes / stops
- **Custom settings panel** with a dark flat design, ElvUI compatible
- **Minimap button** with status indicator (active/inactive icon) and detailed tooltip
- **Session history** with date, instance, duration and status
- **Upload reminder** for Warcraft Logs on stop + session duration display
- **Account-wide saved variables**

## Supported Instances

### TBC Raids (enabled by default)

| Raid | Players |
|------|---------|
| Karazhan | 10 |
| Gruul's Lair | 25 |
| Magtheridon's Lair | 25 |
| Serpentshrine Cavern | 25 |
| Tempest Keep: The Eye | 25 |
| Hyjal Summit | 25 |
| Black Temple | 25 |
| Zul'Aman | 10 |
| Sunwell Plateau | 25 |

### TBC Heroic Dungeons (disabled by default)

Hellfire Ramparts, The Blood Furnace, The Shattered Halls, The Slave Pens, The Underbog, The Steamvault, Mana-Tombs, Auchenai Crypts, Sethekk Halls, Shadow Labyrinth, Old Hillsbrad Foothills, The Black Morass, The Mechanar, The Botanica, The Arcatraz, Magisters' Terrace

## Installation

1. Download or clone this repository
2. Copy the folder to your WoW addons directory:
   ```
   World of Warcraft/_anniversary_/Interface/AddOns/AutoCombatLogClassic/
   ```
3. Restart WoW or `/reload`

## Commands

| Command | Description |
|---------|-------------|
| `/acl` | Show help |
| `/acl toggle` | Toggle combat logging |
| `/acl start` | Start combat logging |
| `/acl stop` | Stop combat logging |
| `/acl status` | Show status and duration |
| `/acl history` | Show session history |
| `/acl settings` | Open the settings panel |

## Minimap Button

- **Left click** — Toggle combat logging
- **Right click** — Open settings
- **Tooltip** — Shows status, session duration and current instance

## Settings Panel

The panel is accessible via `/acl settings`, right-clicking the minimap button, or through the WoW interface options.

- **Logging Status** — Real-time status, duration, toggle button
- **TBC Raids** — Per-raid checkboxes with Select All / Deselect All
- **TBC Heroic Dungeons** — Per-dungeon checkboxes
- **Session History** — Table of past sessions (date, instance, duration, status)
- **Minimap** — Option to hide the minimap button

## Project Structure

```
AutoCombatLogClassic/
├── AutoCombatLogClassic.toc  # Manifest
├── Core.lua               # Namespace, events, SavedVariables
├── Skin.lua               # UI helpers (dark flat theme, ElvUI compatible)
├── Instances.lua           # TBC raid and dungeon tables
├── SessionTimer.lua        # Session timer
├── CombatLog.lua           # Detection logic, start/stop/resume, history
├── MinimapButton.lua       # Minimap button (LibDBIcon)
├── Settings.lua            # Custom settings panel
└── Libs/
    ├── LibStub/
    ├── CallbackHandler-1.0/
    ├── LibDataBroker-1.1/
    └── LibDBIcon-1.0/
```

## License

MIT
