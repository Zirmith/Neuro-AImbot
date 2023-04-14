local Neuro = {}

Neuro.__index = Neuro

function Neuro.new(settings)
    local self = setmetatable({}, Neuro)
    self:hook()
    self.settings = settings or {}
    self.foldername = self.settings.foldername or "Neuro-Trainer"
    self.api = "http://localhost:3000/Neuro/v1/"
    self:Setup()
    return self
end

function Neuro:hook()
    self.Players = game:GetService("Players")
    self.Teams = game:GetService("Teams")
    self.httpserver = request or syn.request or game:GetService("HttpService")
    self.Tween = game:GetService("TweenService")
    self.ReplicatedStorage = game:GetService("ReplicatedStorage")
    self.Marketplace = game:GetService("MarketplaceService")
    self.gameId = game.GameId
    self.PlaceId = game.PlaceId
    self.player = self.Players.LocalPlayer
    self.pchar = self.player.Character or self.player:WaitForChild("Character") or self.player.CharacterAdded:Wait()
    self.HumanoidRootPart, self.Humanoid = self.pchar:WaitForChild("HumanoidRootPart"), self.pchar:WaitForChild("Humanoid")
    self.Health, self.MaxHealth = self.Humanoid.Health, self.Humanoid.MaxHealth
    self.gameName = self:GameName()
end

function Neuro:GameName()
    local gname = self.Marketplace:GetProductInfo(self.PlaceId)["Name"]
    return gname
end


function Neuro:QueryApi(query, meth , userid)
    local response = self.httpserver({
        
            Url = self.api + query,  -- This website helps debug HTTP requests
            Method = meth,
            Headers = {
                ["Content-Type"] = "application/json"  -- When sending JSON, set this!
            },
            Body = game:GetService("HttpService"):JSONEncode({data = userid})
       
    })

   
    if response.Success then
        return response.Body
    else
        warn("Error querying API:", response.StatusCode, response.StatusMessage)
        return nil
    end
end


function Neuro:Log(Message, Type)
    local Timestamp = os.date("%c")
    local MessageTypeColor = Color3.new(1, 1, 1)  -- default color is white

    if Type == "INFO" then
        MessageTypeColor = Color3.new(0, 1, 0)  -- green for info
    elseif Type == "WARN" then
        MessageTypeColor = Color3.new(1, 1, 0)  -- yellow for warnings
    elseif Type == "ERROR" then
        MessageTypeColor = Color3.new(1, 0, 0)  -- red for errors
    end

    -- format the log message
    local LogMessage = string.format("[%s] Neuro: %s", Timestamp, Message)

    -- print the log message with console text color
    local ConsoleTextColor = string.format("%%COLOR%d,%d,%d%%", MessageTypeColor.R*255, MessageTypeColor.G*255, MessageTypeColor.B*255)
    print(LogMessage)
end




function Neuro:Setup()
    Neuro:Log("Starting setup...", "INFO")
    if not isfolder(self.foldername) then
        makefolder(self.foldername)
        Neuro:Log("Created folder: " .. self.foldername, "INFO")
    end
    if not isfolder(self.foldername .. "/configs") then
        makefolder(self.foldername .. "/configs")
        Neuro:Log("Created folder: " .. self.foldername .. "/configs", "INFO")
    end
    if not isfolder(self.foldername .. "/configs/myconfigs") then
        makefolder(self.foldername .. "/configs/myconfigs")
        Neuro:Log("Created folder: " .. self.foldername .. "/configs/myconfigs", "INFO")
    end
    if not isfolder(self.foldername .. "/configs/api_configs") then
        makefolder(self.foldername .. "/configs/api_configs")
        Neuro:Log("Created folder: " .. self.foldername .. "/configs/api_configs", "INFO")
    end
    if not isfolder(self.foldername .. "/games") then
        makefolder(self.foldername .. "/games")
        Neuro:Log("Created folder: " .. self.foldername .. "/games", "INFO")
    end
    if not isfolder(self.foldername .. "/games/tested") then
        makefolder(self.foldername .. "/games/tested")
        Neuro:Log("Created folder: " .. self.foldername .. "/games/tested", "INFO")
    end
    if not isfolder(self.foldername .. "/games/untested") then
        makefolder(self.foldername .. "/games/untested")
        Neuro:Log("Created folder: " .. self.foldername .. "/games/untested", "INFO")
    end
    if not isfolder(self.foldername .. "/games/blacklisted") then
        makefolder(self.foldername .. "/games/blacklisted")
        Neuro:Log("Created folder: " .. self.foldername .. "/games/blacklisted", "INFO")
    end
    if not isfolder(self.foldername .. "/users") then
        makefolder(self.foldername .. "/users")
        Neuro:Log("Created folder: " .. self.foldername .. "/users", "INFO")
    end
    if not isfolder(self.foldername .. "/users/local") then
        makefolder(self.foldername .. "/users/local")
        Neuro:Log("Created folder: " .. self.foldername .. "/users/local", "INFO")
    end
    if not isfolder(self.foldername .. "/users/api") then
        makefolder(self.foldername .. "/users/api")
        Neuro:Log("Created folder: " .. self.foldername .. "/users/api", "INFO")
    end
    
    Neuro:Log("Setup complete.", "INFO")
end



