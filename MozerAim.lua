-- =====================================================
-- SHARP V12 - THE OVERLORD
-- X-RAY دائم + AIMBOT صاروخي + لوحة لاعبين + حماية
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ==================== الحالات ====================
local isEnabled = false
local uiLocked = false
local uiHidden = false
local pinEnabled = false
local protectedPlayers = {} -- قائمة اللاعبين المحميين
local playerListVisible = true

-- ==================== 1. نظام X-RAY (دائم) ====================
local function applyXray(char)
    if not char then return end
    task.wait(0.3)
    local highlight = char:FindFirstChild("SharpXray")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "SharpXray"
        highlight.Parent = char
    end
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function initXray()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then applyXray(player.Character) end
            player.CharacterAdded:Connect(applyXray)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(applyXray)
end)
task.spawn(initXray)

-- ==================== 2. واجهة التشغيل (ON/OFF + PIN) ====================
local pGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
pGui.Name = "PowerUI"
pGui.ResetOnSpawn = false

-- زر ON/OFF
local pBtn = Instance.new("TextButton", pGui)
pBtn.Size = UDim2.new(0, 40, 0, 40)
pBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
pBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
pBtn.Text = "OFF"
pBtn.TextColor3 = Color3.new(1, 1, 1)
pBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 5)
local pStroke = Instance.new("UIStroke", pBtn)
pStroke.Thickness = 2
pStroke.Color = Color3.new(1, 1, 1)

-- زر التثبيت (PIN) - صغير جداً
local pinBtn = Instance.new("TextButton", pGui)
pinBtn.Size = UDim2.new(0, 18, 0, 18)
pinBtn.Position = UDim2.new(0.05, 45, 0.4, -2)
pinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pinBtn.Text = "📌"
pinBtn.TextColor3 = Color3.new(1, 1, 1)
pinBtn.Font = Enum.Font.GothamBold
pinBtn.TextSize = 12
Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0, 4)
pinBtn.MouseButton1Click:Connect(function()
    pinEnabled = not pinEnabled
    if pinEnabled then
        pBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
        pinBtn.Position = UDim2.new(0.05, 45, 0.4, -2)
        pinBtn.Text = "📍"
    else
        pinBtn.Text = "📌"
    end
end)

-- ==================== 3. واجهة الدائرة (Crosshair) ====================
local cGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
cGui.Name = "CrosshairUI"
cGui.ResetOnSpawn = false

local cFrame = Instance.new("Frame", cGui)
cFrame.Size = UDim2.new(0, 60, 0, 60)
cFrame.Position = UDim2.new(0.5, -30, 0.5, -30)
cFrame.BackgroundTransparency = 1

local ring = Instance.new("Frame", cFrame)
ring.Size = UDim2.new(1, 0, 1, 0)
ring.BackgroundTransparency = 1
local rStroke = Instance.new("UIStroke", ring)
rStroke.Color = Color3.new(1, 1, 1)
rStroke.Thickness = 1
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local dot = Instance.new("Frame", cFrame)
dot.Size = UDim2.new(0, 4, 0, 4)
dot.Position = UDim2.new(0.5, -2, 0.5, -2)
dot.BackgroundColor3 = Color3.new(1, 0, 0)
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local btns = Instance.new("Frame", cFrame)
btns.Size = UDim2.new(0, 80, 0, 20)
btns.Position = UDim2.new(0.5, -40, 1, 10)
btns.BackgroundTransparency = 1

local lBtn = Instance.new("TextButton", btns)
lBtn.Size = UDim2.new(0, 38, 1, 0)
lBtn.Text = "Lock"
lBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
lBtn.TextColor3 = Color3.new(1, 1, 1)
lBtn.TextSize = 10

local hBtn = Instance.new("TextButton", btns)
hBtn.Size = UDim2.new(0, 38, 1, 0)
hBtn.Position = UDim2.new(0, 42, 0, 0)
hBtn.Text = "Hide"
hBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hBtn.TextColor3 = Color3.new(1, 1, 1)
hBtn.TextSize = 10

-- ==================== 4. لوحة اللاعبين (سوداء، حواف دائرية، قابلة للسحب) ====================
local playerListGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
playerListGui.Name = "PlayerListUI"
playerListGui.ResetOnSpawn = false

