-- ============================================================================
-- TELEPORT HUB ULTRA - ЧАСТЬ 1: Инициализация, Окно, Вкладки, Палитра
-- ============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CONFIGS_FILENAME = "TeleportHub_AllConfigs_Pro.json"

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportHubPersistentPro"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Универсальная функция для перетаскивания элементов
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 1. ИКОНКА ОТКРЫТИЯ
local openBtn = Instance.new("ImageButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
openBtn.Visible = false
openBtn.Parent = gui
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(1, 0)
makeDraggable(openBtn)

local openLbl = Instance.new("TextLabel", openBtn)
openLbl.Size = UDim2.new(1, 0, 1, 0)
openLbl.BackgroundTransparency = 1
openLbl.Text = "⚡"
openLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
openLbl.TextSize = 22

-- 2. ГЛАВНОЕ ОКНО
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 380)
main.Position = UDim2.new(0.5, -200, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
main.Parent = gui
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)
makeDraggable(main)

-- Верхняя панель
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 35)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.03, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Teleport Hub Ultra"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -33, 0.5, -14)
close.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.TextSize = 18
local closeCorner = Instance.new("UICorner", close)
closeCorner.CornerRadius = UDim.new(0, 6)

close.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    openBtn.Visible = false
end)

-- Система вкладок (6 штук)
local tabsFrame = Instance.new("ScrollingFrame", main)
tabsFrame.Size = UDim2.new(1, -16, 0, 32)
tabsFrame.Position = UDim2.new(0, 8, 0, 38)
tabsFrame.BackgroundTransparency = 1
tabsFrame.CanvasSize = UDim2.new(0, 480, 0, 0)
tabsFrame.ScrollBarThickness = 2

local pages = {}
local function makeTab(index, name)
    local btn = Instance.new("TextButton", tabsFrame)
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.Position = UDim2.new(0, (index - 1) * 78, 0, 0)
    btn.BackgroundColor3 = (index == 1) and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(25, 25, 33)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local page = Instance.new("ScrollingFrame", main)
    page.Size = UDim2.new(1, -16, 1, -82)
    page.Position = UDim2.new(0, 8, 0, 76)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 3
    page.Visible = (index == 1)
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    btn.MouseButton1Click:Connect(function()
        for i, p in ipairs(pages) do
            p.page.Visible = (i == index)
            p.btn.BackgroundColor3 = (i == index) and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(25, 25, 33)
        end
    end)
    
    table.insert(pages, {btn = btn, page = page})
    return page
end

local t1 = makeTab(1, "Точки")
local t2 = makeTab(2, "Координаты")
local t3 = makeTab(3, "Порталы")
local t4 = makeTab(4, "FreeCam")
local t5 = makeTab(5, "Игроки")
local t6 = makeTab(6, "Конфиги")

local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Универсальный парсер цвета (HEX, строковые коды вида G08L, палитра)
local function parseColorCode(str)
    str = str:upper():gsub("%s+", "")
    if str:find("^#?[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") then
        str = str:gsub("#", "")
        local r = tonumber(str:sub(1,2), 16) or 255
        local g = tonumber(str:sub(3,4), 16) or 255
        local b = tonumber(str:sub(5,6), 16) or 255
        return Color3.fromRGB(r, g, b)
    end
    local prefix = str:sub(1,1)
    local num1 = tonumber(str:sub(2,3)) or 50
    
    local r, g, b = 100, 100, 100
    if prefix == "R" then r = 255; g = math.floor(255 * (100 - num1)/100); b = math.floor(255 * (100 - num1)/100)
    elseif prefix == "G" then r = math.floor(255 * (100 - num1)/100); g = 255; b = math.floor(255 * (100 - num1)/100)
    elseif prefix == "B" then r = math.floor(255 * (100 - num1)/100); g = math.floor(255 * (100 - num1)/100); b = 255
    elseif prefix == "Y" then r = 255; g = 255; b = math.floor(255 * (100 - num1)/100)
    elseif prefix == "P" then r = 255; g = 100; b = 255
    else
        local presets = {
            КРАСНЫЙ = Color3.fromRGB(220, 50, 50),
            ОРАНЖЕВЫЙ = Color3.fromRGB(240, 130, 30),
            ЖЕЛТЫЙ = Color3.fromRGB(240, 220, 50),
            ЗЕЛЕНЫЙ = Color3.fromRGB(50, 200, 80),
            СИНИЙ = Color3.fromRGB(50, 120, 240),
            ФИОЛЕТОВЫЙ = Color3.fromRGB(150, 50, 240),
            РОЗОВЫЙ = Color3.fromRGB(240, 100, 180),
            БЕЛЫЙ = Color3.fromRGB(255, 255, 255),
            ТЕМНЫЙ = Color3.fromRGB(35, 35, 45)
        }
        if presets[str] then return presets[str] end
    end
    return Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
