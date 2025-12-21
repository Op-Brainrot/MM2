local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for LocalPlayer
if not game:IsLoaded() then
    pcall(function() game.Loaded:Wait() end)
end

local function waitForLP(timeout)
    local t0 = os.clock()
    while not Players.LocalPlayer do
        Players.PlayerAdded:Wait()
        if timeout and (os.clock()-t0) > timeout then break end
    end
    return Players.LocalPlayer
end
local LP = Players.LocalPlayer or waitForLP(10)

-- Mute all sounds and videos
local function removeAllSounds(container)
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Sound") or obj:IsA("VideoFrame") then
            obj:Destroy()
        end
    end
end

removeAllSounds(workspace)
removeAllSounds(SoundService)
removeAllSounds(Lighting)
removeAllSounds(StarterGui)
removeAllSounds(ReplicatedStorage)
removeAllSounds(LP:WaitForChild("PlayerGui", 5) or Instance.new("Folder"))

local function watch(container)
    container.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sound") or obj:IsA("VideoFrame") then
            obj:Destroy()
        end
    end)
end

watch(workspace)
watch(SoundService)
watch(Lighting)
watch(StarterGui)
watch(ReplicatedStorage)
watch(LP)

game.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") or obj:IsA("VideoFrame") then
        obj:Destroy()
    end
end)

-- Parent setup
local CoreGui = game:GetService("CoreGui")
local UIParent
do
    local playerGui = LP and LP:FindFirstChildOfClass("PlayerGui")
    if not playerGui and LP then
        pcall(function() playerGui = LP:WaitForChild("PlayerGui", 2) end)
    end
    if playerGui then
        UIParent = playerGui
    else
        UIParent = CoreGui
    end
end

-- Cleanup and create ScreenGui
local OLD = UIParent:FindFirstChild("LoadingScreen_GUI")
if OLD then OLD:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = "LoadingScreen_GUI"
SG.IgnoreGuiInset = true
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
SG.DisplayOrder = 999999
SG.Parent = UIParent

-- Colors
local COLORS = {
    bg = Color3.fromRGB(6,8,16),
    card = Color3.fromRGB(14,12,24),
    text = Color3.fromRGB(235,235,245),
    dim  = Color3.fromRGB(170,175,200),
    a1   = Color3.fromRGB(130,90,255),
    a2   = Color3.fromRGB(50,180,255),
}

-- Notification System
local function createNotification(message, duration)
    local notif = Instance.new("Frame", SG)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.Position = UDim2.new(0.5, 0, 0, -100)
    notif.Size = UDim2.new(0, 400, 0, 80)
    notif.BackgroundColor3 = COLORS.card
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.ZIndex = 99999
    
    local notifCorner = Instance.new("UICorner", notif)
    notifCorner.CornerRadius = UDim.new(0, 12)
    
    local notifStroke = Instance.new("UIStroke", notif)
    notifStroke.Thickness = 2
    notifStroke.Color = COLORS.a1
    notifStroke.Transparency = 0.3
    
    local icon = Instance.new("TextLabel", notif)
    icon.Size = UDim2.new(0, 60, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 32
    icon.TextColor3 = COLORS.a1
    icon.ZIndex = 100000
    
    local text = Instance.new("TextLabel", notif)
    text.Position = UDim2.new(0, 60, 0, 0)
    text.Size = UDim2.new(1, -70, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextColor3 = COLORS.text
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 100000
    
    -- Slide in animation
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()
    
    -- Wait and slide out
    task.delay(duration or 5, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, -100)
        }):Play()
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- Show notification
task.delay(2, function()
    createNotification("⏳WAIT FOR 5-7 MINUTE TO ACCESS THE SCRIPT⏳", 6)
end)

-- Main container (centered card)
local Container = Instance.new("Frame", SG)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Position = UDim2.fromScale(0.5, 0.5)
Container.Size = UDim2.fromOffset(480, 360)
Container.BackgroundColor3 = COLORS.card
Container.BackgroundTransparency = 0.08
Container.BorderSizePixel = 0
Container.ZIndex = 10

