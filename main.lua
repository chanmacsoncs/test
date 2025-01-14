repeat task.wait() until game:IsLoaded()
    print("Loaded")
    
    local httpService = game:GetService("HttpService")
    
    local placeID = game.PlaceId
    local teleportService = game:GetService("TeleportService")
    local Found = false
    
    local function checkLevel(str)
        print(str)
        local level = tonumber(str:match("%d+"))
        if level >= _G.Min and level <= _G.Max then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Level " .. level,
                Text = "",
                Duration = 30
            })
            return true
        end
    end
    local function checkForViciousBee()
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
            Title = "Vicious Bee Hopper",
            Text = "Vicious Bee Has Been Found!",
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
                    queue_on_teleport("_G.Max=" .. _G.Max .. ";_G.Min=" .. _G.Min .. ";" .. game:HttpGet("https://e-z.tools/p/raw/qa6az4va4w"))
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

    local function tween() 
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local tweenService = game:GetService("TweenService")
        
        local goal = {
            Position = Vector3.new(position.X, position.Y + 20, position.Z)
        }
        local tweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = tweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
    end
    
    if not checkForViciousBee() then
        hop()
    else
        sendNotif()
        repeat
            tween()
        until not checkForViciousBee
        hop()
    end