end

local savedPointsData = {}

-- Модальное окно выбора цвета
local function openColorPicker(currentBg, currentText, callback)
    local cpGui = Instance.new("Frame", gui)
    cpGui.Size = UDim2.new(0, 300, 0, 320)
    cpGui.Position = UDim2.new(0.5, -150, 0.5, -160)
    cpGui.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    cpGui.ZIndex = 10
    Instance.new("UICorner", cpGui).CornerRadius = UDim.new(0, 10)
    makeDraggable(cpGui)
    
    local titleLbl = Instance.new("TextLabel", cpGui)
    titleLbl.Size = UDim2.new(1, 0, 0, 30)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "🎨 Настройка цветов"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.ZIndex = 10
    
    local codeInput = Instance.new("TextBox", cpGui)
    codeInput.Size = UDim2.new(0.9, 0, 0, 32)
    codeInput.Position = UDim2.new(0.05, 0, 0, 40)
    codeInput.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    codeInput.PlaceholderText = "Код (например: G08L или #FF5500)"
    codeInput.Text = ""
    codeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    codeInput.TextSize = 11
    codeInput.ZIndex = 10
    Instance.new("UICorner", codeInput).CornerRadius = UDim.new(0, 6)
    
    local presetsFrame = Instance.new("Frame", cpGui)
    presetsFrame.Size = UDim2.new(0.9, 0, 0, 70)
    presetsFrame.Position = UDim2.new(0.05, 0, 0, 80)
    presetsFrame.BackgroundTransparency = 1
    presetsFrame.ZIndex = 10
    
    local pLayout = Instance.new("UIGridLayout", presetsFrame)
    pLayout.CellSize = UDim2.new(0, 48, 0, 28)
    pLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    
    local colorsList = {
        {"Красный", Color3.fromRGB(220, 50, 50)},
        {"Оранж", Color3.fromRGB(240, 130, 30)},
        {"Желтый", Color3.fromRGB(240, 220, 50)},
        {"Зеленый", Color3.fromRGB(50, 200, 80)},
        {"Синий", Color3.fromRGB(50, 120, 240)},
        {"Фиолет", Color3.fromRGB(150, 50, 240)},
        {"Розовый", Color3.fromRGB(240, 100, 180)},
        {"Белый", Color3.fromRGB(255, 255, 255)},
        {"Тёмный", Color3.fromRGB(35, 35, 45)},
    }
    
    local selectedBg = currentBg
    local selectedText = currentText
    
    for _, cInfo in ipairs(colorsList) do
        local btn = Instance.new("TextButton", presetsFrame)
        btn.BackgroundColor3 = cInfo[2]
        btn.Text = cInfo[1]
        btn.TextColor3 = (cInfo[2].R + cInfo[2].G + cInfo[2].B) > 1.5 and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
        btn.TextSize = 9
        btn.ZIndex = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            selectedBg = cInfo[2]
        end)
    end
    
    local rgbFrame = Instance.new("Frame", cpGui)
    rgbFrame.Size = UDim2.new(0.9, 0, 0, 80)
    rgbFrame.Position = UDim2.new(0.05, 0, 0, 160)
    rgbFrame.BackgroundTransparency = 1
    rgbFrame.ZIndex = 10
    
    local rBox = Instance.new("TextBox", rgbFrame)
    rBox.Size = UDim2.new(0.3, 0, 0, 28)
    rBox.Position = UDim2.new(0, 0, 0, 0)
    rBox.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    rBox.Text = tostring(math.floor(currentBg.R * 255))
    rBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    rBox.TextSize = 11
    rBox.ZIndex = 10
    Instance.new("UICorner", rBox).CornerRadius = UDim.new(0, 4)
    
    local gBox = Instance.new("TextBox", rgbFrame)
    gBox.Size = UDim2.new(0.3, 0, 0, 28)
    gBox.Position = UDim2.new(0.35, 0, 0, 0)
    gBox.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
    gBox.Text = tostring(math.floor(currentBg.G * 255))
    gBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    gBox.TextSize = 11
    gBox.ZIndex = 10
    Instance.new("UICorner", gBox).CornerRadius = UDim.new(0, 4)
    
    local bBox = Instance.new("TextBox", rgbFrame)
    bBox.Size = UDim2.new(0.3, 0, 0, 28)
    bBox.Position = UDim2.new(0.7, 0, 0, 0)
    bBox.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    bBox.Text = tostring(math.floor(currentBg.B * 255))
    bBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    bBox.TextSize = 11
    bBox.ZIndex = 10
    Instance.new("UICorner", bBox).CornerRadius = UDim.new(0, 4)
    
    local applyBtn = Instance.new("TextButton", cpGui)
    applyBtn.Size = UDim2.new(0.9, 0, 0, 34)
    applyBtn.Position = UDim2.new(0.05, 0, 1, -44)
    applyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
    applyBtn.Text = "✓ Применить цвет"
    applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyBtn.TextSize = 12
    applyBtn.ZIndex = 10
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)
    
    applyBtn.MouseButton1Click:Connect(function()
        if codeInput.Text ~= "" then
            selectedBg = parseColorCode(codeInput.Text)
        elseif tonumber(rBox.Text) and tonumber(gBox.Text) and tonumber(bBox.Text) then
            selectedBg = Color3.fromRGB(
                math.clamp(tonumber(rBox.Text) or 0, 0, 255),
                math.clamp(tonumber(gBox.Text) or 0, 0, 255),
                math.clamp(tonumber(bBox.Text) or 0, 0, 255)
            )
        end
        callback(selectedBg, selectedText)
        cpGui:Destroy()
    end)