local containerCorner = Instance.new("UICorner", Container)
containerCorner.CornerRadius = UDim.new(0, 20)

local containerStroke = Instance.new("UIStroke", Container)
containerStroke.Thickness = 2
containerStroke.Transparency = 0.15
containerStroke.ZIndex = 11

local strokeGrad = Instance.new("UIGradient", containerStroke)
strokeGrad.Color = ColorSequence.new(COLORS.a1, Color3.new(0,0,0), COLORS.a2)

-- Header Section
local Header = Instance.new("Frame", Container)
Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1, -40, 0, 90)
Header.Position = UDim2.new(0, 20, 0, 20)
Header.ZIndex = 20

-- Avatar with glow effect
local AvatarContainer = Instance.new("Frame", Header)
AvatarContainer.Size = UDim2.fromOffset(70, 70)
AvatarContainer.BackgroundTransparency = 1
AvatarContainer.ZIndex = 21

local Avatar = Instance.new("ImageLabel", AvatarContainer)
Avatar.BackgroundTransparency = 1
Avatar.Size = UDim2.fromScale(1, 1)
Avatar.Image = "rbxassetid://0"
Avatar.ZIndex = 22
Avatar.BackgroundColor3 = COLORS.card

local avatarCorner = Instance.new("UICorner", Avatar)
avatarCorner.CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", Avatar)
avatarStroke.Thickness = 3
avatarStroke.Color = COLORS.a1
avatarStroke.Transparency = 0.3

-- Avatar glow effect
local avatarGlow = Instance.new("ImageLabel", AvatarContainer)
avatarGlow.Size = UDim2.fromScale(1.3, 1.3)
avatarGlow.Position = UDim2.fromScale(0.5, 0.5)
avatarGlow.AnchorPoint = Vector2.new(0.5, 0.5)
avatarGlow.BackgroundTransparency = 1
avatarGlow.Image = "rbxassetid://0"
avatarGlow.ImageTransparency = 0.6
avatarGlow.ZIndex = 21

local glowCorner = Instance.new("UICorner", avatarGlow)
glowCorner.CornerRadius = UDim.new(1, 0)

-- Load avatar
task.spawn(function()
    if LP then
        local ok, url = pcall(Players.GetUserThumbnailAsync, Players, LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if ok and url then 
            Avatar.Image = url 
            avatarGlow.Image = url
        end
    end
end)

-- Pulsing glow animation
task.spawn(function()
    while avatarGlow and avatarGlow.Parent do
        TweenService:Create(avatarGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.8,
            Size = UDim2.fromScale(1.4, 1.4)
        }):Play()
        task.wait(1.5)
        TweenService:Create(avatarGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.6,
            Size = UDim2.fromScale(1.3, 1.3)
        }):Play()
        task.wait(1.5)
    end
end)

-- User Info Container
local InfoContainer = Instance.new("Frame", Header)
InfoContainer.BackgroundTransparency = 1
InfoContainer.Size = UDim2.new(1, -90, 1, 0)
InfoContainer.Position = UDim2.new(0, 90, 0, 0)
InfoContainer.ZIndex = 21

-- Title
local Title = Instance.new("TextLabel", InfoContainer)
Title.BackgroundTransparency = 1
Title.Text = "DesyncHub"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 28
Title.TextColor3 = COLORS.a1
Title.TextStrokeColor3 = Color3.fromRGB(20, 0, 40)
Title.TextStrokeTransparency = 0.5
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Size = UDim2.new(1, 0, 0, 32)
Title.ZIndex = 22

-- Username and info
local UserInfo = Instance.new("TextLabel", InfoContainer)
UserInfo.BackgroundTransparency = 1
UserInfo.Font = Enum.Font.Gotham
UserInfo.TextSize = 13
UserInfo.TextColor3 = COLORS.dim
UserInfo.TextXAlignment = Enum.TextXAlignment.Left
UserInfo.Size = UDim2.new(1, 0, 0, 20)
UserInfo.Position = UDim2.new(0, 0, 0, 34)
UserInfo.ZIndex = 22

