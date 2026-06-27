-- =====================================================
-- SHARP V14 - THE OVERLORD (FIXED DRAG + PIN)
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- الحالات
local isEnabled = false
local uiLocked = false
local uiHidden = false
local pinActive = false
local protectedPlayers = {}

-- ==================== 1. X-RAY ====================
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

-- ==================== 2. واجهة ON/OFF + PIN ====================
local pGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
pGui.Name = "PowerUI"
pGui.ResetOnSpawn = false

-- مجموعة الزر (قابلة للسحب فقط قبل PIN)
local btnGroup = Instance.new("Frame", pGui)
btnGroup.Size = UDim2.new(0, 60, 0, 80)
btnGroup.Position = UDim2.new(0.03, 0, 0.3, 0)
btnGroup.BackgroundTransparency = 1

-- زر ON/OFF
local pBtn = Instance.new("TextButton", btnGroup)
pBtn.Size = UDim2.new(0, 55, 0, 55)
pBtn.Position = UDim2.new(0, 0, 0, 0)
pBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
pBtn.Text = "OFF"
pBtn.TextColor3 = Color3.new(1, 1, 1)
pBtn.Font = Enum.Font.GothamBold
pBtn.TextSize = 18
Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 10)
local pStroke = Instance.new("UIStroke", pBtn)
pStroke.Thickness = 2
pStroke.Color = Color3.new(1, 1, 1)

-- زر PIN (أسفل ON/OFF)
local pinBtn = Instance.new("TextButton", btnGroup)
pinBtn.Size = UDim2.new(0, 40, 0, 20)
pinBtn.Position = UDim2.new(0.075, 0, 1, 3)
pinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pinBtn.Text = "Pin"
pinBtn.TextColor3 = Color3.new(1, 1, 1)
pinBtn.Font = Enum.Font.GothamBold
pinBtn.TextSize = 12
Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0, 5)

-- ==================== 3. سحب زر ON/OFF (منفصل عن PIN) ====================
local draggingBtn = false
local dragBtnStart = nil
local dragBtnStartPos = nil

btnGroup.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if pinActive then return end -- إذا كان PIN مفعلاً، ما يتحرك
        draggingBtn = true
        dragBtnStart = input.Position
        dragBtnStartPos = btnGroup.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragBtnStart
        btnGroup.Position = UDim2.new(dragBtnStartPos.X.Scale, dragBtnStartPos.X.Offset + delta.X, dragBtnStartPos.Y.Scale, dragBtnStartPos.Y.Offset + delta.Y)
    end
end)

btnGroup.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingBtn = false
    end
end)

-- ==================== 4. زر PIN ====================
pinBtn.MouseButton1Click:Connect(function()
    pinActive = not pinActive
    if pinActive then
        pinBtn.Text = "Pinned ✓"
        pinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        pinBtn.Visible = false -- يختفي تماماً
    else
        pinBtn.Text = "Pin"
        pinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        pinBtn.Visible = true
    end
end)

-- ==================== 5. لوحة اللاعبين (قابلة للسحب) ====================
local playerListGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
playerListGui.Name = "PlayerListUI"
playerListGui.ResetOnSpawn = false

local playerFrame = Instance.new("Frame", playerListGui)
playerFrame.Size = UDim2.new(0, 160, 0, 250)
playerFrame.Position = UDim2.new(0.8, -170, 0.2, 0)
playerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", playerFrame).CornerRadius = UDim.new(0, 12)
local playerStroke = Instance.new("UIStroke", playerFrame)
playerStroke.Thickness = 1
playerStroke.Color = Color3.fromRGB(50, 50, 50)