end
-- ============================================================================
-- TELEPORT HUB ULTRA - ЧАСТЬ 2: Точки (цвета, координаты, защита) и Игроки
-- ============================================================================

-- ВКЛАДКА 1: ТОЧКИ
local nameInput = Instance.new("TextBox", t1)
nameInput.Size = UDim2.new(1, 0, 0, 32)
nameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
nameInput.Text = "Моя точка"
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.TextSize = 12
nameInput.ClearTextOnFocus = false
Instance.new("UICorner", nameInput).CornerRadius = UDim.new(0, 6)

local addPointBtn = Instance.new("TextButton", t1)
addPointBtn.Size = UDim2.new(1, 0, 0, 32)
addPointBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
addPointBtn.Text = "💾 Сохранить точку"
addPointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addPointBtn.TextSize = 12
Instance.new("UICorner", addPointBtn).CornerRadius = UDim.new(0, 6)

local pointsContainer = Instance.new("Frame", t1)
pointsContainer.Name = "PointsContainer"
pointsContainer.Size = UDim2.new(1, 0, 0, 0)
pointsContainer.BackgroundTransparency = 1
pointsContainer.AutomaticSize = Enum.AutomaticSize.Y
local pLayout = Instance.new("UIListLayout", pointsContainer)
pLayout.Padding = UDim.new(0, 6)

