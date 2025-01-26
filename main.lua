repeat task.wait() until game:IsLoaded()
    print("Loaded")
    
    local httpService = game:GetService("HttpService")
    
    local placeID = game.PlaceId
    local teleportService = game:GetService("TeleportService")
    local Found = false



_G.List = {}
local values = {
    ["k"] = 1000,
    ["m"] = 1000000,
    ["b"] = 1000000000,
    ["t"] = 1000000000000,
    -- Add more abbreviations as needed
}

local function AbrToNum(str)
    local num, abr = str:match("^([%d.]+)(%a)$") -- Extract number and abbreviation
    if num and abr then
        local val = values[abr:lower()] -- Support case-insensitive abbreviations
        if val then
            return val * tonumber(num)
        end
    end
    return nil -- Return nil for invalid abbreviations
end

local function checkForPinata()
    local Booths = game:GetService("Workspace")["__THINGS"].Booths
    for _, Booth in ipairs(Booths:GetChildren()) do
        local PetScroll = Booth.Pets["BoothTop"]["PetScroll"]
        for _, Frame in ipairs(PetScroll:GetChildren()) do
            if Frame:IsA("Frame") then
                local Icon = Frame.Holder.ItemSlot.Icon
                if Icon.Image == "rbxassetid://15938616489" then
                    print("Image Found!")
                    local Price = Frame.Buy.Cost.Text
                    print("Price:", Price)

                    local numericPrice = AbrToNum(Price)
                    if numericPrice and numericPrice < 31000 then
                        _G.List[#_G.List + 1] = Frame.Name -- Add the frame name to the list
                        Found = true
                    end
                end
            end
        end
    end
end

local function sendNotif()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Pinata Hopper",
        Text = "Pinata Has Been Found!",
        Duration = 30
    })
end

local function hop()
    local success, site = pcall(function()
        return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?&limit=100&excludeFullGames=true'))
    end)
    
    if not success or not site or not site.data then
        return
    end
    
    for _, serverData in pairs(site.data) do
        if serverData.playing < 25 then
            local serverID = tostring(serverData.id)
            local hopSuccess, _ = pcall(function()
                if Found then
                    sendNotif()
                    return true
                end
                queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/chanmacsoncs/test/refs/heads/main/main.lua"))
                teleportService:TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
            end)
            if hopSuccess then
                break
            end
        end
    end
end

local function buyPinata()
    for i, name in ipairs(_G.List) do
        local Booths = game:GetService("Workspace")["__THINGS"].Booths
        for _, Booth in ipairs(Booths:GetChildren()) do
            local PetScroll = Booth.Pets["BoothTop"]["PetScroll"]
            for _, Frame in ipairs(PetScroll:GetChildren()) do
                if Frame:IsA("Frame") then
                    if Frame.Name == name then
                        game.Players.LocalPlayer.Character.HumanoidRootPart:PivotTo(Booth:GetPivot())
                    end
                end
            end
        end
    end
end

checkForPinata()
if Found == false then
    hop()
else
    sendNotif()
    buyPinata()
end
