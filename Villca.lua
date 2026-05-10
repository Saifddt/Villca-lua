-- ============================================================
-- VILLCA COMPLETO - NOCHE + SHIFT LOCK + MIRA
-- Unión de ambos scripts optimizada para Delta Mobile
-- ============================================================

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- CONFIGURACIÓN / GUARDADO
-- ============================================================
local currentFOV = 80
local brightness = 1
local cartoonEnabled = false
local stretchEnabled = false
local panelVisible = true
local removeSkinsEnabled = false

local function saveSettings()
    local settingsText = "FOV=" .. currentFOV .. "\n"
    settingsText = settingsText .. "Brightness=" .. brightness .. "\n"
    settingsText = settingsText .. "CartoonEnabled=" .. tostring(cartoonEnabled) .. "\n"
    settingsText = settingsText .. "StretchEnabled=" .. tostring(stretchEnabled) .. "\n"
    settingsText = settingsText .. "RemoveSkinsEnabled=" .. tostring(removeSkinsEnabled)
    pcall(function() writefile("VILLCA_Settings.txt", settingsText) end)
end

local function loadSettings()
    local success, fileContent = pcall(function() return readfile("VILLCA_Settings.txt") end)
    if success and fileContent then
        for line in fileContent:gmatch("[^\r\n]+") do
            local key, value = line:match("([^=]+)=(.+)")
            if key and value then
                if key == "FOV" then currentFOV = tonumber(value) or currentFOV
                elseif key == "Brightness" then brightness = tonumber(value) or brightness
                elseif key == "CartoonEnabled" then cartoonEnabled = (value == "true")
                elseif key == "StretchEnabled" then stretchEnabled = (value == "true")
                elseif key == "RemoveSkinsEnabled" then removeSkinsEnabled = (value == "true")
                end
            end
        end
        return true
    end
    return false
end

-- Guardado Shift Lock / Mira
local FILE_NAME = "VillcaConfig.json"
local MiraData = {
    MiraHabilitada = true,
    MiraSize = 4,
    MiraPos = UDim2.new(0.5, 0, 0.5, 0),
    ButtonPos = UDim2.new(1, -50, 0.5, -20)
}

local function SaveMira()
    local cfg = {
        MiraHabilitada = MiraData.MiraHabilitada,
        MiraSize = MiraData.MiraSize,
        MiraPos = {MiraData.MiraPos.X.Scale, MiraData.MiraPos.X.Offset, MiraData.MiraPos.Y.Scale, MiraData.MiraPos.Y.Offset},
        ButtonPos = {MiraData.ButtonPos.X.Scale, MiraData.ButtonPos.X.Offset, MiraData.ButtonPos.Y.Scale, MiraData.ButtonPos.Y.Offset}
    }
    if writefile then writefile(FILE_NAME, HttpService:JSONEncode(cfg)) end
end

local function LoadMira()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(readfile, FILE_NAME)
        if success then
            local decoded = HttpService:JSONDecode(content)
            if decoded.MiraHabilitada ~= nil then MiraData.MiraHabilitada = decoded.MiraHabilitada end
            if decoded.MiraSize then MiraData.MiraSize = decoded.MiraSize end
            if decoded.MiraPos then MiraData.MiraPos = UDim2.new(decoded.MiraPos[1], decoded.MiraPos[2], decoded.MiraPos[3], decoded.MiraPos[4]) end
            if decoded.ButtonPos then MiraData.ButtonPos = UDim2.new(decoded.ButtonPos[1], decoded.ButtonPos[2], decoded.ButtonPos[3], decoded.ButtonPos[4]) end
        end
    end
end

-- ============================================================
-- GUI PRINCIPAL
-- ============================================================
if game.CoreGui:FindFirstChild("MobileFOV") then game.CoreGui.MobileFOV:Destroy() end
if player.PlayerGui:FindFirstChild("VillcaShiftLock") then player.PlayerGui.VillcaShiftLock:Destroy() end

-- ScreenGui NOCHE (CoreGui)
local NocheGui = Instance.new("ScreenGui")
NocheGui.Parent = game.CoreGui
NocheGui.Name = "MobileFOV"

-- ScreenGui SHIFT LOCK (PlayerGui)
local ShiftGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ShiftGui.Name = "VillcaShiftLock"
ShiftGui.ResetOnSpawn = false