local createPointUI
createPointUI = function(ptData)
    local item = Instance.new("Frame", pointsContainer)
    item.Size = UDim2.new(1, 0, 0, 42)
    item.BackgroundColor3 = ptData.BgColor or Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", item)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Position = UDim2.new(0.03, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = ptData.Name
    lbl.TextColor3 = ptData.TextColor or Color3.fromRGB(240, 240, 240)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    
    local tp = Instance.new("TextButton", item)
    tp.Size = UDim2.new(0, 40, 0, 28)
    tp.Position = UDim2.new(1, -170, 0.5, -14)
    tp.BackgroundColor3 = Color3.fromRGB(40, 80, 130)
    tp.Text = "ТП"
    tp.TextColor3 = Color3.fromRGB(255, 255, 255)
    tp.TextSize = 11
    Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)
    tp.MouseButton1Click:Connect(function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(unpack(ptData.Pos)) end
    end)
    
    local colBtn = Instance.new("TextButton", item)
    colBtn.Size = UDim2.new(0, 36, 0, 28)
    colBtn.Position = UDim2.new(1, -126, 0.5, -14)
    colBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    colBtn.Text = "🎨"
    colBtn.TextSize = 12
    Instance.new("UICorner", colBtn).CornerRadius = UDim.new(0, 4)
    colBtn.MouseButton1Click:Connect(function()
        openColorPicker(item.BackgroundColor3, lbl.TextColor3, function(newBg, newText)
            item.BackgroundColor3 = newBg
            ptData.BgColor = {newBg.R, newBg.G, newBg.B}
        end)
    end)
    
    local editCoordBtn = Instance.new("TextButton", item)
    editCoordBtn.Size = UDim2.new(0, 40, 0, 28)
    editCoordBtn.Position = UDim2.new(1, -86, 0.5, -14)
    editCoordBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 30)
    editCoordBtn.Text = "КООР"
    editCoordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    editCoordBtn.TextSize = 9
    Instance.new("UICorner", editCoordBtn).CornerRadius = UDim.new(0, 4)
    
    editCoordBtn.MouseButton1Click:Connect(function()
        local promptGui = Instance.new("Frame", gui)
        promptGui.Size = UDim2.new(0, 320, 0, 200)
        promptGui.Position = UDim2.new(0.5, -160, 0.5, -100)
        promptGui.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        promptGui.ZIndex = 20
        Instance.new("UICorner", promptGui).CornerRadius = UDim.new(0, 10)
        makeDraggable(promptGui)
        
        local warnLbl = Instance.new("TextLabel", promptGui)
        warnLbl.Size = UDim2.new(1, -20, 0, 50)
        warnLbl.Position = UDim2.new(0, 10, 0, 10)
        warnLbl.BackgroundTransparency = 1
        warnLbl.Text = "⚠️ Предупреждение!\nИзменение координат точки: " .. ptData.Name
        warnLbl.TextColor3 = Color3.fromRGB(255, 180, 50)
        warnLbl.TextSize = 11
        warnLbl.Font = Enum.Font.GothamBold
        warnLbl.ZIndex = 20
        
        local coordInput = Instance.new("TextBox", promptGui)
        coordInput.Size = UDim2.new(0.9, 0, 0, 34)
        coordInput.Position = UDim2.new(0.05, 0, 0, 70)
        coordInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        local curPosStr = string.format("%.1f, %.1f, %.1f", ptData.Pos[1], ptData.Pos[2], ptData.Pos[3])
        coordInput.Text = curPosStr
        coordInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        coordInput.TextSize = 11
        coordInput.ZIndex = 20
        Instance.new("UICorner", coordInput).CornerRadius = UDim.new(0, 6)
        
        local confirmBtn = Instance.new("TextButton", promptGui)
        confirmBtn.Size = UDim2.new(0.42, 0, 0, 34)
        confirmBtn.Position = UDim2.new(0.05, 0, 1, -44)
        confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
        confirmBtn.Text = "Принять"
        confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        confirmBtn.TextSize = 11
        confirmBtn.ZIndex = 20
        Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)
        
        local cancelBtn = Instance.new("TextButton", promptGui)
        cancelBtn.Size = UDim2.new(0.42, 0, 0, 34)
        cancelBtn.Position = UDim2.new(0.53, 0, 1, -44)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        cancelBtn.Text = "Отмена"
        cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cancelBtn.TextSize = 11
        cancelBtn.ZIndex = 20
        Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)
        
        confirmBtn.MouseButton1Click:Connect(function()
            local parts = {}
            for num in coordInput.Text:gmatch("[-%d%.]+") do
                table.insert(parts, tonumber(num))
            end
            if #parts >= 3 then
                ptData.HistoryPos = {unpack(ptData.Pos)}
                ptData.Pos[1] = parts[1]
                ptData.Pos[2] = parts[2]
                ptData.Pos[3] = parts[3]
                promptGui:Destroy()
            else
                coordInput.Text = "Формат: X, Y, Z"
            end
        end)
        
        cancelBtn.MouseButton1Click:Connect(function()
            promptGui:Destroy()
        end)
    end)
    
    local del = Instance.new("TextButton", item)
    del.Size = UDim2.new(0, 40, 0, 28)
    del.Position = UDim2.new(1, -44, 0.5, -14)
    del.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    del.Text = "×"
    del.TextColor3 = Color3.fromRGB(255, 255, 255)
    del.TextSize = 16
    Instance.new("UICorner", del).CornerRadius = UDim.new(0, 4)
    del.MouseButton1Click:Connect(function()
        for i, pt in ipairs(savedPointsData) do
            if pt == ptData then table.remove(savedPointsData, i) break end
        end
        item:Destroy()
    end)
end

addPointBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    if not root then return end
    local pos = root.CFrame
    local pName = (nameInput.Text ~= "") and nameInput.Text or "Точка"
    
    local ptData = {
        Name = pName,
        Pos = {pos.X, pos.Y, pos.Z},
        BgColor = {0.11, 0.11, 0.14},
        TextColor = {0.94, 0.94, 0.94},
        HistoryPos = nil
    }
    table.insert(savedPointsData, ptData)
    
    for _, child in ipairs(pointsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, pt in ipairs(savedPointsData) do
        createPointUI(pt)
    end
end)

