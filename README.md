# ST Vending Robbery

A secure and configurable vending-machine robbery resource for FiveM servers running QBCore. Players use an electronic kit, complete the ST Mastermind minigame, receive configurable rewards, and may trigger a police dispatch alert.

## Preview

<img width="567" height="604" alt="Vending robbery interaction" src="https://github.com/user-attachments/assets/22c8f469-0afb-49d1-82b4-f27303f5528d" />
<img width="389" height="421" alt="Vending robbery progress" src="https://github.com/user-attachments/assets/f22b7be3-3add-43db-a377-698f8452ab7d" />
<img width="358" height="510" alt="Vending robbery minigame" src="https://github.com/user-attachments/assets/3bab6ee2-d152-4bc4-9335-861ee9992ec1" />
<img width="221" height="148" alt="Vending robbery result" src="https://github.com/user-attachments/assets/d6a5beca-0574-4888-8d24-7c088e7624c1" />

## Author and Support

- Author: `ii_abual3bed | stdev`
- Discord: https://discord.gg/HCskVYZPtB

## Features

- Interaction with configured vending-machine models through `qb-target`
- Configurable required item, progress duration, cooldown, rewards, and minigame difficulty
- Integration with `st-mastermind`
- Optional delayed police alerts through `cd_dispatch`
- Per-machine robbery cooldowns
- Electronic-kit usage counter and configurable burn chance
- Server-authoritative robbery sessions and reward validation
- Distance, model, entity, timing, token, timeout, and rate-limit checks
- Automatic cancellation when the player moves too far away or the resource stops

## Dependencies

- `qb-core`
- `qb-target`
- `progressbar`
- [`st-mastermind`](https://github.com/abual3bed00/st-mastermind)
- `cd_dispatch` when dispatch alerts are enabled

The included `fxmanifest.lua` also contains ElectronAC include lines. Remove those two lines if your server does not use ElectronAC.

## Required Items

The default configuration expects these QBCore shared items:

- `electronickit`: required to start the robbery
- `goldcoins`: configurable reward
- `silvercoins`: configurable reward

Change the item names in `config.lua` if your server uses different names.

## Installation

1. Copy `st-vendingrobbery` into your server resources directory.
2. Install and start all required dependencies.
3. Add the required items to your QBCore shared items.
4. Review and adjust `config.lua`.
5. Add `ensure st-vendingrobbery` to `server.cfg` after its dependencies.
6. Restart the server.

Example start order:

```cfg
ensure qb-core
ensure qb-target
ensure progressbar
ensure st-mastermind
ensure cd_dispatch
ensure st-vendingrobbery
```

## Default Configuration

### General

| Setting | Default | Description |
| --- | ---: | --- |
| `Config.RequiredItem` | `electronickit` | Item required to begin a robbery |
| `Config.CooldownSec` | `300` | Cooldown for each vending machine |
| `Config.ProgressTime` | `5000` | Initial progress duration in milliseconds |

`Config.VendingModels` contains the vending-machine models that can be targeted and validated by the server.

### Minigame

| Setting | Default | Description |
| --- | ---: | --- |
| `Config.Minigame.Attempts` | `6` | Maximum Mastermind attempts |
| `Config.Minigame.Timer` | `60` | Minigame time limit in seconds |

### Security

| Setting | Default | Description |
| --- | ---: | --- |
| `InteractDistance` | `3.0` | Maximum distance when starting |
| `RewardDistance` | `4.0` | Maximum distance when claiming a reward |
| `SessionTimeoutSec` | `90` | Lifetime of a robbery session |
| `StartRateLimitSec` | `2` | Minimum delay between start requests |
| `MinRewardDelaySec` | `5` | Minimum valid delay before claiming rewards |

### Rewards

The default successful robbery reward ranges are:

- `goldcoins`: 2–100
- `silvercoins`: 5–200

Reward items and ranges are configured in `Config.Rewards`.

### Electronic Kit Risk

By default, after every three successful uses there is a 30% chance that the electronic kit is removed. Configure this with:

- `Config.ElectronicKit.UsesBeforeChance`
- `Config.ElectronicKit.BurnChance`

### Dispatch

`Config.Dispatch` controls whether alerts are enabled, their random delay, cooldown, target job, message, sound, and blip settings. Set `Config.Dispatch.Enabled = false` to disable dispatch alerts.

## Robbery Flow

1. The player targets a supported vending machine.
2. The server validates the player, entity, model, distance, item, cooldown, and request rate.
3. The progress animation starts and a delayed dispatch alert is armed.
4. `st-mastermind` opens with the configured attempts and timer.
5. A successful result is validated again by the server.
6. Rewards are granted, the machine cooldown starts, and the electronic-kit risk is processed.

## License

MIT. See `LICENSE`.
