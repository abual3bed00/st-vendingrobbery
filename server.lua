QBCore = exports['qb-core']:GetCoreObject()
local theftCount = {}

RegisterNetEvent("vending:reward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not theftCount[src] then
        theftCount[src] = 0
    end

    theftCount[src] = theftCount[src] + 1

    -- Give both reward items with random quantities
    for itemName, data in pairs(Config.Rewards) do
        local amount = math.random(data.min, data.max)
        Player.Functions.AddItem(itemName, amount)
        print("Giving item:", itemName, "Amount:", amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
    end

    -- Check if it's time to apply burn chance
    if theftCount[src] >= Config.ElectronicKit.UsesBeforeChance then
        if math.random(1, 100) <= Config.ElectronicKit.BurnChance then
            local removed = Player.Functions.RemoveItem("electronickit", 1)
            if removed then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["electronickit"], 'remove')
                TriggerClientEvent('QBCore:Notify', src, "The electronic kit got burned!", "error")
            end
            theftCount[src] = 0 -- reset after burn
        end
    end
end)

AddEventHandler("playerDropped", function()
    theftCount[source] = nil
end)

QBCore.Functions.CreateCallback('vending:checkItem', function(source, cb, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local hasItem = Player.Functions.GetItemByName(item) ~= nil
        cb(hasItem)
    else
        cb(false)
    end
end)


-- RegisterNetEvent("vending:reward", function()
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)

--     for itemName, data in pairs(Config.Rewards) do
--         local amount = math.random(data.min, data.max)
--         Player.Functions.AddItem(itemName, amount)
--         TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
--     end
-- end)

RegisterNetEvent("vending:dispatch", function()
    print("[Vending] Dispatch event received")
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    local gender = player.PlayerData.charinfo.gender == 0 and "Male" or "Female"

    TriggerEvent('cd_dispatch:AddNotification', {
        job_table = { "police" },
        coords = coords,
        title = "10-90 - Vending Robbery",
        message = "Suspicious "..gender.." attempting to rob a vending machine",
        flash = 0,
        unique_id = tostring(math.random(1111111,9999999)),
        blip = {
            sprite = 431, -- يمكنك تغييره حسب الرغبة
            scale = 1.0,
            colour = 1,
            flashes = true,
            text = "Vending Robbery",
            time = (5 * 60 * 1000), -- 5 دقائق
            sound = 1
        }
    })
end)