-- ============================================================
-- PANEL NOCHE
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = NocheGui
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = MainFrame
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -20, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
MinimizeBtn.Text = "_"; MinimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeBtn.TextSize = 14; MinimizeBtn.ZIndex = 2

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.BackgroundTransparency = 0.3
Title.Text = "📱 VILLCA NOCHE"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 12; Title.Font = Enum.Font.GothamBold; Title.ZIndex = 2

local FOVText = Instance.new("TextLabel")
FOVText.Parent = MainFrame
FOVText.Size = UDim2.new(1, 0, 0, 20)
FOVText.Position = UDim2.new(0, 0, 0.1, 0)
FOVText.BackgroundTransparency = 1
FOVText.Text = "FOV: 80"
FOVText.TextColor3 = Color3.fromRGB(0,255,0)
FOVText.TextSize = 14; FOVText.Font = Enum.Font.GothamBold; FOVText.ZIndex = 2

local FOVPlus = Instance.new("TextButton")
FOVPlus.Parent = MainFrame
FOVPlus.Size = UDim2.new(0.45, 0, 0, 25)
FOVPlus.Position = UDim2.new(0.05, 0, 0.18, 0)
FOVPlus.BackgroundColor3 = Color3.fromRGB(0,100,200)
FOVPlus.BackgroundTransparency = 0.2
FOVPlus.Text = "FOV +"; FOVPlus.TextColor3 = Color3.fromRGB(255,255,255)
FOVPlus.TextSize = 12; FOVPlus.ZIndex = 2

local FOVMinus = Instance.new("TextButton")
FOVMinus.Parent = MainFrame
FOVMinus.Size = UDim2.new(0.45, 0, 0, 25)
FOVMinus.Position = UDim2.new(0.5, 0, 0.18, 0)
FOVMinus.BackgroundColor3 = Color3.fromRGB(200,50,50)
FOVMinus.BackgroundTransparency = 0.2
FOVMinus.Text = "FOV -"; FOVMinus.TextColor3 = Color3.fromRGB(255,255,255)
FOVMinus.TextSize = 12; FOVMinus.ZIndex = 2

local BrightText = Instance.new("TextLabel")
BrightText.Parent = MainFrame
BrightText.Size = UDim2.new(1, 0, 0, 15)
BrightText.Position = UDim2.new(0, 0, 0.3, 0)
BrightText.BackgroundTransparency = 1
BrightText.Text = "🌙 Brillo: 1 (NOCHE EXTREMA)"
BrightText.TextColor3 = Color3.fromRGB(100,100,100)
BrightText.TextSize = 10; BrightText.ZIndex = 2

local BrightPlus = Instance.new("TextButton")
BrightPlus.Parent = MainFrame
BrightPlus.Size = UDim2.new(0.45, 0, 0, 20)
BrightPlus.Position = UDim2.new(0.05, 0, 0.36, 0)
BrightPlus.BackgroundColor3 = Color3.fromRGB(60,60,80)
BrightPlus.BackgroundTransparency = 0.3
BrightPlus.Text = "Brillo +"; BrightPlus.TextColor3 = Color3.fromRGB(150,150,150)
BrightPlus.TextSize = 10; BrightPlus.ZIndex = 2

local BrightMinus = Instance.new("TextButton")
BrightMinus.Parent = MainFrame
BrightMinus.Size = UDim2.new(0.45, 0, 0, 20)
BrightMinus.Position = UDim2.new(0.5, 0, 0.36, 0)
BrightMinus.BackgroundColor3 = Color3.fromRGB(60,60,80)
BrightMinus.BackgroundTransparency = 0.3
BrightMinus.Text = "Brillo -"; BrightMinus.TextColor3 = Color3.fromRGB(150,150,150)
BrightMinus.TextSize = 10; BrightMinus.ZIndex = 2

local StretchBtn = Instance.new("TextButton")
StretchBtn.Parent = MainFrame
StretchBtn.Size = UDim2.new(0.9, 0, 0, 22)
StretchBtn.Position = UDim2.new(0.05, 0, 0.46, 0)
StretchBtn.BackgroundColor3 = Color3.fromRGB(80,60,120)
StretchBtn.BackgroundTransparency = 0.2
StretchBtn.Text = "🖥️ STRETCH: OFF"; StretchBtn.TextColor3 = Color3.fromRGB(255,100,100)
StretchBtn.TextSize = 11; StretchBtn.ZIndex = 2