-- ВКЛАДКА 5: ИГРОКИ
local playersContainer = Instance.new("Frame", t5)
playersContainer.Size = UDim2.new(1, 0, 0, 0)
playersContainer.BackgroundTransparency = 1
local plLayout = Instance.new("UIListLayout", playersContainer)
plLayout.Padding = UDim.new(0, 6)

local function updatePlayers()
    for _, c in ipairs(playersContainer:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local card = Instance.new("Frame", playersContainer)
            card.Size = UDim2.new(1, 0, 0, 40)
            card.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            
            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
            nameLbl.Position = UDim2.new(0.03, 0, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextSize = 11
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            local tpBtn = Instance.new("TextButton", card)
            tpBtn.Size = UDim2.new(0, 75, 0, 28)
            tpBtn.Position = UDim2.new(1, -81, 0.5, -14)
            tpBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 130)
            tpBtn.Text = "ТП к нему"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 11
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
            
            tpBtn.MouseButton1Click:Connect(function()
                local r = getRoot()
                local tChar = p.Character
                if r and tChar and tChar:FindFirstChild("HumanoidRootPart") then
                    r.CFrame = tChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end)
        end
    end
end
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)
task.spawn(updatePlayers)
-- ============================================================================
-- TELEPORT HUB ULTRA - ЧАСТЬ 3: Координаты, 3D-круг метки и Порталы
-- ============================================================================

-- ВКЛАДКА 2: КООРДИНАТЫ И ВЫБОР ТОЧКИ КЛИКОМ НА МЕСТО
local coordInfoLabel = Instance.new("TextLabel", t2)
coordInfoLabel.Size = UDim2.new(1, 0, 0, 45)
coordInfoLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
coordInfoLabel.Text = "Текущие координаты:\nX: 0, Y: 0, Z: 0"
coordInfoLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
coordInfoLabel.TextSize = 11
coordInfoLabel.Font = Enum.Font.Code
Instance.new("UICorner", coordInfoLabel).CornerRadius = UDim.new(0, 6)

RunService.RenderStepped:Connect(function()
    local r = getRoot()
    if r then
        local p = r.Position
        coordInfoLabel.Text = string.format("Текущие координаты:\nX: %.1f, Y: %.1f, Z: %.1f", p.X, p.Y, p.Z)
    end
end)

local pickPointActive = false
local pickPointBtn = Instance.new("TextButton", t2)
pickPointBtn.Size = UDim2.new(1, 0, 0, 35)
pickPointBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
pickPointBtn.Text = "📍 Выбрать точку на месте: ВЫКЛ"
pickPointBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
pickPointBtn.TextSize = 12
Instance.new("UICorner", pickPointBtn).CornerRadius = UDim.new(0, 6)

local circleColor = Color3.fromRGB(255, 50, 50)
local circleColorBtn = Instance.new("TextButton", t2)
circleColorBtn.Size = UDim2.new(1, 0, 0, 32)
circleColorBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
circleColorBtn.Text = "🎨 Изменить цвет круга-метки"
circleColorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
circleColorBtn.TextSize = 12
Instance.new("UICorner", circleColorBtn).CornerRadius = UDim.new(0, 6)

circleColorBtn.MouseButton1Click:Connect(function()
    openColorPicker(circleColor, Color3.fromRGB(255,255,255), function(newCol)
        circleColor = newCol
        circleColorBtn.BackgroundColor3 = newCol
    end)
end)

local activeMarkerPart = nil

pickPointBtn.MouseButton1Click:Connect(function()
    pickPointActive = not pickPointActive
    pickPointBtn.Text = pickPointActive and "📍 Выбрать точку на месте: ВКЛ" or "📍 Выбрать точку на месте: ВЫКЛ"
    pickPointBtn.BackgroundColor3 = pickPointActive and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(28, 28, 36)
end)

mouse.Button1Down:Connect(function()
    if pickPointActive and mouse.Target then
        local hitPos = mouse.Hit.Position
        
        if activeMarkerPart then activeMarkerPart:Destroy() end
        
        local marker = Instance.new("Part")
        marker.Name = "TeleportHubMarkerCircle"
        marker.Size = Vector3.new(0.2, 6, 6)
        marker.CFrame = CFrame.new(hitPos + Vector3.new(0, 0.1, 0)) * CFrame.Angles(math.pi/2, 0, 0)
        marker.Shape = Enum.PartType.Cylinder
        marker.Anchored = true
        marker.CanCollide = false
        marker.Material = Enum.Material.Neon
        marker.Color = circleColor
        marker.Parent = Workspace
        activeMarkerPart = marker
        
        coordInfoLabel.Text = string.format("Выбрано место!\nX: %.1f, Y: %.1f, Z: %.1f", hitPos.X, hitPos.Y, hitPos.Z)
        
        pickPointActive = false
        pickPointBtn.Text = "📍 Выбрать точку на месте: ВЫКЛ"
        pickPointBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    end
end)

