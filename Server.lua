local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local S_T = game:GetService("TeleportService")
local S_H = game:GetService("HttpService")

local File = pcall(function()
    AllIDs = S_H:JSONDecode(readfile("server-hop-temp.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    pcall(function()
        writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
    end)
end

local function TPReturner(placeId)
    local Site
    if foundAnything == "" then
        Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Desc&limit=100'))
    else
        Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Desc&limit=100&cursor=' .. foundAnything))
    end
    local chosenServer

    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    for _, server in pairs(Site.data) do
        if tonumber(server.maxPlayers) > tonumber(server.playing) then
            chosenServer = server.id
            break -- Stop loop after finding the first suitable server in descending order
        end
    end

    if chosenServer then
        local Possible = true
        for _, Existing in pairs(AllIDs) do
            if chosenServer == tostring(Existing) then
                Possible = false
                break
            end
        end
        if Possible then
            table.insert(AllIDs, chosenServer)
            wait()
            pcall(function()
                writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
                wait()
                S_T:TeleportToPlaceInstance(placeId, chosenServer, game.Players.LocalPlayer)
            end)
            wait(4)
        end
    end
end

local module = {}
function module:Teleport(placeId)
    while wait() do
        pcall(function()
            TPReturner(placeId)
            if foundAnything ~= "" then
                TPReturner(placeId)
            end
        end)
    end
end

return module