local CartoonBtn = Instance.new("TextButton")
CartoonBtn.Parent = MainFrame
CartoonBtn.Size = UDim2.new(0.9, 0, 0, 22)
CartoonBtn.Position = UDim2.new(0.05, 0, 0.56, 0)
CartoonBtn.BackgroundColor3 = Color3.fromRGB(80,60,80)
CartoonBtn.BackgroundTransparency = 0.2
CartoonBtn.Text = "🎨 CARTÓN: OFF"; CartoonBtn.TextColor3 = Color3.fromRGB(255,100,100)
CartoonBtn.TextSize = 11; CartoonBtn.ZIndex = 2

local SkinsBtn = Instance.new("TextButton")
SkinsBtn.Parent = MainFrame
SkinsBtn.Size = UDim2.new(0.9, 0, 0, 22)
SkinsBtn.Position = UDim2.new(0.05, 0, 0.66, 0)
SkinsBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
SkinsBtn.BackgroundTransparency = 0.2
SkinsBtn.Text = "👤 QUITAR SKINS: OFF"; SkinsBtn.TextColor3 = Color3.fromRGB(255,100,100)
SkinsBtn.TextSize = 11; SkinsBtn.ZIndex = 2

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0.9, 0, 0, 20)
CloseBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "❌ CERRAR PANEL"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 11; CloseBtn.ZIndex = 2

local Status = Instance.new("TextLabel")
Status.Parent = MainFrame
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.86, 0)
Status.BackgroundTransparency = 1
Status.Text = "✅ LISTO"
Status.TextColor3 = Color3.fromRGB(0,255,0)
Status.TextSize = 9; Status.TextWrapped = true; Status.ZIndex = 2

-- ============================================================
-- PANEL SHIFT LOCK (panel secundario derecho)
-- ============================================================
local ShiftFrame = Instance.new("Frame", ShiftGui)
ShiftFrame.BackgroundColor3 = Color3.new(0,0,0)
ShiftFrame.BackgroundTransparency = 0.7
ShiftFrame.Position = UDim2.new(1, -170, 0.5, -75)
ShiftFrame.Size = UDim2.new(0, 160, 0, 180)
ShiftFrame.Active = true; ShiftFrame.Draggable = true
Instance.new("UICorner", ShiftFrame)

local ShiftTitle = Instance.new("TextLabel", ShiftFrame)
ShiftTitle.Text = "🔒 SHIFT LOCK"
ShiftTitle.Size = UDim2.new(1, -45, 0, 25); ShiftTitle.Position = UDim2.new(0, 5, 0, 0)
ShiftTitle.BackgroundTransparency = 1; ShiftTitle.TextColor3 = Color3.new(1,1,1)
ShiftTitle.Font = Enum.Font.SourceSansBold; ShiftTitle.TextSize = 10

local ShiftBody = Instance.new("Frame", ShiftFrame)
ShiftBody.Size = UDim2.new(1, 0, 1, -25); ShiftBody.Position = UDim2.new(0, 0, 0, 25)
ShiftBody.BackgroundTransparency = 1

local function CreateBtn(parent, text, pos, size, color)
    local btn = Instance.new("TextButton", parent)
    btn.Text = text; btn.Position = pos; btn.Size = size
    btn.BackgroundColor3 = color or Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 10
    Instance.new("UICorner", btn); return btn
end

local ShiftMinBtn = CreateBtn(ShiftFrame, "-", UDim2.new(1,-45,0,2), UDim2.new(0,20,0,20), Color3.fromRGB(80,80,80))
local ShiftCloseBtn = CreateBtn(ShiftFrame, "X", UDim2.new(1,-22,0,2), UDim2.new(0,20,0,20), Color3.fromRGB(150,0,0))

local moveLockBtn = CreateBtn(ShiftBody, "MOVER BTN", UDim2.new(0.05,0,0,5), UDim2.new(0,70,0,20), Color3.fromRGB(50,80,120))
local toggleDot = CreateBtn(ShiftBody, "MIRA: "..(MiraData.MiraHabilitada and "ON" or "OFF"), UDim2.new(0.05,0,0,30), UDim2.new(0,70,0,20), Color3.fromRGB(40,80,80))

