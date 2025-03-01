local webhookUrl = 'YOUR_WEBHOOK_HERE' -- Replace with your actual Discord Webhook URL

function SendDiscordLog(shopLabel, itemsSold, totalAmount, player)
    local playerName = GetPlayerName(player)

    -- Ensure itemsSold is properly formatted for Discord
    local formattedItems = {}
    for _, item in pairs(itemsSold) do
        table.insert(formattedItems, string.format("- %s: %d", item.name, item.amount))
    end

    -- Default value for empty itemsSold
    local itemsSoldString = #formattedItems > 0 and table.concat(formattedItems, "\n") or "No items sold"

    -- Prepare the embed for Discord
    local embed = {
        {
            ["title"] = "Sell Shop Transaction Log",
            ["color"] = 16711680, -- Red color
            ["fields"] = {
                {
                    ["name"] = "Shop",
                    ["value"] = shopLabel,
                    ["inline"] = true
                },
                {
                    ["name"] = "Total Earnings",
                    ["value"] = "$" .. totalAmount,
                    ["inline"] = true
                },
                {
                    ["name"] = "Items Sold",
                    ["value"] = itemsSoldString,
                    ["inline"] = false
                },
                {
                    ["name"] = "Seller",
                    ["value"] = playerName or "Unknown",
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    -- Send the embed to Discord
    PerformHttpRequest(webhookUrl, function(err, text, headers)
    end, 'POST', json.encode({username = "Sell Shop Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
