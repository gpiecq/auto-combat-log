# AutoCombatLog

Addon World of Warcraft Classic TBC Anniversary qui démarre automatiquement le combat log (`/combatlog`) à l'entrée dans un raid ou donjon héroïque TBC.

## Fonctionnalités

- **Démarrage automatique** du combat log à l'entrée dans une instance éligible
- **Reprise automatique** après une reconnexion dans l'instance
- **Arrêt manuel uniquement** — les logs ne s'arrêtent jamais automatiquement
- **Notification RaidWarning** au centre de l'écran lors du démarrage / reprise / arrêt
- **Panneau de settings** custom avec design dark flat compatible ElvUI
- **Bouton minimap** avec indicateur de statut (icône active/inactive), tooltip détaillé
- **Historique des sessions** avec date, instance, durée et statut
- **Rappel d'upload** Warcraft Logs à l'arrêt + affichage de la durée de session
- **Sauvegarde partagée** au niveau du compte

## Instances supportées

### Raids TBC (activés par défaut)

| Raid | Joueurs |
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

### Donjons héroïques TBC (désactivés par défaut)

Hellfire Ramparts, The Blood Furnace, The Shattered Halls, The Slave Pens, The Underbog, The Steamvault, Mana-Tombs, Auchenai Crypts, Sethekk Halls, Shadow Labyrinth, Old Hillsbrad Foothills, The Black Morass, The Mechanar, The Botanica, The Arcatraz, Magisters' Terrace

## Installation

1. Télécharger ou cloner ce dépôt
2. Copier le dossier dans le répertoire d'addons WoW :
   ```
   World of Warcraft/_classic_/Interface/AddOns/AutoCombatLog/
   ```
3. Relancer WoW ou `/reload`

## Commandes

| Commande | Description |
|----------|-------------|
| `/acl` | Affiche l'aide |
| `/acl toggle` | Active / désactive le combat log |
| `/acl start` | Démarre le combat log |
| `/acl stop` | Arrête le combat log |
| `/acl status` | Affiche le statut et la durée |
| `/acl history` | Affiche l'historique des sessions |
| `/acl settings` | Ouvre le panneau de configuration |

## Bouton minimap

- **Clic gauche** — Toggle le combat log
- **Clic droit** — Ouvre les settings
- **Tooltip** — Affiche le statut, la durée de session et l'instance en cours

## Panneau de settings

Le panneau est accessible via `/acl settings`, clic droit sur le bouton minimap, ou dans les options d'interface WoW.

- **Logging Status** — Statut en temps réel, durée, bouton toggle
- **TBC Raids** — Checkboxes par raid avec Select All / Deselect All
- **TBC Heroic Dungeons** — Checkboxes par donjon héroïque
- **Session History** — Tableau des sessions passées (date, instance, durée, statut)
- **Minimap** — Option pour masquer le bouton minimap

## Structure du projet

```
AutoCombatLog/
├── AutoCombatLog.toc      # Manifeste
├── Core.lua               # Namespace, événements, SavedVariables
├── Skin.lua               # Helpers UI (dark flat theme, compatible ElvUI)
├── Instances.lua           # Tables des raids et donjons TBC
├── SessionTimer.lua        # Chronomètre de session
├── CombatLog.lua           # Logique de détection, start/stop/resume, historique
├── MinimapButton.lua       # Bouton minimap (LibDBIcon)
├── Settings.lua            # Panneau de configuration custom
└── Libs/
    ├── LibStub/
    ├── CallbackHandler-1.0/
    ├── LibDataBroker-1.1/
    └── LibDBIcon-1.0/
```

## Licence

MIT