-- ВКЛАДКА 3: ПОРТАЛЫ
local portalNameInput = Instance.new("TextBox", t3)
portalNameInput.Size = UDim2.new(1, 0, 0, 32)
portalNameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
portalNameInput.Text = "Портал 1"
portalNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
portalNameInput.TextSize = 12
portalNameInput.ClearTextOnFocus = false
Instance.new("UICorner", portalNameInput).CornerRadius = UDim.new(0, 6)

local createPortalBtn = Instance.new("TextButton", t3)
createPortalBtn.Size = UDim2.new(1, 0, 0, 32)
createPortalBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
createPortalBtn.Text = "🌀 Создать портал здесь"
createPortalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
createPortalBtn.TextSize = 12
Instance.new("UICorner", createPortalBtn).CornerRadius = UDim.new(0, 6)

local portalsContainer = Instance.new("Frame", t3)
portalsContainer.Size = UDim2.new(1, 0, 0, 0)
portalsContainer.BackgroundTransparency = 1
portalsContainer.AutomaticSize = Enum.AutomaticSize.Y
local portalLayout = Instance.new("UIListLayout", portalsContainer)
portalLayout.Padding = UDim.new(0, 6)

local portalsList = {}

local function createPortalPart(pData)
    local part = Instance.new("Part")
    part.Name = "TeleportHubPortal_" .. pData.Name
    part.Size = Vector3.new(4, 6, 1)
    part.CFrame = CFrame.new(unpack(pData.Pos))
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.3
    part.Material = Enum.Material.Glass
    part.Color = pData.Color or Color3.fromRGB(100, 50, 200)
    part.Parent = Workspace
    
    local debounce = false
    part.Touched:Connect(function(hit)
        if debounce then return end
        local char = hit.Parent
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and char == player.Character then
            if pData.LinkedTo and pData.LinkedTo.PartObj and pData.LinkedTo.PartObj.Parent then
                debounce = true
                local root = getRoot()
                if root then
                    root.CFrame = pData.LinkedTo.PartObj.CFrame + Vector3.new(0, 3, 0)
                end
                task.wait(1.5)
                debounce = false
            end
        end
    end)
    
    pData.PartObj = part
    return part
end