function Neuro:GetNearestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= self.player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (self.player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function Neuro:GetFarthestPlayer()
    local farthestPlayer = nil
    local farthestDistance = 0

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= self.player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (self.player.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance > farthestDistance then
                farthestPlayer = player
                farthestDistance = distance
            end
        end
    end

    return farthestPlayer, farthestDistance
end

function Neuro:Pathfind(destination)
    local path = {}
    local current = self.HumanoidRootPart.Position
    local endPos = destination.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local function IsObstacle(part)
        return part.CanCollide == true or part.Transparency == 0 or part.Name == "Water"
    end

    local function GetSafePosition(position)
        local rayOrigin = position + Vector3.new(0, 5, 0)
        local rayDirection = Vector3.new(0, -10, 0)
        local hit = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if hit and hit.Position.y < position.y then
            return hit.Position
        end
        return position
    end

    while current ~= endPos do
        local direction = (endPos - current).Unit
        local magnitude = (endPos - current).Magnitude
        local raycastResult = workspace:Raycast(current, direction * magnitude, raycastParams)

        if raycastResult then
            table.insert(path, GetSafePosition(raycastResult.Position))
            if raycastResult.Instance.Name == "Water" then
                table.insert(path, GetSafePosition(raycastResult.Instance.Position + Vector3.new(0, 5, 0)))
            end
            current = path[#path]
        else
            table.insert(path, endPos)
            current = endPos
        end
    end

    for i = 1, #path do
        local part = workspace:FindPartOnRay(Ray.new(self.HumanoidRootPart.Position, path[i] - self.HumanoidRootPart.Position))
        if part and IsObstacle(part) then
            local jumpHeight = self.Humanoid.JumpHeight
            if part.Size.y >= jumpHeight then
                table.insert(path, i, GetSafePosition(self.HumanoidRootPart.Position + Vector3.new(0, jumpHeight + 1, 0)))
            elseif part.Size.y >= jumpHeight / 2 then
                table.insert(path, i, GetSafePosition(self.HumanoidRootPart.Position + Vector3.new(0, jumpHeight / 2 + 1, 0)))
            else
                table.remove(path, i)
            end
        end
    end

    return path
end

function Neuro:GetEnemyPlayers()
    local enemies = {}

    for _, player in ipairs(self.Players:GetPlayers()) do
        if player.TeamColor ~= self.player.TeamColor then
            table.insert(enemies, player)
        end
    end

    return enemies
end


function Neuro:LockOn(target)
    local lockonPos = typeof(target) == "Instance" and target.Character and target.Character:WaitForChild("HumanoidRootPart").Position or target
    while wait() do
        if self.pchar and self.HumanoidRootPart and lockonPos then
            local dir = lockonPos - self.HumanoidRootPart.Position
            local cf = CFrame.lookAt(Vector3.new(0, 0, 0), dir)
            self.HumanoidRootPart.CFrame = self.HumanoidRootPart.CFrame:lerp(cf, 0.2)
        end
    end
end

function Neuro:Bhop()
    local jumpPower = self.Humanoid.JumpPower
    local isJumping = false

    self.Humanoid.Jumping:Connect(function(isJump)
        isJumping = isJump
    end)

    self.inputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Space and not gameProcessed then
            if isJumping then
                self.Humanoid.Jump = true
            else
                self.HumanoidRootPart.Velocity = Vector3.new(0, jumpPower, 0)
            end
        end
    end)

    self.runService.RenderStepped:Connect(function()
        if self.inputService:IsKeyDown(Enum.KeyCode.Space) and isJumping then
            self.HumanoidRootPart.Velocity = Vector3.new(self.HumanoidRootPart.Velocity.X, jumpPower, self.HumanoidRootPart.Velocity.Z)
        end
    end)
end


function Neuro:Noclip2()
    self.Noclip = true
    self.Humanoid:ChangeState(11)

    local char = self.pchar
    local rootPart = self.HumanoidRootPart

    char.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            char:Destroy()
            wait(0.1)
            char = self.Players.LocalPlayer.Character or self.Players.LocalPlayer.CharacterAdded:Wait()
            rootPart = char:WaitForChild("HumanoidRootPart")
        end
    end)

    while self.Noclip do
        rootPart.CFrame = self.CFrame + self.CFrame.lookVector * 5
        wait()
    end

    self.Humanoid:ChangeState(15)
end

function Neuro:TweenNoclip(targetPosition, duration)
    local humanoidRootPart = self.pchar.HumanoidRootPart
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    
    local tween = self.Tween:Create(humanoidRootPart, tweenInfo, {CFrame = targetPosition})
    tween:Play()
end


function Neuro:KillPlayer()
    local character = self.player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

function Neuro:ServerHop()
    local TeleportService = game:GetService("TeleportService")
    local success, errorMessage = pcall(function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        local teleportData = TeleportService:GetTeleportSetting("autoJumpEnabled", placeId, jobId)
        if teleportData and teleportData.isAutoJumpEnabled then
            TeleportService:TeleportToPlaceInstance(placeId, teleportData.rootPlaceInstanceId)
        else
            TeleportService:TeleportToPlaceInstance(placeId, jobId)
        end
    end)
    if not success then
        warn("Failed to server hop: " .. errorMessage)
    end
end


function Neuro:Rejoin()
    local TeleportService = game:GetService("TeleportService")
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)
    if not success then
        warn("Failed to rejoin: " .. errorMessage)
    end
end


return Neuro
