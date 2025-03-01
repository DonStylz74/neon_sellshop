local Config = Config or {}
local Framework = nil

if Config.Framework == 'ESX' then
    Citizen.CreateThread(function()
        while ESX == nil do
            ESX = exports['es_extended']:getSharedObject()
            Citizen.Wait(100)
        end
        Framework = ESX
    end)
elseif Config.Framework == 'QB' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'QBX' then
    Framework = exports.qbx_core
end

function SetRandomPrices(shop)
    for item, data in pairs(shop.materials) do
        if type(data.price) == "table" then
            local randomPrice = math.random(data.price.min, data.price.max)
            shop.materials[item].price = randomPrice
        else
            shop.materials[item].price = data.price
        end
    end
end


function SetupInteraction(shop)
    if Config.Interaction == 'target' then
        SetupTargetInteraction(shop)
    else
        SetupTextUIInteraction(shop)
    end
end

function SetupTargetInteraction(shop)
    local targetFramework = Config.Target == 'ox_target' and 'ox_target' or 'qb-target'

    if targetFramework == 'ox_target' then
        exports.ox_target:addLocalEntity(shop.ped, {
            {
                name = 'sell_items',
                icon = 'fa-solid fa-coins',
                label = 'Sell Items',
                onSelect = function()
                    OpenSellMenu(shop)
                end
            }
        })             
    elseif targetFramework == 'qb-target' then
        exports['qb-target']:AddTargetEntity(shop.ped, {
            options = {
                {
                    type = "client",
                    event = "neon_sellshop:sell",
                    icon = 'fa-solid fa-coins',
                    label = shop.targetLabel
                }
            },
            distance = 2.5
        })
    end
end

function SetupTextUIInteraction(shop)
    CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local pedCoords = shop.pedCoords
            local dist = #(playerCoords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))

            if dist <= 3.0 then
                lib.showTextUI(shop.targetLabel)

                if IsControlJustPressed(0, 38) then
                    OpenSellMenu(shop)
                end
            else
                lib.hideTextUI()
            end
            Wait(0)
        end
    end)
end

function CreateShop(shop)
    SetRandomPrices(shop)

    local pedHash = GetHashKey(shop.pedModel)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end

    shop.ped = CreatePed(4, pedHash, shop.pedCoords.x, shop.pedCoords.y, shop.pedCoords.z, shop.pedCoords.w, false, true)
    FreezeEntityPosition(shop.ped, true)
    SetEntityInvincible(shop.ped, true)
    SetBlockingOfNonTemporaryEvents(shop.ped, true)

    if shop.blip then
        local blip = AddBlipForCoord(shop.pedCoords.x, shop.pedCoords.y, shop.pedCoords.z)
        SetBlipSprite(blip, shop.blipSettings.sprite)
        SetBlipDisplay(blip, shop.blipSettings.display)
        SetBlipScale(blip, shop.blipSettings.scale)
        SetBlipColour(blip, shop.blipSettings.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.blipSettings.label)
        EndTextCommandSetBlipName(blip)
    end

    SetupInteraction(shop)
end

CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        CreateShop(shop)
    end
end)

local Shops = {}

RegisterNetEvent('neon_sellshop:receiveShopPrices', function(shop)
    Shops[shop.label] = shop
    ShowSellMenu(shop)
end)

function OpenSellMenu(shop)
    if not shop or not shop.materials then
        lib.notify({ type = 'error', description = 'Shop data is missing or incorrect!' })
        return
    end

    TriggerServerEvent('neon_sellshop:requestShopPrices', shop.label)
end

function ShowSellMenu(shop)
    if not shop or not shop.materials then
        lib.notify({ type = 'error', description = 'Shop data is missing or incorrect!' })
        return
    end

    local elements = {}
    local playerInventory = GetPlayerInventory()

    for item, data in pairs(shop.materials or {}) do  
        local count = playerInventory[item] and playerInventory[item].count or 0

        if count > 0 then
            local price = data.price 

            local itemIcon = ('nui://ox_inventory/web/images/%s.png'):format(item)

            table.insert(elements, {
                title = data.name,
                description = ('Total: %s | Price: $%s'):format(count, price),
                event = 'neon_sellshop:sell',
                args = {
                    item = item,
                    count = count,
                    price = price,
                    moneyType = shop.moneyType,
                    shopLabel = shop.label
                },
                icon = itemIcon
            })
        end
    end

    if #elements == 0 then
        lib.notify({ type = 'error', description = "You don't have any materials to sell." })
        return
    end

    lib.registerContext({
        id = 'sell_materials_menu',
        title = shop.label,
        options = elements
    })

    lib.showContext('sell_materials_menu')
end

function GetPlayerInventory()
    if Config.Inventory == 'OX' then
        return exports.ox_inventory:Items()
    end
end

function Notify(message, type)
    lib.notify({ type = type, description = message })
end

RegisterNetEvent('neon_sellshop:sell', function(data)
    local input = lib.inputDialog('Sell Amount', {
        { label = 'Select amount to sell', type = 'slider', min = 1, max = data.count }
    })

    if not input or not tonumber(input[1]) then
        Notify('Invalid amount entered.', 'error')
        return
    end

    local amountToSell = tonumber(input[1])

    if amountToSell > data.count then
        Notify('You don\'t have enough materials.', 'error')
        return
    end

    local payload = {
        item = data.item,
        amount = amountToSell,
        shopLabel = data.shopLabel,
        price = data.price,
        moneyType = data.moneyType
    }

    TriggerServerEvent('neon_sellshop:sellMaterial', payload)
end)
