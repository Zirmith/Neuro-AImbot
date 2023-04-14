# Neuro-Aimbot

Neuro Module
The Neuro module is a Lua module that provides utility functions and methods for Roblox Lua scripting.

Installation
To use the Neuro module, you can either copy the code into a script in Roblox Studio or load it from a URL using the loadstring function.

Here is an example of loading the Neuro module from a URL:

```lua
local Neuro = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zirmith/Neuro-AImbot/main/Neuro_Hook.lua"))()


local neuroInstance = Neuro.new({settings = {
    foldername = "test" -- if not name then Deafult is NeuroTrainer   
}})

-- log nearest and farthest players
local closestPlayer, closestDistance = neuroInstance:GetNearestPlayer()
neuroInstance:Log(string.format("Closest player: %s, distance: %.2f", closestPlayer.Name, closestDistance), "INFO")



local farthestPlayer, farthestDistance = neuroInstance:GetFarthestPlayer()
neuroInstance:Log(string.format("Farthest player: %s, distance: %.2f", farthestPlayer.Name, farthestDistance), "INFO")

```



License

The Neuro module is available under the MIT License. See the LICENSE file for more information.
