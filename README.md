# ST Vending Robbery

[العربية](#النسخة-العربية) | [English](#english-version)

## Preview | المعاينة

<img width="567" height="604" alt="Vending robbery interaction" src="https://github.com/user-attachments/assets/22c8f469-0afb-49d1-82b4-f27303f5528d" />
<img width="389" height="421" alt="Vending robbery progress" src="https://github.com/user-attachments/assets/f22b7be3-3add-43db-a377-698f8452ab7d" />
<img width="358" height="510" alt="Vending robbery minigame" src="https://github.com/user-attachments/assets/3bab6ee2-d152-4bc4-9335-861ee9992ec1" />

---

## النسخة العربية

سكربت آمن وقابل للتخصيص لسرقة آلات البيع في سيرفرات FiveM التي تعمل بنظام QBCore. يستخدم اللاعب Electronic Kit، ينفذ تحدي ST Mastermind، يحصل على جوائز قابلة للتعديل، وقد يتم إرسال بلاغ إلى الشرطة.

### المطور والدعم

- المطور: `ii_abual3bed | stdev`
- ديسكورد: https://discord.gg/HCskVYZPtB

### المميزات

- استهداف موديلات آلات البيع المحددة عبر `qb-target`
- تعديل الأداة المطلوبة، وقت التقدم، التبريد، الجوائز وصعوبة التحدي
- ربط كامل مع `st-mastermind`
- بلاغ شرطة متأخر واختياري عبر `cd_dispatch`
- Cooldown مستقل لكل آلة
- عداد استخدام للأداة مع احتمال احتراق قابل للتعديل
- جلسات سرقة وتحقق من الجوائز من جهة السيرفر
- حماية للمسافة، الموديل، الـ entity، التوقيت، token، timeout وrate limit
- إلغاء تلقائي عند ابتعاد اللاعب أو توقف الـ resource

### المتطلبات

- `qb-core`
- `qb-target`
- `progressbar`
- [`st-mastermind`](https://github.com/abual3bed00/st-mastermind)
- `cd_dispatch` عند تفعيل البلاغات

يحتوي `fxmanifest.lua` على أسطر ElectronAC. احذف السطرين إذا كان سيرفرك لا يستخدم ElectronAC.

### الأغراض المطلوبة

الإعداد الافتراضي يعتمد على الأغراض التالية داخل QBCore shared items:

- `electronickit`: مطلوب لبدء السرقة
- `goldcoins`: جائزة قابلة للتعديل
- `silvercoins`: جائزة قابلة للتعديل

يمكن تغيير الأسماء من `config.lua`.

### التثبيت

1. ضع `st-vendingrobbery` داخل مجلد resources.
2. ثبّت وشغّل المتطلبات.
3. أضف الأغراض المطلوبة إلى QBCore shared items.
4. راجع إعدادات `config.lua`.
5. أضف `ensure st-vendingrobbery` بعد المتطلبات في `server.cfg`.

```cfg
ensure qb-core
ensure qb-target
ensure progressbar
ensure st-mastermind
ensure cd_dispatch
ensure st-vendingrobbery
```

### الإعدادات الافتراضية

| الإعداد | القيمة | الوصف |
| --- | ---: | --- |
| `Config.RequiredItem` | `electronickit` | الأداة المطلوبة لبدء السرقة |
| `Config.CooldownSec` | `300` | مدة التبريد لكل آلة بالثواني |
| `Config.ProgressTime` | `5000` | مدة شريط التقدم بالميلي ثانية |
| `Config.Minigame.Attempts` | `6` | عدد محاولات Mastermind |
| `Config.Minigame.Timer` | `60` | وقت التحدي بالثواني |

### الحماية

| الإعداد | القيمة | الوصف |
| --- | ---: | --- |
| `InteractDistance` | `3.0` | أقصى مسافة عند بدء السرقة |
| `RewardDistance` | `4.0` | أقصى مسافة عند استلام الجائزة |
| `SessionTimeoutSec` | `90` | عمر جلسة السرقة |
| `StartRateLimitSec` | `2` | الحد الأدنى بين طلبات البدء |
| `MinRewardDelaySec` | `5` | أقل مدة مسموحة قبل طلب الجائزة |

### الجوائز ومخاطرة الأداة

الجوائز الافتراضية عند النجاح:

- `goldcoins`: من 2 إلى 100
- `silvercoins`: من 5 إلى 200

بعد كل ثلاثة استخدامات ناجحة، يوجد احتمال افتراضي 30% لاحتراق Electronic Kit. يمكن تعديل ذلك من `Config.ElectronicKit`.

### البلاغات

يتحكم `Config.Dispatch` بتفعيل البلاغ، التأخير العشوائي، cooldown البلاغات، الوظيفة المستهدفة، الرسالة، الصوت وإعدادات الـ blip. استخدم `Config.Dispatch.Enabled = false` لتعطيل البلاغات.

### تسلسل السرقة

1. يستهدف اللاعب آلة مدعومة.
2. يتحقق السيرفر من اللاعب، الآلة، الموديل، المسافة، الأداة والـ cooldown.
3. يبدأ شريط التقدم ويتم تجهيز البلاغ المتأخر.
4. تفتح لعبة `st-mastermind` بالإعدادات المحددة.
5. يعيد السيرفر التحقق بعد النجاح.
6. يمنح الجوائز ويبدأ cooldown ويطبق احتمال احتراق الأداة.

---

## English Version

A secure and configurable vending-machine robbery resource for FiveM servers running QBCore. Players use an electronic kit, complete ST Mastermind, receive configurable rewards, and may trigger a police dispatch alert.

### Author and Support

- Author: `ii_abual3bed | stdev`
- Discord: https://discord.gg/HCskVYZPtB

### Features

- Interaction with configured vending models through `qb-target`
- Configurable required item, progress duration, cooldown, rewards, and difficulty
- Full `st-mastermind` integration
- Optional delayed police alerts through `cd_dispatch`
- Independent cooldown for each machine
- Electronic-kit usage counter and configurable burn chance
- Server-authoritative robbery sessions and reward validation
- Distance, model, entity, timing, token, timeout, and rate-limit checks
- Automatic cancellation when the player moves too far away or the resource stops

### Dependencies

- `qb-core`
- `qb-target`
- `progressbar`
- [`st-mastermind`](https://github.com/abual3bed00/st-mastermind)
- `cd_dispatch` when dispatch alerts are enabled

The included `fxmanifest.lua` contains ElectronAC include lines. Remove them if your server does not use ElectronAC.

### Required Items

The default configuration expects these QBCore shared items:

- `electronickit`: required to start a robbery
- `goldcoins`: configurable reward
- `silvercoins`: configurable reward

Item names can be changed in `config.lua`.

### Installation

1. Copy `st-vendingrobbery` into your resources directory.
2. Install and start the dependencies.
3. Add the required items to QBCore shared items.
4. Review `config.lua`.
5. Add `ensure st-vendingrobbery` after its dependencies in `server.cfg`.

```cfg
ensure qb-core
ensure qb-target
ensure progressbar
ensure st-mastermind
ensure cd_dispatch
ensure st-vendingrobbery
```

### Default Settings

| Setting | Default | Description |
| --- | ---: | --- |
| `Config.RequiredItem` | `electronickit` | Item required to begin a robbery |
| `Config.CooldownSec` | `300` | Per-machine cooldown in seconds |
| `Config.ProgressTime` | `5000` | Progress duration in milliseconds |
| `Config.Minigame.Attempts` | `6` | Maximum Mastermind attempts |
| `Config.Minigame.Timer` | `60` | Minigame time limit in seconds |

### Security

| Setting | Default | Description |
| --- | ---: | --- |
| `InteractDistance` | `3.0` | Maximum distance when starting |
| `RewardDistance` | `4.0` | Maximum distance when claiming a reward |
| `SessionTimeoutSec` | `90` | Robbery session lifetime |
| `StartRateLimitSec` | `2` | Minimum delay between start requests |
| `MinRewardDelaySec` | `5` | Minimum valid delay before claiming rewards |

### Rewards and Tool Risk

Default rewards on success:

- `goldcoins`: 2–100
- `silvercoins`: 5–200

After every three successful uses, the electronic kit has a default 30% chance of being removed. Configure this through `Config.ElectronicKit`.

### Dispatch

`Config.Dispatch` controls alert status, random delay, cooldown, target job, message, sound, and blip settings. Set `Config.Dispatch.Enabled = false` to disable alerts.

### Robbery Flow

1. The player targets a supported machine.
2. The server validates the player, entity, model, distance, item, and cooldown.
3. The progress animation starts and delayed dispatch is armed.
4. `st-mastermind` opens with the configured settings.
5. The server validates the successful result again.
6. Rewards are granted, cooldown begins, and electronic-kit risk is processed.

## License | الرخصة

MIT. See `LICENSE`.
