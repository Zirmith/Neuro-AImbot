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



return Neuro