local shiftFovTitle = Instance.new("TextLabel", ShiftBody)
shiftFovTitle.Text = "FOV: "..math.round(currentFOV)
shiftFovTitle.Size = UDim2.new(0,70,0,15); shiftFovTitle.Position = UDim2.new(0.52,0,0,5)
shiftFovTitle.BackgroundTransparency = 1; shiftFovTitle.TextColor3 = Color3.new(1,1,1)
shiftFovTitle.Font = Enum.Font.SourceSansBold; shiftFovTitle.TextSize = 11

local sfovPlus = CreateBtn(ShiftBody, "+10 FOV", UDim2.new(0.52,0,0,22), UDim2.new(0,70,0,20), Color3.fromRGB(40,80,40))
local sfovMinus = CreateBtn(ShiftBody, "-10 FOV", UDim2.new(0.52,0,0,45), UDim2.new(0,70,0,20), Color3.fromRGB(80,40,40))

local up = CreateBtn(ShiftBody, "▲", UDim2.new(0.18,0,0,65), UDim2.new(0,25,0,20))
local left = CreateBtn(ShiftBody, "◄", UDim2.new(0.05,0,0,87), UDim2.new(0,25,0,20))
local right = CreateBtn(ShiftBody, "►", UDim2.new(0.31,0,0,87), UDim2.new(0,25,0,20))
local down = CreateBtn(ShiftBody, "▼", UDim2.new(0.18,0,0,109), UDim2.new(0,25,0,20))
local bigger = CreateBtn(ShiftBody, "S +", UDim2.new(0.05,0,0,135), UDim2.new(0,35,0,20), Color3.fromRGB(40,100,40))
local smaller = CreateBtn(ShiftBody, "S -", UDim2.new(0.30,0,0,135), UDim2.new(0,35,0,20), Color3.fromRGB(100,40,40))

-- MIRA (punto)
local CenterDot = Instance.new("Frame", ShiftGui)
CenterDot.BackgroundColor3 = Color3.new(1,1,1)
CenterDot.AnchorPoint = Vector2.new(0.5,0.5)
CenterDot.Position = MiraData.MiraPos
CenterDot.Size = UDim2.new(0, MiraData.MiraSize, 0, MiraData.MiraSize)
CenterDot.Visible = false
Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1,0)

-- BOTÓN SHIFT LOCK
local LockButton = Instance.new("ImageButton", ShiftGui)
LockButton.BackgroundColor3 = Color3.new(0,0,0)
LockButton.BackgroundTransparency = 0.5
LockButton.Position = MiraData.ButtonPos
LockButton.Size = UDim2.new(0,40,0,40)
LockButton.Image = "rbxassetid://131109915995711"
Instance.new("UICorner", LockButton).CornerRadius = UDim.new(1,0)

-- ============================================================
-- FUNCIONES NOCHE
-- ============================================================
local function updateFOV()
    FOVText.Text = "FOV: " .. currentFOV
    shiftFovTitle.Text = "FOV: " .. math.round(currentFOV)
    FOVText.TextColor3 = currentFOV > 100 and Color3.fromRGB(255,100,100) or Color3.fromRGB(0,255,0)
end

local function updateBrightness()
    local brightTexts = {
        "1 (NOCHE EXTREMA)","2 (NOCHE PROFUNDA)","3 (NOCHE OSCURA)","4 (NOCHE)",
        "5 (ATARDECER TARDÍO)","6 (ATARDECER)","7 (ANOCHECER)","8 (NUBLADO OSCURO)",
        "9 (NUBLADO)","10 (DÍA NORMAL)","11 (DÍA SOLEADO)","12 (DÍA BRILLANTE)","13 (BLANCO TOTAL)"
    }
    BrightText.Text = "🌙 Brillo: " .. brightTexts[brightness]
    if brightness <= 4 then
        BrightText.TextColor3 = Color3.fromRGB(80,80,80)
    elseif brightness <= 8 then
        BrightText.TextColor3 = Color3.fromRGB(150,150,150)
    else
        BrightText.TextColor3 = Color3.fromRGB(220,220,220)
    end
    saveSettings()
end

