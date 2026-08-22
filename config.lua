Config = {}

Config.VendingModels = {
    `prop_vend_soda_01`,
    `prop_vend_coffe_01`,
    `prop_vend_snak_01`,
    `prop_vend_soda_02`
}

Config.RequiredItem = "electronickit"
Config.CooldownSec = 300
Config.ProgressTime = 5000

Config.Security = {
    InteractDistance = 3.0,
    RewardDistance = 4.0,
    SessionTimeoutSec = 90,
    StartRateLimitSec = 2,
    MinRewardDelaySec = 5
}

Config.Minigame = {
    Attempts = 6,
    Timer = 60
}

Config.Dispatch = {
    Enabled = true,
    MinDelayMs = 8000,
    MaxDelayMs = 15000,
    CooldownSec = 60,
    Job = "police",
    Title = "10-09 - Vending Robbery",
    Message = "Suspicious %s attempting to rob a vending machine",
    Blip = {
        sprite = 431,
        scale = 1.0,
        colour = 1,
        flashes = true,
        text = "Vending Robbery",
        time = (5 * 60 * 1000),
        sound = 1
    }
}

Config.Rewards = {
    goldcoins = { min = 2, max = 100 },
    silvercoins = { min = 5, max = 200 },
}

Config.ElectronicKit = {
    UsesBeforeChance = 3,
    BurnChance = 30,  -- نسبة احتراق الأداة بعد عدد معين من الاستخدامات (مثلاً 30%)
}
