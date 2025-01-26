repeat task.wait() until game:IsLoaded()
    print("Loaded")
    
    local httpService = game:GetService("HttpService")
    
    local placeID = game.PlaceId
    local teleportService = game:GetService("TeleportService")
    local Found = false

    local function checkForPinata()
        for _, child in ipairs(game:GetService("Workspace").Monsters:GetChildren()) do
            if string.find(child.Name, "Vicious Bee") then
                if checkLevel(child.Name) then
                    Found = true
                    return true
                end
            end
        end
        return false
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
            return httpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeID .. '/servers/Public?sortOrder=Asc&limit=100'))
        end)
        
        if not success or not site or not site.data then
            return
        end
        
        for _, serverData in pairs(site.data) do
            if serverData.maxPlayers > serverData.playing then
                local serverID = tostring(serverData.id)
                local hopSuccess, _ = pcall(function()
                    if Found then
                        sendNotif()
                        return true
                    end
                    queue_on_teleport("_G.Max=" .. _G.Max .. ";_G.Min=" .. _G.Min .. ";" .. game:HttpGet("https://raw.githubusercontent.com/chanmacsoncs/test/refs/heads/main/main.lua"))
                    teleportService:TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
                end)
                if hopSuccess then
                    break
                end
            end
        end
    end
    
    game:GetService("Workspace").Monsters.ChildAdded:Connect(function(child)
        if string.find(child.Name, "Vicious Bee") then
            if checkLevel(child.Name) then
                Found = true
            end
        end
    end)
    
    if not checkForPinata() then
        hop()
    else
        sendNotif()
    end

List = {};
local values = {
    ["k"] = 1000;
    ["m"] = 1000000;
    ["b"] = 1000000000;
    ["t"] = 1000000000000;
    -- and so on... you can fill the rest in if you need to
};
local function AbrToNum(str)
    local num, abr = str:match("^([%d.]+)(%a)$"); -- here we get the number and abbrevation from a string (case doesn't matter)
    if num and abr then -- check if the string format is correct so nothing breaks
        local val = values[abr]; -- get the value from 'values' table
        if val then
            return val * tonumber(num); -- if it exists then multiply number by value and return it
        end
    else
        error("Invalid abbreviation");
    end
end
local function checkForPinata()
    local Booths = game:GetService("Workspace")["__THINGS"].Booths
    for _, Booth in ipairs(Booths:GetChildren()) do
        local PetScroll = Booth.Pets["BoothTop"]["PetScroll"]
        for _, Frame in ipairs(PetScroll:GetChildren()) do
            if Frame:IsA("Frame") then
                local Icon = Frame.Holder.ItemSlot.Icon
                if Icon.Image == "rbxassetid://15938616489" then
                    print("Image Done!")
                    local Price = Frame.Buy.Cost.Text
                    print(Price)
                    print(List)
                    if AbrToNum(Price) < 31000 then
                        List.insert(Frame.Name)
                    end
                end
            end
        end
    end
end

checkForPinata()
for i = 0, 3 do
   print(List[i])
end
