local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

local vendingModels = {
    `prop_vend_soda_01`,
    `prop_vend_coffe_01`,
    `prop_vend_snak_01`,
    `prop_vend_soda_02`
}

for _, model in pairs(vendingModels) do
    exports['qb-target']:AddTargetModel(model, {
        options = {
            {
                label = "Rob Vending Machine",
                icon = "fas fa-lock",
                action = function(entity)
                    if not DoesEntityExist(entity) then
                        QBCore.Functions.Notify("This machine no longer exists.", "error")
                        return
                    end

                    -- نطلب تحكم الشبكة على الكيان
                    NetworkRequestControlOfEntity(entity)
                    local timeout = 0
                    while not NetworkHasControlOfEntity(entity) and timeout < 1000 do
                        Wait(10)
                        timeout = timeout + 10
                    end

                    if not NetworkHasControlOfEntity(entity) then
                        QBCore.Functions.Notify("Failed to get control of the machine.", "error")
                        return
                    end

                    local now = GetGameTimer()
                    local entityId = entity -- نستخدم رقم entity نفسه كمفتاح للكولداون

                    if cooldowns[entityId] and now - cooldowns[entityId] < 300000 then -- 300000 ms = 5 دقائق
                        QBCore.Functions.Notify("You need to wait before robbing this machine again.", "error")
                        return
                    end

                    cooldowns[entityId] = now

                    startVendingRobbery(entity)

                    -- إشعار الشرطة بعد 5 ثواني
                    Citizen.SetTimeout(5000, function()
                        TriggerServerEvent("vending:dispatch")
                    end)
                end,
                canInteract = function()
                    return true
                end,
            }
        },
        distance = 2.0
    })
end

function startVendingRobbery(entity)
    local player = PlayerPedId()

    QBCore.Functions.TriggerCallback('vending:checkItem', function(hasItem)
        if not hasItem then
            QBCore.Functions.Notify("You need an Electronic Kit!", "error")
            return
        end

        TaskTurnPedToFaceEntity(player, entity, 1000)
        Wait(1000)

        QBCore.Functions.Progressbar("vending_hack", "Hacking the machine...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 1,
        }, {}, {}, function()
            TriggerEvent('vending:minigame')
        end, function()
            ClearPedTasks(player)
            QBCore.Functions.Notify("Action cancelled", "error")
        end)
    end, "electronickit")
end

RegisterNetEvent('vending:minigame', function()
    print(">>> vending:minigame event started")
    exports['st-mastermind']:SetAttempts(6)
    exports['st-mastermind']:SetTimer(60)
    exports['st-mastermind']:StartMiniGame()

    -- اسمع على النتيجة
    AddEventHandler("st-mastermind:finished", function(success)
        print(">>> MiniGame finished, success =", success)
        ClearPedTasks(PlayerPedId())
        if success then
            print("Hack succeeded ✅")
            TriggerServerEvent("vending:reward")
        else
            print("Hack failed ❌")
            QBCore.Functions.Notify("You failed the hack!", "error")
        end
    end)
end)