local playerFrame = Instance.new("Frame", playerListGui)
playerFrame.Size = UDim2.new(0, 200, 0, 300)
playerFrame.Position = UDim2.new(0.8, -210, 0.2, 0)
playerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", playerFrame).CornerRadius = UDim.new(0, 12)
local playerStroke = Instance.new("UIStroke", playerFrame)
playerStroke.Thickness = 1
playerStroke.Color = Color3.fromRGB(50, 50, 50)

-- Title
local titleLabel = Instance.new("TextLabel", playerFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.Text = "👥 Players (" .. #Players:GetPlayers() .. ")"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.BackgroundTransparency = 1

-- Scrolling Frame للاعبين
local scroll = Instance.new("ScrollingFrame", playerFrame)
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 10)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 4)

-- تحديث قائمة اللاعبين
local function updatePlayerList()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local players = Players:GetPlayers()
    local count = 0
    for _, player in ipairs(players) do
        if player ~= LocalPlayer then
            count = count + 1
            local card = Instance.new("Frame", scroll)
            card.Size = UDim2.new(1, -10, 0, 35)
            card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            -- صورة اللاعب
            local thumb = Instance.new("ImageLabel", card)
            thumb.Size = UDim2.new(0, 25, 0, 25)
            thumb.Position = UDim2.new(0, 4, 0, 5)
            thumb.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
            
            -- اسم اللاعب
            local nameLabel = Instance.new("TextLabel", card)
            nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 34, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 11
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            -- زر الحماية 🛡
            local protectBtn = Instance.new("TextButton", card)
            protectBtn.Size = UDim2.new(0, 25, 0, 25)
            protectBtn.Position = UDim2.new(1, -30, 0, 5)
            protectBtn.Text = "🛡"
            protectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            protectBtn.TextColor3 = Color3.new(1, 1, 1)
            protectBtn.TextSize = 14
            Instance.new("UICorner", protectBtn).CornerRadius = UDim.new(0, 5)
            
            protectBtn.MouseButton1Click:Connect(function()
                if protectedPlayers[player] then
                    protectedPlayers[player] = nil
                    protectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                else
                    protectedPlayers[player] = true
                    protectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                end
            end)
        end
    end
    
    titleLabel.Text = "👥 Players (" .. count .. ")"
    scroll.CanvasSize = UDim2.new(0, 0, 0, count * 42 + 10)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- ==================== 5. وظائف السحب ====================
local function makeDraggable(obj, lockable)
    local dragging, startInput, startPos
    obj.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if lockable and uiLocked then return end
            dragging = true
            startInput = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(pBtn, false)
makeDraggable(pinBtn, false)
makeDraggable(cFrame, true)
makeDraggable(playerFrame, true)

-- ==================== 6. أزرار الدائرة ====================
lBtn.MouseButton1Click:Connect(function()
    uiLocked = not uiLocked
    lBtn.Text = uiLocked and "Unlock" or "Lock"
end)

hBtn.MouseButton1Click:Connect(function()
    uiHidden = not uiHidden
    ring.Visible = not uiHidden
    dot.Visible = not uiHidden
    btns.Visible = not uiHidden
end)

-- ==================== 7. محرك القنص (المحسّن) ====================
local function isTargetVisible(part)
    local castParams = RaycastParams.new()
    castParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    castParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, castParams)
    return result == nil
end

local function findGlobalTarget()
    local bestTarget = nil
    local minDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not protectedPlayers[p] and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                -- شرط عدم استهداف خلف الجدران إلا إذا كان الـ X-Ray مفعّلاً (وهو مفعّل دائماً)
                if onScreen and isTargetVisible(head) then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < minDist then
                        minDist = dist
                        bestTarget = head
                    end
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    if not isEnabled then return end
    
    local target = findGlobalTarget()
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end)

-- ==================== 8. زر ON/OFF ====================
pBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    pBtn.Text = isEnabled and "ON" or "OFF"
    pBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

print("🔥 SHARP V12 - THE OVERLORD LOADED")
print("🛡️ Protected Players: Use 🛡 button in player list")
