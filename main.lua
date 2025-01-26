repeat task.wait() until game:IsLoaded()
print("Game Loaded")

local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local starterGui = game:GetService("StarterGui")
local placeID = game.PlaceId
local found = false
local pinataImageID = "rbxassetid://15938616489"
local maxPrice = 31000

-- Global list for storing valid frames
_G.List = {}

-- Abbreviation-to-number mapping
local values = {
    k = 1000,
    m = 1000000,
    b = 1000000000,
    t = 1000000000000,
}

-- Converts abbreviations (e.g., "10k") to numerical values
local function abrToNum(str)
    local num, abr = str:match("^([%d.]+)(%a)$")
    if num and abr then
        local multiplier = values[abr:lower()]
        if multiplier then
            return multiplier * tonumber(num)
        end
    end
    return nil
end

-- Sends a notification to the player
local function sendNotification(text)
    starterGui:SetCore("SendNotification", {
        Title = "Pinata Hopper",
        Text = text,
        Duration = 30
    })
end

-- Checks for Pinata items in booths
local function checkForPinata()
    local booths = game:GetService("Workspace")["__THINGS"].Booths
    for _, booth in ipairs(booths:GetChildren()) do
        local petScroll = booth.Pets["BoothTop"]["PetScroll"]
        for _, frame in ipairs(petScroll:GetChildren()) do
            if frame:IsA("Frame") then
                local icon = frame.Holder.ItemSlot.Icon
                if icon.Image == pinataImageID then
                    print("Pinata Found!")
                    local priceText = frame.Buy.Cost.Text
                    print("Price:", priceText)

                    local numericPrice = abrToNum(priceText)
                    if numericPrice and numericPrice < maxPrice then
                        table.insert(_G.List, frame.Name) -- Add frame name to list
                        found = true
                    end
                end
            end
        end
    end
end

-- Hops between servers to find the item
local function hopServers()
    local success, site = pcall(function()
        return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?limit=100&excludeFullGames=true'))
    end)

    if not success or not site or not site.data then
        return
    end

    for _, serverData in pairs(site.data) do
        if serverData.playing < 25 then
            local serverID = tostring(serverData.id)
            local hopSuccess, _ = pcall(function()
                if found then
                    sendNotification("Pinata Found! Staying on this server.")
                    return true
                end
                teleportService:TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
            end)
            if hopSuccess then break end
        end
    end
end

-- Buys the Pinata from the stored frames
local function buyPinata()
    local booths = game:GetService("Workspace")["__THINGS"].Booths
    for _, name in ipairs(_G.List) do
        for _, booth in ipairs(booths:GetChildren()) do
            local petScroll = booth.Pets["BoothTop"]["PetScroll"]
            for _, frame in ipairs(petScroll:GetChildren()) do
                if frame:IsA("Frame") and frame.Name == name then
                    print("Attempting to purchase Pinata:", name)
                    -- Add your buying logic here
                end
            end
        end
    end
end

-- Main script logic
checkForPinata()
if not found then
    hopServers()
else
    buyPinata()
end