local function updateStretch()
    if stretchEnabled then
        StretchBtn.Text = "🖥️ STRETCH: ON"
        StretchBtn.BackgroundColor3 = Color3.fromRGB(80,180,120)
        StretchBtn.TextColor3 = Color3.fromRGB(255,255,255)
        Status.Text = "Pantalla Estirada ON"
    else
        StretchBtn.Text = "🖥️ STRETCH: OFF"
        StretchBtn.BackgroundColor3 = Color3.fromRGB(80,60,120)
        StretchBtn.TextColor3 = Color3.fromRGB(255,100,100)
        Status.Text = "Pantalla Estirada OFF"
    end
    updateFOV(); saveSettings()
end

local function applyCartoonToCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or character.Name == player.Name then return end
    if cartoonEnabled or removeSkinsEnabled then
        local animController = character:FindFirstChildOfClass("AnimationController") or humanoid
        if animController then
            for _, track in pairs(animController:GetPlayingAnimationTracks()) do
                track:Stop()
                if animController:IsA("AnimationController") then animController:Destroy() end
            end
        end
    end
    if removeSkinsEnabled then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
    end
    if cartoonEnabled or removeSkinsEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
                if part.Name ~= "HumanoidRootPart" then
                    part.BrickColor = BrickColor.new("Medium stone grey")
                end
                for _, child in pairs(part:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") or child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") then
                        child:Destroy()
                    end
                end
            end
        end
    end
end

local function processAllHumanoids()
    local localPlayer = Players.LocalPlayer
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p ~= localPlayer then applyCartoonToCharacter(p.Character) end
    end
    for _, obj in pairs(Workspace:GetChildren()) do
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid and obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) == nil and obj ~= localPlayer.Character then
            applyCartoonToCharacter(obj)
        end
    end
end

local function applyCartoonGraphics()
    if cartoonEnabled then
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = 5
        spawn(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    obj.Material = Enum.Material.Plastic
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("Texture") or child:IsA("Decal") then child:Destroy() end
                    end
                end
            end
            processAllHumanoids()
        end)
        CartoonBtn.Text = "🎨 CARTÓN: ON"
        CartoonBtn.BackgroundColor3 = Color3.fromRGB(80,180,80)
        CartoonBtn.TextColor3 = Color3.fromRGB(255,255,255)
        Status.Text = "CARTÓN ACTIVADO"
    else
        settings().Rendering.QualityLevel = 21
        CartoonBtn.Text = "🎨 CARTÓN: OFF"
        CartoonBtn.BackgroundColor3 = Color3.fromRGB(80,60,80)
        CartoonBtn.TextColor3 = Color3.fromRGB(255,100,100)
        Status.Text = "MODO NORMAL"
        updateBrightness()
    end
    saveSettings()
end

local function toggleRemoveSkins()
    removeSkinsEnabled = not removeSkinsEnabled
    if removeSkinsEnabled then
        SkinsBtn.Text = "👤 QUITAR SKINS: ON"
        SkinsBtn.BackgroundColor3 = Color3.fromRGB(180,80,80)
        SkinsBtn.TextColor3 = Color3.fromRGB(255,255,255)
        Status.Text = "SKINS REMOVIDAS"
        processAllHumanoids()
    else
        SkinsBtn.Text = "👤 QUITAR SKINS: OFF"
        SkinsBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
        SkinsBtn.TextColor3 = Color3.fromRGB(255,100,100)
        Status.Text = "SKINS NORMAL"
    end
    saveSettings()
end

local function togglePanel()
    panelVisible = not panelVisible
    if panelVisible then
        MainFrame.Size = UDim2.new(0,200,0,250); MinimizeBtn.Text = "_"
    else
        MainFrame.Size = UDim2.new(0,200,0,25); MinimizeBtn.Text = "□"
    end
end