-- Fill user info
task.spawn(function()
    local name = LP and LP.Name or "User"
    local dname = LP and LP.DisplayName or "Player"
    local age = LP and (tostring(LP.AccountAge).." days") or "N/A"
    local premium = (LP and LP.MembershipType and tostring(LP.MembershipType):find("Premium")) and "⭐ Premium" or "Standard"
    UserInfo.Text = string.format("%s (@%s) • %s • %s", dname, name, age, premium)
end)

-- Badge/Status
local Badge = Instance.new("TextLabel", InfoContainer)
Badge.BackgroundTransparency = 1
Badge.Text = "Loading..."
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 13
Badge.TextColor3 = COLORS.a2
Badge.TextXAlignment = Enum.TextXAlignment.Left
Badge.Size = UDim2.new(1, 0, 0, 18)
Badge.Position = UDim2.new(0, 0, 0, 56)
Badge.ZIndex = 22

-- Divider Line
local Divider = Instance.new("Frame", Container)
Divider.Size = UDim2.new(1, -40, 0, 1)
Divider.Position = UDim2.new(0, 20, 0, 125)
Divider.BackgroundColor3 = COLORS.dim
Divider.BackgroundTransparency = 0.85
Divider.BorderSizePixel = 0
Divider.ZIndex = 20

-- Loading Section
local LoadingSection = Instance.new("Frame", Container)
LoadingSection.BackgroundTransparency = 1
LoadingSection.Size = UDim2.new(1, -40, 0, 180)
LoadingSection.Position = UDim2.new(0, 20, 0, 140)
LoadingSection.ZIndex = 20

-- Status text
local StatusText = Instance.new("TextLabel", LoadingSection)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing"
StatusText.Font = Enum.Font.GothamSemibold
StatusText.TextSize = 18
StatusText.TextColor3 = COLORS.text
StatusText.Size = UDim2.new(1, 0, 0, 26)
StatusText.Position = UDim2.new(0, 0, 0, 10)
StatusText.ZIndex = 22
StatusText.TextXAlignment = Enum.TextXAlignment.Center

-- Progress Container
local ProgressContainer = Instance.new("Frame", LoadingSection)
ProgressContainer.Size = UDim2.new(1, 0, 0, 10)
ProgressContainer.Position = UDim2.new(0, 0, 0, 55)
ProgressContainer.BackgroundColor3 = Color3.fromRGB(20, 18, 34)
ProgressContainer.BackgroundTransparency = 0.1
ProgressContainer.BorderSizePixel = 0
ProgressContainer.ZIndex = 21

local progressCorner = Instance.new("UICorner", ProgressContainer)
progressCorner.CornerRadius = UDim.new(1, 0)

local progressStroke = Instance.new("UIStroke", ProgressContainer)
progressStroke.Thickness = 1
progressStroke.Color = Color3.fromRGB(40, 40, 80)
progressStroke.Transparency = 0.3

-- Progress Bar
local ProgressBar = Instance.new("Frame", ProgressContainer)
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = COLORS.a1
ProgressBar.BorderSizePixel = 0
ProgressBar.ZIndex = 22

local barCorner = Instance.new("UICorner", ProgressBar)
barCorner.CornerRadius = UDim.new(1, 0)

local barGrad = Instance.new("UIGradient", ProgressBar)
barGrad.Color = ColorSequence.new(COLORS.a1, COLORS.a2)

-- Percentage
local Percentage = Instance.new("TextLabel", LoadingSection)
Percentage.BackgroundTransparency = 1
Percentage.Text = "0%"
Percentage.Font = Enum.Font.GothamBold
Percentage.TextSize = 24
Percentage.TextColor3 = COLORS.a2
Percentage.Size = UDim2.new(1, 0, 0, 28)
Percentage.Position = UDim2.new(0, 0, 0, 80)
Percentage.ZIndex = 22
Percentage.TextXAlignment = Enum.TextXAlignment.Center

