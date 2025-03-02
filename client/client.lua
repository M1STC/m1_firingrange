ESX = exports['es_extended']:getSharedObject()

local playerScore = 0
local activeTarget = nil
local isInFiringRange = false
local timeLeft = 30
local countdownStarted = false


function openFiringRangeMenu()
    TriggerServerEvent('firingrange:fetchLeaderboard')
    SetTimeout(500, function() 
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "openMenu" })
    end)
end

RegisterNetEvent('firingrange:updateLeaderboard')
AddEventHandler('firingrange:updateLeaderboard', function(jsonData)
    print("[DEBUG] Leaderboard JSON Data Received: ", jsonData) 
    local leaderboard = json.decode(jsonData) or {}

    -- Debug Log to Confirm Data Format
    for i, entry in ipairs(leaderboard) do
        print(string.format("[DEBUG] Leaderboard Entry %d: Name=%s, Score=%d", i, entry.name, entry.score))
    end

    SendNUIMessage({
        action = "updateLeaderboard",
        leaderboard = leaderboard
    })
end)



RegisterNUICallback("closeMenu", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeMenu" })
    cb("ok")
end)

RegisterNetEvent('firingrange:updateLeaderboard')
AddEventHandler('firingrange:updateLeaderboard', function(jsonData)
    local leaderboard = json.decode(jsonData) or {}
    SendNUIMessage({
        action = "updateLeaderboard",
        leaderboard = leaderboard
    })
end)

RegisterNUICallback("startFiringRange", function(data, cb)
    isInFiringRange = true
    countdownStarted = false 

    local randomLocation = Config.TeleportCoords[math.random(#Config.TeleportCoords)]
    SetEntityCoords(PlayerPedId(), randomLocation.x, randomLocation.y, randomLocation.z)
    SetEntityHeading(PlayerPedId(), randomLocation.h)

    playerScore = 0
    timeLeft = 30

    TriggerServerEvent('firingrange:giveWeapon', 'weapon_pistol', 100)

    SetTimeout(1500, function()
        local playerPed = PlayerPedId()
        local weaponHash = GetHashKey("WEAPON_PISTOL")

        TriggerEvent('ox_inventory:useItem', 'weapon_pistol')

        if HasPedGotWeapon(playerPed, weaponHash, false) then
            SetCurrentPedWeapon(playerPed, weaponHash, true)
            print("[Firing Range] Weapon successfully equipped.")
        else
            print("[Firing Range] WARNING: Weapon not found! Retrying with native method...")
            GiveWeaponToPed(playerPed, weaponHash, 100, false, true)
            SetCurrentPedWeapon(playerPed, weaponHash, true)
        end
    end)

    spawnTarget()
    Wait(2000)
    startTimer()
    cb("ok")
end)

RegisterNUICallback("stopFiringRange", function(data, cb)
    endFiringRange()
    cb("ok")
end)

function endFiringRange()
    isInFiringRange = false
    SetEntityCoords(PlayerPedId(), Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z)
    SetEntityHeading(PlayerPedId(), Config.MarkerHeading)

    local weaponHash = GetHashKey("WEAPON_PISTOL")
    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) then
        RemoveWeaponFromPed(PlayerPedId(), weaponHash)
    end

    TriggerServerEvent('firingrange:removeWeapon', 'weapon_pistol')

    
    TriggerServerEvent('firingrange:saveScore', playerScore)
    clearTarget()

    
    timeLeft = 30
    playerScore = 0
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.MarkerCoords)

        if distance < 10.0 then
            DrawMarker(Config.MarkerType, Config.MarkerCoords.x, Config.MarkerCoords.y, Config.MarkerCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerHeading, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
            if distance < 1.5 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open Firing Range Menu")
                if IsControlJustReleased(1, 51) then 
                    openFiringRangeMenu()
                end
            end
        end
        Wait(0)
    end
end)


function startTimer()
    CreateThread(function()
        countdownStarted = true
        while isInFiringRange and timeLeft > 0 do
            Wait(1000)
            timeLeft = timeLeft - 1
        end
        if timeLeft <= 0 then
            endFiringRange()
        end
    end)
end


CreateThread(function()
    while true do
        if isInFiringRange then
            DrawTxt("Score: " .. playerScore, 0.85, 0.05, 0.4, 0.4, 255, 255, 255, 255)
            DrawTxt("Time Left: " .. timeLeft .. "s", 0.85, 0.08, 0.4, 0.4, 255, 255, 255, 255)
        end
        Wait(0)
    end
end)


function spawnTarget()
    clearTarget()
    local coords = Config.TargetCoords[math.random(#Config.TargetCoords)]
    local model = GetHashKey("s_m_m_movalien_01")

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    activeTarget = CreatePed(4, model, coords.x, coords.y, coords.z, coords.h, false, true)
    SetEntityAsMissionEntity(activeTarget, true, true)
    SetBlockingOfNonTemporaryEvents(activeTarget, true)
    SetPedCanRagdoll(activeTarget, false)
    SetEntityInvincible(activeTarget, false)
    TaskStandStill(activeTarget, -1)
    SetPedDropsWeaponsWhenDead(activeTarget, false)
end


function clearTarget()
    if activeTarget and DoesEntityExist(activeTarget) then
        DeleteEntity(activeTarget)
        activeTarget = nil
    end
end

CreateThread(function()
    while true do
        if isInFiringRange and activeTarget then
            if HasEntityBeenDamagedByEntity(activeTarget, PlayerPedId(), true) then
                local boneIndex = GetPedLastDamageBone(activeTarget)
                local headshot = (boneIndex == HEAD_BONE)

                playerScore = playerScore + (headshot and 20 or 10)
                ESX.ShowNotification(headshot and "Headshot! +20 Points!" or "Target Hit! +10 Points!")

                ClearEntityLastDamageEntity(activeTarget)
                clearTarget()
                Wait(1000)
                spawnTarget()
            end
        end
        Wait(100)
    end
end)