-- ============================================================
-- EVENTOS NOCHE
-- ============================================================
FOVPlus.MouseButton1Click:Connect(function()
    currentFOV = math.clamp(currentFOV + 10, 70, 150)
    updateFOV(); Status.Text = "FOV: " .. currentFOV; saveSettings()
end)
FOVMinus.MouseButton1Click:Connect(function()
    currentFOV = math.clamp(currentFOV - 10, 70, 150)
    updateFOV(); Status.Text = "FOV: " .. currentFOV; saveSettings()
end)
BrightPlus.MouseButton1Click:Connect(function()
    brightness = math.clamp(brightness + 1, 1, 13)
    updateBrightness(); Status.Text = "Brillo: Nivel " .. brightness
end)
BrightMinus.MouseButton1Click:Connect(function()
    brightness = math.clamp(brightness - 1, 1, 13)
    updateBrightness(); Status.Text = "Brillo: Nivel " .. brightness
end)
MinimizeBtn.MouseButton1Click:Connect(togglePanel)
StretchBtn.MouseButton1Click:Connect(function() stretchEnabled = not stretchEnabled; updateStretch() end)
CartoonBtn.MouseButton1Click:Connect(function() cartoonEnabled = not cartoonEnabled; applyCartoonGraphics() end)
SkinsBtn.MouseButton1Click:Connect(toggleRemoveSkins)
CloseBtn.MouseButton1Click:Connect(function() saveSettings(); MainFrame.Visible = false end)

-- ============================================================
-- EVENTOS SHIFT LOCK
-- ============================================================
ShiftMinBtn.MouseButton1Click:Connect(function()
    ShiftBody.Visible = not ShiftBody.Visible
    ShiftFrame.Size = ShiftBody.Visible and UDim2.new(0,160,0,180) or UDim2.new(0,160,0,25)
end)
ShiftCloseBtn.MouseButton1Click:Connect(function() ShiftFrame.Visible = false end)

sfovPlus.MouseButton1Click:Connect(function()
    currentFOV = math.min(currentFOV + 10, 150)
    updateFOV(); saveSettings()
end)
sfovMinus.MouseButton1Click:Connect(function()
    currentFOV = math.max(currentFOV - 10, 70)
    updateFOV(); saveSettings()
end)

moveLockBtn.MouseButton1Click:Connect(function()
    LockButton.Active = not LockButton.Active
    LockButton.Draggable = LockButton.Active
    moveLockBtn.Text = LockButton.Active and "MOVER: SI" or "MOVER: NO"
end)
LockButton.DragStopped:Connect(function() MiraData.ButtonPos = LockButton.Position; SaveMira() end)

toggleDot.MouseButton1Click:Connect(function()
    MiraData.MiraHabilitada = not MiraData.MiraHabilitada
    toggleDot.Text = MiraData.MiraHabilitada and "MIRA: ON" or "MIRA: OFF"
    SaveMira()
end)

up.MouseButton1Click:Connect(function() CenterDot.Position += UDim2.new(0,0,0,-1); MiraData.MiraPos = CenterDot.Position; SaveMira() end)
down.MouseButton1Click:Connect(function() CenterDot.Position += UDim2.new(0,0,0,1); MiraData.MiraPos = CenterDot.Position; SaveMira() end)
left.MouseButton1Click:Connect(function() CenterDot.Position += UDim2.new(0,-1,0,0); MiraData.MiraPos = CenterDot.Position; SaveMira() end)
right.MouseButton1Click:Connect(function() CenterDot.Position += UDim2.new(0,1,0,0); MiraData.MiraPos = CenterDot.Position; SaveMira() end)
bigger.MouseButton1Click:Connect(function() CenterDot.Size += UDim2.new(0,1,0,1); MiraData.MiraSize = CenterDot.Size.X.Offset; SaveMira() end)
smaller.MouseButton1Click:Connect(function()
    if CenterDot.Size.X.Offset > 1 then
        CenterDot.Size -= UDim2.new(0,1,0,1); MiraData.MiraSize = CenterDot.Size.X.Offset; SaveMira()
    end
end)

-- SHIFT LOCK LÓGICA
_G.IsVillcaLocked = false
local AlignOrientation = Instance.new("AlignOrientation")
local Attachment0 = Instance.new("Attachment")

LockButton.MouseButton1Click:Connect(function()
    _G.IsVillcaLocked = not _G.IsVillcaLocked
    LockButton.ImageColor3 = _G.IsVillcaLocked and Color3.new(0,1,0) or Color3.new(1,1,1)
    CenterDot.Visible = _G.IsVillcaLocked and MiraData.MiraHabilitada
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if _G.IsVillcaLocked and root and hum then
        hum.AutoRotate = false; Attachment0.Parent = root
        AlignOrientation.Attachment0 = Attachment0
        AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
        AlignOrientation.Responsiveness = 200; AlignOrientation.MaxTorque = 10^10
        AlignOrientation.Parent = root
        hum.CameraOffset = Vector3.new(1.7, 0.5, 0)
    else
        AlignOrientation.Parent = nil; Attachment0.Parent = nil
        if hum then hum.AutoRotate = true; hum.CameraOffset = Vector3.zero end
    end
end)

