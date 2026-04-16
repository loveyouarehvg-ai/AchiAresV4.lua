--// ACHI-ARES V4.2 (Loadstring Ready & RGB Ultimate)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local FlingToggle = Instance.new("TextButton")
local AimToggle = Instance.new("TextButton")
local AntiGrabToggle = Instance.new("TextButton")
local StrengthInput = Instance.new("TextBox")
local UIListLayout = Instance.new("UIListLayout")

--// Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

--// Config
local FlingEnabled = false
local AimbotEnabled = false
local AntiGrabEnabled = false
local StrengthMultiplier = 500
local AimKey = Enum.KeyCode.Q
local MenuKey = Enum.KeyCode.P

--// GUI Setup
ScreenGui.Name = "AchiAresV4_2"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -150)
MainFrame.Size = UDim2.new(0, 200, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

UIStroke.Thickness = 3
UIStroke.Parent = MainFrame

-- ระบบสีรุ้ง (Chroma RGB)
RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local color = Color3.fromHSV(hue, 1, 1)
    UIStroke.Color = color
    Title.TextColor3 = color
end)

Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ACHI ARES V4.2"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ปุ่มปิด (X)
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function StyleButton(btn, text)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Parent = MainFrame
end

StyleButton(FlingToggle, "Fling: OFF")
StyleButton(AimToggle, "Aimbot: OFF")
StyleButton(AntiGrabToggle, "Anti-Grab/Fling: OFF")

StrengthInput.Size = UDim2.new(0.9, 0, 0, 35)
StrengthInput.PlaceholderText = "Force..."
StrengthInput.Text = "500"
StrengthInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StrengthInput.TextColor3 = Color3.new(1, 1, 1)
StrengthInput.Parent = MainFrame
Instance.new("UICorner", StrengthInput).CornerRadius = UDim.new(0, 8)

--// LOGIC
local function UpdateToggle(btn, state, text)
    btn.Text = text .. (state and ": ON" or ": OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
end

FlingToggle.MouseButton1Click:Connect(function()
    FlingEnabled = not FlingEnabled
    UpdateToggle(FlingToggle, FlingEnabled, "Fling")
end)

AimToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    UpdateToggle(AimToggle, AimbotEnabled, "Aimbot")
end)

AntiGrabToggle.MouseButton1Click:Connect(function()
    AntiGrabEnabled = not AntiGrabEnabled
    UpdateToggle(AntiGrabToggle, AntiGrabEnabled, "Anti-Grab/Fling")
end)

StrengthInput.FocusLost:Connect(function()
    StrengthMultiplier = tonumber(StrengthInput.Text) or 500
end)

--// ตรรกะ Aimbot (Distance Magnitude)
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and UserInputService:IsKeyDown(AimKey) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            if mouse1click then mouse1click() end
        end
    end
end)

--// ANTI-GRAB/FLING (Force Release)
RunService.Stepped:Connect(function()
    if AntiGrabEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
                for _, obj in pairs(part:GetChildren()) do
                    if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj.Name == "GrabPart" then
                        obj:Destroy()
                    end
                end
            end
        end
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            if hum.Sit then hum.Sit = false end
        end
    end
end)

--// FLING LOGIC
workspace.ChildAdded:Connect(function(m)
    if FlingEnabled and m.Name == "GrabParts" then
        local gp = m:WaitForChild("GrabPart", 2)
        if gp and gp:FindFirstChild("WeldConstraint") then
            local p1 = gp.WeldConstraint.Part1
            if p1 then
                local bv = Instance.new("BodyVelocity", p1)
                m:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not m.Parent then
                        if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = Camera.CFrame.LookVector * StrengthMultiplier
                            Debris:AddItem(bv, 1)
                        else
                            bv:Destroy()
                        end
                    end
                end)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == MenuKey then MainFrame.Visible = not MainFrame.Visible end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Achi Ares V4.2", Text = "Loadstring Successful! Press P to Open Menu"})