-- Subtitle
local Subtitle = Instance.new("TextLabel", LoadingSection)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = ""
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextColor3 = COLORS.dim
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 120)
Subtitle.ZIndex = 22
Subtitle.TextXAlignment = Enum.TextXAlignment.Center

-- Info Cards at Bottom
local InfoCardsContainer = Instance.new("Frame", LoadingSection)
InfoCardsContainer.BackgroundTransparency = 1
InfoCardsContainer.Size = UDim2.new(1, 0, 0, 30)
InfoCardsContainer.Position = UDim2.new(0, 0, 0, 150)
InfoCardsContainer.ZIndex = 20

local function createInfoCard(text, icon, position)
    local card = Instance.new("Frame", InfoCardsContainer)
    card.Size = UDim2.new(0.31, 0, 1, 0)
    card.Position = position
    card.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.ZIndex = 21
    
    local corner = Instance.new("UICorner", card)
    corner.CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", card)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextColor3 = COLORS.dim
    label.ZIndex = 22
end

createInfoCard("Secure", "🔒", UDim2.fromScale(0, 0))
createInfoCard("Fast", "⚡", UDim2.fromScale(0.345, 0))
createInfoCard("Latest", "✨", UDim2.fromScale(0.69, 0))

-- Dots animation
local dotsText = ""
task.spawn(function()
    while StatusText and StatusText.Parent do
        for i = 0, 3 do
            if not StatusText or not StatusText.Parent then break end
            local dots = string.rep(".", i)
            StatusText.Text = dotsText .. dots
            task.wait(0.4)
        end
    end
end)

-- Loading sequence (stuck at 100%)
local loadingSteps = {
    {text = "Loading...", time = 55, progress = 35},
    {text = "Loading assets", time = 55, progress = 65},
    {text = "Connecting to server", time = 55, progress = 100},
}

task.spawn(function()
    for _, step in ipairs(loadingSteps) do
        dotsText = step.text
        Badge.Text = step.text
        
        -- Animate progress
        local targetSize = UDim2.new(step.progress / 100, 0, 1, 0)
        TweenService:Create(ProgressBar, TweenInfo.new(step.time * 0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
        
        -- Animate percentage
        local startPercent = tonumber(Percentage.Text:match("%d+")) or 0
        local steps = math.floor(step.time * 40)
        for i = 1, steps do
            local alpha = i / steps
            local currentPercent = math.floor(startPercent + (step.progress - startPercent) * alpha)
            Percentage.Text = currentPercent .. "%"
            task.wait(step.time / steps)
        end
        
        task.wait(0.5)
    end
    
    -- Stay stuck at 100%
    dotsText = "Connecting to server"
    Badge.Text = "Connecting..."
end)

-- Entry animation
Background.BackgroundTransparency = 1
Container.Size = UDim2.fromOffset(0, 0)
Container.BackgroundTransparency = 1
containerStroke.Transparency = 1

task.wait(0.1)

TweenService:Create(Background, TweenInfo.new(0.5), {
    BackgroundTransparency = 0
}):Play()

task.wait(0.2)

TweenService:Create(Container, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(480, 360),
    BackgroundTransparency = 0.08
}):Play()

TweenService:Create(containerStroke, TweenInfo.new(0.7), {
    Transparency = 0.15
}):Play()

task.wait(0.3)

-- Fade in all elements
for _, element in ipairs({Avatar, Title, UserInfo, Badge, StatusText, Percentage, Subtitle}) do
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        element.TextTransparency = 1
        TweenService:Create(element, TweenInfo.new(0.5), {
            TextTransparency = 0
        }):Play()
    elseif element:IsA("ImageLabel") then
        element.ImageTransparency = 1
        TweenService:Create(element, TweenInfo.new(0.5), {
            ImageTransparency = 0
        }):Play()
    end
    task.wait(0.1)
end

-- Dragging functionality
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
