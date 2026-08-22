local QBCore = exports['qb-core']:GetCoreObject()

local machineCooldowns = {}
local machineReservations = {}
local activeRobberies = {}
local lastStartAttempt = {}
local lastDispatch = {}
local theftCount = {}
local tokenCounter = 0

local function notify(src, message, messageType)
    TriggerClientEvent('QBCore:Notify', src, message, messageType or "error")
end

local function distanceBetween(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = a.z - b.z
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

local function getPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function normalizeModelHash(model)
    local value = tonumber(model)
    if not value then return nil end
    return value % 4294967296
end

local function isAllowedMachineModel(model)
    model = normalizeModelHash(model)
    if not model then return false end

    for _, allowedModel in ipairs(Config.VendingModels or {}) do
        if normalizeModelHash(allowedModel) == model then
            return true
        end
    end

    return false
end

local function parseMachineTarget(src, coords, model)
    if type(coords) ~= "table" or not isAllowedMachineModel(model) then return nil end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)
    if not x or not y or not z or x ~= x or y ~= y or z ~= z then return nil end

    local machineCoords = vector3(x, y, z)
    local playerCoords = getPlayerCoords(src)
    if not playerCoords then return nil end

    local maxDistance = (Config.Security and Config.Security.InteractDistance) or 3.0
    if distanceBetween(playerCoords, machineCoords) > maxDistance then return nil end

    return {
        coords = machineCoords,
        key = string.format("%.2f:%.2f:%.2f", x, y, z)
    }
end

local function isNearCoords(src, coords, maxDistance)
    local playerCoords = getPlayerCoords(src)
    return playerCoords and distanceBetween(playerCoords, coords) <= maxDistance
end

local function isMachineOnCooldown(machineKey)
    local untilTs = machineCooldowns[machineKey] or 0
    return os.time() < untilTs, untilTs
end

local function clearRobberySession(src)
    local session = activeRobberies[src]
    if session then
        local reservation = machineReservations[session.machineKey]
        if reservation and reservation.token == session.token then
            machineReservations[session.machineKey] = nil
        end
    end
    activeRobberies[src] = nil
end

local function clearExpiredRobberySession(src)
    local session = activeRobberies[src]
    if session and os.time() > session.expiresAt then
        clearRobberySession(src)
        return true
    end
    return false
end

local function sendDispatch(src)
    if not Config.Dispatch.Enabled then return end

    local Player = QBCore.Functions.GetPlayer(src)
    local coords = getPlayerCoords(src)
    if not Player or not coords then return end

    local now = os.time()
    local dispatchCooldown = Config.Dispatch.CooldownSec or 60
    if now - (lastDispatch[src] or 0) < dispatchCooldown then return end
    lastDispatch[src] = now

    local charinfo = Player.PlayerData.charinfo or {}
    local gender = charinfo.gender == 0 and "Male" or "Female"
    local blip = Config.Dispatch.Blip

    TriggerEvent('cd_dispatch:AddNotification', {
        job_table = { Config.Dispatch.Job },
        coords = coords,
        title = Config.Dispatch.Title,
        message = string.format(Config.Dispatch.Message, gender),
        flash = 0,
        unique_id = tostring(math.random(1111111, 9999999)),
        blip = {
            sprite = blip.sprite,
            scale = blip.scale,
            colour = blip.colour,
            flashes = blip.flashes,
            text = blip.text,
            time = blip.time,
            sound = blip.sound
        }
    })
end

local function giveRewards(src, Player)
    for itemName, reward in pairs(Config.Rewards or {}) do
        local minimum = math.max(1, tonumber(reward.min) or 1)
        local maximum = math.max(minimum, tonumber(reward.max) or minimum)
        local amount = math.random(minimum, maximum)
        local added = Player.Functions.AddItem(itemName, amount)

        if added then
            if QBCore.Shared.Items[itemName] then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add', amount)
            end
            notify(src, ("You got x%s %s"):format(amount, itemName), "success")
        else
            notify(src, ("Not enough inventory space for %s."):format(itemName), "error")
        end
    end
end

local function applyElectronicKitWear(src, Player)
    local citizenId = Player.PlayerData.citizenid or ("source:%s"):format(src)
    theftCount[citizenId] = (theftCount[citizenId] or 0) + 1

    local usesBeforeChance = math.max(1, tonumber(Config.ElectronicKit.UsesBeforeChance) or 1)
    if theftCount[citizenId] < usesBeforeChance then return end

    local burnChance = math.max(0, math.min(100, tonumber(Config.ElectronicKit.BurnChance) or 0))
    if math.random(1, 100) > burnChance then return end

    local removed = Player.Functions.RemoveItem(Config.RequiredItem, 1)
    if removed then
        if QBCore.Shared.Items[Config.RequiredItem] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RequiredItem], 'remove', 1)
        end
        notify(src, "The electronic kit got burned!", "error")
    end
    theftCount[citizenId] = 0
end

