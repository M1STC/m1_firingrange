ESX = exports['es_extended']:getSharedObject()

local leaderboard = {}


print("[Firing Range] Server script loaded.")


ESX.RegisterServerCallback('firingrange:getLeaderboard', function(source, cb)
    print("[Firing Range] Fetching leaderboard data...")
    cb(leaderboard)
end)










RegisterNetEvent('firingrange:fetchLeaderboard')
AddEventHandler('firingrange:fetchLeaderboard', function()
    local _source = source
    MySQL.Async.fetchAll('SELECT name, score FROM firingrange_leaderboard ORDER BY score DESC LIMIT 10', {}, function(results)
        if results and #results > 0 then
           
            local jsonData = json.encode(results)
            TriggerClientEvent('firingrange:updateLeaderboard', _source, jsonData)
        else
           
            TriggerClientEvent('firingrange:updateLeaderboard', _source, "[]")
        end
    end)
end)




RegisterServerEvent('firingrange:saveScore')
AddEventHandler('firingrange:saveScore', function(score)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerName = xPlayer.getName()
        table.insert(leaderboard, { name = playerName, score = score })

     
        table.sort(leaderboard, function(a, b)
            return a.score > b.score
        end)

        
        if #leaderboard > 10 then
            table.remove(leaderboard, #leaderboard)
        end

        print("[Firing Range] Leaderboard Updated:", json.encode(leaderboard))
    else
        print("[Firing Range] ERROR: xPlayer not found while saving score!")
    end
end)


RegisterServerEvent('firingrange:giveWeapon')
AddEventHandler('firingrange:giveWeapon', function(weaponName, ammoCount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        print("[Firing Range] Giving weapon using ox_inventory: " .. weaponName)

    
        local success = exports.ox_inventory:AddItem(source, weaponName, 1, { ammo = ammoCount })

      
        if success then
            print("[Firing Range] Weapon added to inventory successfully.")
            TriggerClientEvent('ox_inventory:useItem', source, weaponName)
            TriggerClientEvent('esx:showNotification', source, 'Weapon received and equipped!')
        else
            print("[Firing Range] ERROR: Failed to add weapon to inventory!")
            TriggerClientEvent('esx:showNotification', source, 'Failed to receive weapon.')
        end
    else
        print("[Firing Range] ERROR: xPlayer not found!")
    end
end)


RegisterServerEvent('firingrange:removeWeapon')
AddEventHandler('firingrange:removeWeapon', function(weaponName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        print("[Firing Range] Removing weapon from ox_inventory: " .. weaponName)

    
        local success = exports.ox_inventory:RemoveItem(source, weaponName, 1)

    
        if success then
            print("[Firing Range] Weapon removed from inventory successfully.")
            TriggerClientEvent('esx:showNotification', source, 'Weapon removed after firing range.')
        else
            print("[Firing Range] ERROR: Failed to remove weapon from inventory!")
        end
    else
        print("[Firing Range] ERROR: xPlayer not found while removing weapon!")
    end
end)