-- ============================================================
-- SISTEMA PERSISTENTE - FOV + ILUMINACIÓN + SHIFT LOCK
-- ============================================================
RunService.RenderStepped:Connect(function()
    -- Mantener mira y shift lock
    if camera.FieldOfView ~= currentFOV and not _G.IsVillcaLocked then
        camera.FieldOfView = currentFOV
    end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if _G.IsVillcaLocked and root then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        local look = camera.CFrame.LookVector
        if root:FindFirstChild("AlignOrientation") then
            root.AlignOrientation.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(look.X, 0, look.Z))
        end
    end
end)

spawn(function()
    wait(3)
    local brightValues = {0.02,0.05,0.1,0.15,0.25,0.4,0.6,0.8,1.2,2.0,3.0,4.0,5.0}
    local ambientColors = {
        Color3.fromRGB(5,5,5), Color3.fromRGB(10,10,10), Color3.fromRGB(15,15,15),
        Color3.fromRGB(20,20,20), Color3.fromRGB(30,30,30), Color3.fromRGB(40,40,40),
        Color3.fromRGB(60,60,60), Color3.fromRGB(80,80,80), Color3.fromRGB(100,100,100),
        Color3.fromRGB(128,128,128), Color3.fromRGB(160,160,160), Color3.fromRGB(200,200,200),
        Color3.fromRGB(255,255,255)
    }
    while true do
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam and cam.CameraType ~= Enum.CameraType.Scriptable then
                cam.FieldOfView = stretchEnabled and currentFOV * 1.3 or currentFOV
            end
            Lighting.Brightness = brightValues[brightness]
            Lighting.Ambient = ambientColors[brightness]
            Lighting.OutdoorAmbient = ambientColors[brightness]
            Lighting.ClockTime = 0
            Lighting.TimeOfDay = "00:00:00"
            Lighting.GlobalShadows = (brightness > 6)
            Lighting.ShadowSoftness = (brightness <= 6) and 0.1 or 0.5
            Lighting.FogEnd = 100000
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ExposureCompensation = 0
            Lighting.ColorShift_Bottom = Color3.new(0,0,0)
            Lighting.ColorShift_Top = Color3.new(0,0,0)
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then atmosphere.Density = 0 end
            local blur = Lighting:FindFirstChildOfClass("BlurEffect")
            if blur then blur.Enabled = false end
            Lighting.GeographicLatitude = 0
        end)
        RunService.Heartbeat:Wait()
    end
end)

spawn(function()
    wait(5)
    pcall(function()
        for _, connection in pairs(getconnections(Lighting.Changed)) do
            connection:Disable()
        end
    end)
end)

-- Personajes nuevos
local function onCharacterAdded(character)
    wait(0.5)
    if cartoonEnabled or removeSkinsEnabled then applyCartoonToCharacter(character) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(onCharacterAdded)
    if p.Character then onCharacterAdded(p.Character) end
end)

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        local humanoid = child:FindFirstChildOfClass("Humanoid")
        if humanoid and Players:GetPlayerFromCharacter(child) == nil then
            if cartoonEnabled or removeSkinsEnabled then
                wait(0.5); applyCartoonToCharacter(child)
            end
        end
    end
end)

-- ============================================================
-- INICIO
-- ============================================================
local function start()
    loadSettings(); LoadMira()
    updateFOV(); updateBrightness(); updateStretch()
    if cartoonEnabled then applyCartoonGraphics() end
    for _, p in pairs(Players:GetPlayers()) do
        p.CharacterAdded:Connect(onCharacterAdded)
        if p.Character then onCharacterAdded(p.Character) end
    end
    processAllHumanoids()
    Status.Text = "✅ VILLCA COMPLETO ACTIVO"
    print("📱 VILLCA COMPLETO - NOCHE + SHIFT LOCK ACTIVADO")
end

if game:IsLoaded() then start() else game.Loaded:Wait(); start() end