local function renderPortalsUI()
    for _, c in ipairs(portalsContainer:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    
    for _, portal in ipairs(portalsList) do
        local card = Instance.new("Frame", portalsContainer)
        card.Size = UDim2.new(1, 0, 0, 42)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        
        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Position = UDim2.new(0.03, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = portal.Name
        lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local linkBtn = Instance.new("TextButton", card)
        linkBtn.Size = UDim2.new(0, 65, 0, 28)
        linkBtn.Position = UDim2.new(1, -155, 0.5, -14)
        linkBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 120)
        linkBtn.Text = portal.LinkedTo and ("Связь: " .. portal.LinkedTo.Name) or "Связать..."
        linkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        linkBtn.TextSize = 9
        Instance.new("UICorner", linkBtn).CornerRadius = UDim.new(0, 4)
        
        linkBtn.MouseButton1Click:Connect(function()
            if #portalsList > 1 then
                for idx, p in ipairs(portalsList) do
                    if p == portal then
                        local nextIdx = (idx % #portalsList) + 1
                        portal.LinkedTo = portalsList[nextIdx]
                        linkBtn.Text = "Связь: " .. portal.LinkedTo.Name
                        break
                    end
                end
            end
        end)
        
        local colBtn = Instance.new("TextButton", card)
        colBtn.Size = UDim2.new(0, 35, 0, 28)
        colBtn.Position = UDim2.new(1, -85, 0.5, -14)
        colBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        colBtn.Text = "🎨"
        colBtn.TextSize = 12
        Instance.new("UICorner", colBtn).CornerRadius = UDim.new(0, 4)
        colBtn.MouseButton1Click:Connect(function()
            openColorPicker(portal.Color, Color3.fromRGB(255,255,255), function(newCol)
                portal.Color = newCol
                if portal.PartObj then portal.PartObj.Color = newCol end
            end)
        end)
        
        local delBtn = Instance.new("TextButton", card)
        delBtn.Size = UDim2.new(0, 35, 0, 28)
        delBtn.Position = UDim2.new(1, -45, 0.5, -14)
        delBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
        delBtn.Text = "×"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextSize = 16
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        delBtn.MouseButton1Click:Connect(function()
            if portal.PartObj then portal.PartObj:Destroy() end
            for i, p in ipairs(portalsList) do
                if p == portal then table.remove(portalsList, i) break end
            end
            renderPortalsUI()
        end)
    end
end

createPortalBtn.MouseButton1Click:Connect(function()
    local r = getRoot()
    if not r then return end
    local pName = (portalNameInput.Text ~= "") and portalNameInput.Text or ("Портал " .. (#portalsList + 1))
    local cf = r.CFrame + (r.CFrame.LookVector * 5)
    
    local portalData = {
        Name = pName,
        Pos = {cf:GetComponents()},
        Color = Color3.fromRGB(120, 50, 220),
        LinkedTo = nil,
        PartObj = nil
    }
    createPortalPart(portalData)
    table.insert(portalsList, portalData)
    
    if #portalsList > 1 then
        portalData.LinkedTo = portalsList[1]
    end
    
    renderPortalsUI()
end)
-- ============================================================================
-- TELEPORT HUB ULTRA - ЧАСТЬ 4: Free Cam, Быстрые ТП и Конфиги
-- ============================================================================

-- ВКЛАДКА 4: FREE CAM
local freeCamActive = false
local freeCamPos = CFrame.new()
local freeCamConn = nil

local freeCamToggleBtn = Instance.new("TextButton", t4)
freeCamToggleBtn.Size = UDim2.new(1, 0, 0, 35)
freeCamToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
freeCamToggleBtn.Text = "🎥 Free Camera: ВЫКЛ"
freeCamToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
freeCamToggleBtn.TextSize = 12
Instance.new("UICorner", freeCamToggleBtn).CornerRadius = UDim.new(0, 6)

local teleportToCamBtn = Instance.new("TextButton", t4)
teleportToCamBtn.Size = UDim2.new(1, 0, 0, 35)
teleportToCamBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
teleportToCamBtn.Text = "🚀 Телепорт на место камеры"
teleportToCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToCamBtn.TextSize = 12
Instance.new("UICorner", teleportToCamBtn).CornerRadius = UDim.new(0, 6)

freeCamToggleBtn.MouseButton1Click:Connect(function()
    freeCamActive = not freeCamActive
    if freeCamActive then
        freeCamToggleBtn.Text = "🎥 Free Camera: ВКЛ"
        freeCamToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
        
        local r = getRoot()
        if r then freeCamPos = r.CFrame end
        Camera.CameraType = Enum.CameraType.Scriptable
        
        freeCamConn = RunService.RenderStepped:Connect(function(dt)
            local speed = 50 * dt
            local moveDir = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (Camera.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (Camera.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (Camera.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (Camera.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            freeCamPos = freeCamPos + (moveDir * speed)
            Camera.CFrame = freeCamPos
        end)
    else
        freeCamToggleBtn.Text = "🎥 Free Camera: ВЫКЛ"
        freeCamToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        if freeCamConn then freeCamConn:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

teleportToCamBtn.MouseButton1Click:Connect(function()
    if freeCamActive then
        local r = getRoot()
        if r then
            r.CFrame = freeCamPos
        end
        freeCamActive = false
        freeCamToggleBtn.Text = "🎥 Free Camera: ВЫКЛ"
        freeCamToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        if freeCamConn then freeCamConn:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

-- БЫСТРЫЕ ТП ВО ВКЛАДКЕ FREECAM
local clickTpActive = false
local clickTpBtn = Instance.new("TextButton", t4)
clickTpBtn.Size = UDim2.new(1, 0, 0, 32)
clickTpBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
clickTpBtn.Text = "🎯 Клик-ТП (Тап-ТП): ВЫКЛ"
clickTpBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
clickTpBtn.TextSize = 12
Instance.new("UICorner", clickTpBtn).CornerRadius = UDim.new(0, 6)

clickTpBtn.MouseButton1Click:Connect(function()
    clickTpActive = not clickTpActive
    clickTpBtn.Text = clickTpActive and "🎯 Клик-ТП (Тап-ТП): ВКЛ" or "🎯 Клик-ТП (Тап-ТП): ВЫКЛ"
    clickTpBtn.BackgroundColor3 = clickTpActive and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(28, 28, 36)
end)

mouse.Button1Down:Connect(function()
    if clickTpActive and mouse.Target and not pickPointActive then
        local r = getRoot()
        if r then
            r.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

local function addOtherBtn(txt, callback)
    local b = Instance.new("TextButton", t4)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(callback)
end

addOtherBtn("🚀 ТП Вперед (30 блоков)", function()
    local r = getRoot()
    if r then r.CFrame = r.CFrame + (r.CFrame.LookVector * 30) end
end)

addOtherBtn("⬆️ ТП Наверх (+30 блоков)", function()
    local r = getRoot()
    if r then r.CFrame = r.CFrame + Vector3.new(0, 30, 0) end
end)

addOtherBtn("⬇️ ТП Вниз (-30 блоков)", function()
    local r = getRoot()
    if r then r.CFrame = r.CFrame + Vector3.new(0, -30, 0) end
end)

-- ВКЛАДКА 6: КОНФИГИ
local configNameInput = Instance.new("TextBox", t6)
configNameInput.Size = UDim2.new(1, 0, 0, 32)
configNameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
configNameInput.Text = "МойКонфиг_Ultra"
configNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameInput.TextSize = 12
configNameInput.ClearTextOnFocus = false
Instance.new("UICorner", configNameInput).CornerRadius = UDim.new(0, 6)

local saveConfigBtn = Instance.new("TextButton", t6)
saveConfigBtn.Size = UDim2.new(1, 0, 0, 32)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
saveConfigBtn.Text = "💾 Сохранить конфиг в файл"
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.TextSize = 12
Instance.new("UICorner", saveConfigBtn).CornerRadius = UDim.new(0, 6)

local configsContainer = Instance.new("Frame", t6)
configsContainer.Size = UDim2.new(1, 0, 0, 0)
configsContainer.BackgroundTransparency = 1
configsContainer.AutomaticSize = Enum.AutomaticSize.Y
local cfgLayout = Instance.new("UIListLayout", configsContainer)
cfgLayout.Padding = UDim.new(0, 6)

local savedConfigsList = {}

local function saveConfigsToFile()
    if writefile then
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(savedConfigsList)
        end)
        if success then
            writefile(CONFIGS_FILENAME, encoded)
        end
    end
end

local function createConfigUI(cName, configData)
    local item = Instance.new("Frame", configsContainer)
    item.Size = UDim2.new(1, 0, 0, 36)
    item.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", item)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0.03, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = cName
    lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local loadBtn = Instance.new("TextButton", item)
    loadBtn.Size = UDim2.new(0, 65, 0, 26)
    loadBtn.Position = UDim2.new(1, -127, 0.5, -13)
    loadBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
    loadBtn.Text = "Загрузить"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.TextSize = 10
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 4)
    
    loadBtn.MouseButton1Click:Connect(function()
        if configData.Points then
            savedPointsData = {}
            for _, pt in ipairs(configData.Points) do
                table.insert(savedPointsData, pt)
            end
            for _, child in ipairs(pointsContainer:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            for _, pt in ipairs(savedPointsData) do
                createPointUI(pt)
            end
        end
        loadBtn.Text = "Загружено!"
        task.delay(1, function() loadBtn.Text = "Загрузить" end)
    end)
    
    local delBtn = Instance.new("TextButton", item)
    delBtn.Size = UDim2.new(0, 55, 0, 26)
    delBtn.Position = UDim2.new(1, -58, 0.5, -13)
    delBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    delBtn.Text = "Удалить"
    delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delBtn.TextSize = 10
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
    
    delBtn.MouseButton1Click:Connect(function()
        for i, cfg in ipairs(savedConfigsList) do
            if cfg.Name == cName then table.remove(savedConfigsList, i) break end
        end
        saveConfigsToFile()
        item:Destroy()
    end)
end

saveConfigBtn.MouseButton1Click:Connect(function()
    local cName = (configNameInput.Text ~= "") and configNameInput.Text or "Конфиг"
    
    local configData = {
        Name = cName,
        Points = savedPointsData
    }
    
    local found = false
    for _, cfg in ipairs(savedConfigsList) do
        if cfg.Name == cName then
            cfg.Points = savedPointsData
            found = true
            break
        end
    end
    if not found then
        table.insert(savedConfigsList, configData)
    end
    
    saveConfigsToFile()
    
    for _, child in ipairs(configsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, cfg in ipairs(savedConfigsList) do
        createConfigUI(cfg.Name, cfg)
    end
end)

if readfile and isfile and isfile(CONFIGS_FILENAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(CONFIGS_FILENAME)) end)
    if success and decoded then
        savedConfigsList = decoded
        for _, cfg in ipairs(savedConfigsList) do
            createConfigUI(cfg.Name, cfg)
        end
    end
end