QBCore.Functions.CreateCallback("vending:server:StartRobbery", function(src, cb, machineCoords, machineModel)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        cb(false, "Player data is unavailable.")
        return
    end

    local now = os.time()
    local rateLimit = (Config.Security and Config.Security.StartRateLimitSec) or 2
    if now - (lastStartAttempt[src] or 0) < rateLimit then
        cb(false, "Please wait before trying again.")
        return
    end
    lastStartAttempt[src] = now

    clearExpiredRobberySession(src)
    if activeRobberies[src] then
        cb(false, "You already have an active vending robbery.")
        return
    end

    local target = parseMachineTarget(src, machineCoords, machineModel)
    if not target then
        cb(false, "Invalid vending machine or you are too far away.")
        return
    end

    local onCooldown, untilTs = isMachineOnCooldown(target.key)
    if onCooldown then
        cb(false, ("This machine is on cooldown for %d more seconds."):format(math.max(1, untilTs - now)))
        return
    end

    local reservation = machineReservations[target.key]
    if reservation and now > reservation.expiresAt then
        machineReservations[target.key] = nil
        reservation = nil
    end
    if reservation then
        cb(false, "Someone is already robbing this machine.")
        return
    end

    if not Player.Functions.GetItemByName(Config.RequiredItem) then
        cb(false, "You need an Electronic Kit.")
        return
    end

    tokenCounter = tokenCounter + 1
    local token = ("%d:%d:%d:%d"):format(src, now, tokenCounter, math.random(100000, 999999))
    local timeout = (Config.Security and Config.Security.SessionTimeoutSec) or 90
    local session = {
        token = token,
        machineKey = target.key,
        coords = target.coords,
        startedAt = now,
        expiresAt = now + timeout,
        dispatchArmed = false
    }

    activeRobberies[src] = session
    machineReservations[target.key] = {
        source = src,
        token = token,
        expiresAt = session.expiresAt
    }

    cb(true, { token = token })
end)

RegisterNetEvent("vending:server:ArmDispatch", function(token)
    local src = source
    local session = activeRobberies[src]
    if not Config.Dispatch.Enabled then return end
    if not session or type(token) ~= "string" or session.token ~= token then return end
    if session.dispatchArmed or os.time() > session.expiresAt then return end

    local minimumStartTime = math.ceil((Config.ProgressTime or 5000) / 1000)
    if os.time() - session.startedAt < minimumStartTime then return end

    session.dispatchArmed = true

    local minimumDelay = math.max(0, tonumber(Config.Dispatch.MinDelayMs) or 8000)
    local maximumDelay = math.max(minimumDelay, tonumber(Config.Dispatch.MaxDelayMs) or 15000)
    local delay = math.random(minimumDelay, maximumDelay)

    SetTimeout(delay, function()
        sendDispatch(src)
    end)
end)

RegisterNetEvent("vending:server:CancelRobbery", function(token)
    local src = source
    local session = activeRobberies[src]
    if not session or type(token) ~= "string" or session.token ~= token then return end
    clearRobberySession(src)
end)

RegisterNetEvent("vending:server:ClaimReward", function(token)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if clearExpiredRobberySession(src) then
        notify(src, "The vending robbery session expired.", "error")
        return
    end

    local session = activeRobberies[src]
    if not session or type(token) ~= "string" or session.token ~= token then
        notify(src, "No valid vending robbery session was found.", "error")
        return
    end

    local now = os.time()
    local minimumDelay = (Config.Security and Config.Security.MinRewardDelaySec) or 5
    if now - session.startedAt < minimumDelay then
        notify(src, "The robbery was completed too quickly.", "error")
        clearRobberySession(src)
        return
    end

    local rewardDistance = (Config.Security and Config.Security.RewardDistance) or 4.0
    if not isNearCoords(src, session.coords, rewardDistance) then
        notify(src, "You moved too far away from the vending machine.", "error")
        clearRobberySession(src)
        return
    end

    local reservation = machineReservations[session.machineKey]
    if not reservation or reservation.source ~= src or reservation.token ~= session.token then
        notify(src, "This vending robbery is no longer valid.", "error")
        clearRobberySession(src)
        return
    end

    local onCooldown = isMachineOnCooldown(session.machineKey)
    if onCooldown then
        notify(src, "This vending machine was already robbed recently.", "error")
        clearRobberySession(src)
        return
    end

    if not Player.Functions.GetItemByName(Config.RequiredItem) then
        notify(src, "You no longer have an Electronic Kit.", "error")
        clearRobberySession(src)
        return
    end

    local machineKey = session.machineKey
    clearRobberySession(src)
    machineCooldowns[machineKey] = now + (Config.CooldownSec or 300)

    giveRewards(src, Player)
    applyElectronicKitWear(src, Player)
end)

AddEventHandler("playerDropped", function()
    local src = source
    clearRobberySession(src)
    lastStartAttempt[src] = nil
    lastDispatch[src] = nil
end)