local titleLabel = Instance.new("TextLabel", playerFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 22)
titleLabel.Text = "👥 Players"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", playerFrame)
scroll.Size = UDim2.new(1, -10, 1, -30)
scroll.Position = UDim2.new(0, 5, 0, 25)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 10)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 3)

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
            card.Size = UDim2.new(1, -10, 0, 30)
            card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            local thumb = Instance.new("ImageLabel", card)
            thumb.Size = UDim2.new(0, 22, 0, 22)
            thumb.Position = UDim2.new(0, 3, 0, 4)
            thumb.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
            
            local nameLabel = Instance.new("TextLabel", card)
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 28, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 10
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local protectBtn = Instance.new("TextButton", card)
            protectBtn.Size = UDim2.new(0, 22, 0, 22)
            protectBtn.Position = UDim2.new(1, -26, 0, 4)
            protectBtn.Text = "🛡"
            protectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            protectBtn.TextColor3 = Color3.new(1, 1, 1)
            protectBtn.TextSize = 12
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
    scroll.CanvasSize = UDim2.new(0, 0, 0, count * 36 + 10)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- ==================== 6. سحب لوحة اللاعبين ====================
local draggingList = false
local dragListStart = nil
local dragListStartPos = nil

playerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingList = true
        dragListStart = input.Position
        dragListStartPos = playerFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingList and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragListStart
        playerFrame.Position = UDim2.new(dragListStartPos.X.Scale, dragListStartPos.X.Offset + delta.X, dragListStartPos.Y.Scale, dragListStartPos.Y.Offset + delta.Y)
    end
end)

playerFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingList = false
    end
end)

-- ==================== 7. دائرة التصويب ====================
local cGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
cGui.Name = "CrosshairUI"
cGui.ResetOnSpawn = false

local cFrame = Instance.new("Frame", cGui)
cFrame.Size = UDim2.new(0, 50, 0, 50)
cFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
cFrame.BackgroundTransparency = 1

local ring = Instance.new("Frame", cFrame)
ring.Size = UDim2.new(1, 0, 1, 0)
ring.BackgroundTransparency = 1
local rStroke = Instance.new("UIStroke", ring)
rStroke.Color = Color3.new(1, 1, 1)
rStroke.Thickness = 1
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local dot = Instance.new("Frame", cFrame)
dot.Size = UDim2.new(0, 3, 0, 3)
dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
dot.BackgroundColor3 = Color3.new(1, 0, 0)
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local btns = Instance.new("Frame", cFrame)
btns.Size = UDim2.new(0, 70, 0, 18)
btns.Position = UDim2.new(0.5, -35, 1, 8)
btns.BackgroundTransparency = 1

local lBtn = Instance.new("TextButton", btns)
lBtn.Size = UDim2.new(0, 33, 1, 0)
lBtn.Text = "Lock"
lBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
lBtn.TextColor3 = Color3.new(1, 1, 1)
lBtn.TextSize = 9

local hBtn = Instance.new("TextButton", btns)
hBtn.Size = UDim2.new(0, 33, 1, 0)
hBtn.Position = UDim2.new(0, 37, 0, 0)
hBtn.Text = "Hide"
hBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hBtn.TextColor3 = Color3.new(1, 1, 1)
hBtn.TextSize = 9

-- ==================== 8. سحب دائرة التصويب ====================
local draggingCross = false
local dragCrossStart = nil
local dragCrossStartPos = nil

cFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if uiLocked then return end
        draggingCross = true
        dragCrossStart = input.Position
        dragCrossStartPos = cFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingCross and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragCrossStart
        cFrame.Position = UDim2.new(dragCrossStartPos.X.Scale, dragCrossStartPos.X.Offset + delta.X, dragCrossStartPos.Y.Scale, dragCrossStartPos.Y.Offset + delta.Y)
    end
end)

cFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingCross = false
    end
end)

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

-- ==================== 9. محرك القنص ====================
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

-- ==================== 10. ON/OFF ====================
pBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    pBtn.Text = isEnabled and "ON" or "OFF"
    pBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

print("🔥 SHARP V14 - THE OVERLORD (FIXED) LOADED")
