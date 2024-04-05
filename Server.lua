local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local S_T = game:GetService("TeleportService")
local S_H = game:GetService("HttpService")

local function ReadFile()
    local success, data = pcall(readfile, "server-hop-temp.json")
    if success then
        AllIDs = S_H:JSONDecode(data)
    end
end

local function WriteFile(data)
    pcall(function()
        writefile("server-hop-temp.json", S_H:JSONEncode(data))
    end)
end

local function TPReturner(placeId)
    local Site;
    if foundAnything == "" then
        Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local maxPlayersServer = nil
    local maxPlayersCount = 0

    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    for i, v in pairs(Site.data) do
        local Possible = true
        local ID = tostring(v.id)
        local playerCount = tonumber(v.playing)
        
        if playerCount > maxPlayersCount and playerCount < tonumber(v.maxPlayers) then
            maxPlayersServer = ID
            maxPlayersCount = playerCount
        end
    end

    if maxPlayersServer then
        table.insert(AllIDs, maxPlayersServer)
        wait()
        WriteFile(AllIDs)
        wait()
        S_T:TeleportToPlaceInstance(placeId, maxPlayersServer, game.Players.LocalPlayer)
        wait(4)
    end
end

local module = {}
function module:StartTeleport(placeId)
    while true do
        ReadFile()
        TPReturner(placeId)
        if foundAnything ~= "" then
            TPReturner(placeId)
        end
        wait(120) -- 120 seconds = 2 minutes
    end
end

return module
