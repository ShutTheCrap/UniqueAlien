local Players = game:GetService'Players'
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()
local RunService = game:GetService'RunService'
local InputService = game:GetService'UserInputService'
local Camera = workspace.CurrentCamera
local RootPart = LocalPlayer.Character.HumanoidRootPart
local Size = 5
local Amount = 25

local x = DrawingImmediate.GetPaint(1):Connect(function()
    local Center = InputService:GetMouseLocation() - (Vector2.new(Size, Size) / 2)
    local RootRel = (RootPart.Position - Camera.CFrame.Position)

    for X = -Size * Amount, Size * Amount, Size do
        for Y = -Size * Amount, Size * Amount, Size do
            local Position = Vector2.new(Center.X + X, Center.Y + Y)
            local ScreenRay = Camera:ViewportPointToRay(Center.X + X, Center.Y + Y)

            ScreenRay = Ray.new(ScreenRay.Origin, ScreenRay.Direction * 250)

            local Hit, HitPosition = workspace:FindPartOnRay(ScreenRay)

            if Hit then
                DrawingImmediate.FilledRectangle(Position + Vector2.new(0, 22), Vector2.new(Size, Size), Hit.Color, 1 - Hit.Transparency - 0.1, 0)
            end
        end
    end
end)

wait(10)

x:Disconnect()
