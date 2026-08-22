local QBCore = exports['qb-core']:GetCoreObject()

local robberyBusy = false
local activeRobbery = nil

local function getMachineTargetData(entity)
    local coords = GetEntityCoords(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, GetEntityModel(entity)
end

local function cancelActiveRobbery(message)
    if activeRobbery and activeRobbery.token then
        TriggerServerEvent("vending:server:CancelRobbery", activeRobbery.token)
    end

    activeRobbery = nil
    robberyBusy = false
    ClearPedTasks(PlayerPedId())

    if message then
        QBCore.Functions.Notify(message, "error")
    end
end

local function startMinigame()
    if not activeRobbery then return end
    local token = activeRobbery.token
    activeRobbery.awaitingResult = true

    local started = pcall(function()
        exports['st-mastermind']:SetAttempts(Config.Minigame.Attempts)
        exports['st-mastermind']:SetTimer(Config.Minigame.Timer)
        exports['st-mastermind']:StartMiniGame()
    end)

    if not started then
        cancelActiveRobbery("The hacking minigame could not be started.")
        return
    end

    TriggerServerEvent("vending:server:ArmDispatch", token)
end

local function startVendingRobbery(entity)
    if robberyBusy then
        QBCore.Functions.Notify("You are already robbing a vending machine.", "error")
        return
    end
    if not entity or not DoesEntityExist(entity) then
        QBCore.Functions.Notify("This machine no longer exists.", "error")
        return
    end

    local resultPromise = promise.new()
    local coords, model = getMachineTargetData(entity)

    QBCore.Functions.TriggerCallback(
        "vending:server:StartRobbery",
        function(success, response)
            resultPromise:resolve({
                success = success,
                response = response
            })
        end,
        coords,
        model
    )

    local result = Citizen.Await(resultPromise)
    if not result.success then
        QBCore.Functions.Notify(result.response or "The vending robbery could not be started.", "error")
        return
    end

    robberyBusy = true
    activeRobbery = {
        token = result.response.token,
        awaitingResult = false
    }

    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, entity, 1000)
    Wait(1000)

    QBCore.Functions.Progressbar(
        "vending_hack",
        "Hacking the machine...",
        Config.ProgressTime,
        false,
        true,
        {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 1
        },
        {},
        {},
        function()
            ClearPedTasks(ped)
            if activeRobbery then
                startMinigame()
            end
        end,
        function()
            cancelActiveRobbery("Action cancelled.")
        end
    )
end

AddEventHandler("st-mastermind:finished", function(success)
    if not activeRobbery or not activeRobbery.awaitingResult then return end

    local token = activeRobbery.token
    activeRobbery = nil
    robberyBusy = false
    ClearPedTasks(PlayerPedId())

    if success then
        TriggerServerEvent("vending:server:ClaimReward", token)
    else
        TriggerServerEvent("vending:server:CancelRobbery", token)
        QBCore.Functions.Notify("You failed the hack!", "error")
    end
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.VendingModels, {
        options = {
            {
                label = "Rob Vending Machine",
                icon = "fas fa-lock",
                action = startVendingRobbery,
                canInteract = function()
                    return not robberyBusy
                end
            }
        },
        distance = 2.0
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    ClearPedTasks(PlayerPedId())
end)
