local rs = game:GetService'RunService'

local s = Drawing.new'Square'
s.Visible = true
s.Opacity = 1
s.Filled = true
s.Color = Color3.new(0.15, 0.15, 0.15)
s.Position = Vector2.new(1000, 400)
s.Size = Vector2.new(200, 300)

local csp = 0
local objects = {}
local zin = 1

for i=1, 20 do
    local t = TextDynamic.new() table.insert(objects, t)
    t.Visible = true
    t.Center = true
    t.Outline = true
    t.Size = 20
    t.Color = Color3.new(1, 1, 1)
    t.Text = 'sup, i am ' .. tostring(i)
    t.Position = Point2D.new(s.Position + Vector2.new(s.Size.X / 2, 24 * i - 24))
    t.ZIndex = zin + 1
end

function scroll(dir)
    local endbounds = s.Position + s.Size
    local center = s.Position + s.Size / 2
    local topz = zin + 1
    local bottomz = zin + 2

    setcliprect(topz, Rect.new(s.Position, endbounds))
    setcliprect(bottomz, Rect.new(s.Position, endbounds))

    local isneg = dir < 0

    for i=1, math.abs(dir) do
        for i, v in pairs(objects) do
            local pos = v.Position.ScreenPos
            v.Position = Point2D.new(v.Position.ScreenPos + Vector2.new(0, isneg and -5 or 5))
            local istop = pos.Y < center.Y
            local vis = pos.Y > s.Position.Y - v.Size and pos.Y < endbounds.Y + v.Size / 2
            v.ZIndex = istop and topz or bottomz
            v.Visible = vis
        end
        -- wait()
        rs.RenderStepped:Wait() -- too fast
    end
end

local u = game:GetService'UserInputService'.InputChanged:Connect(function(i)
    if i.UserInputType.Name == 'MouseWheel' then
        scroll(i.Position.Z * 5)
    end
end)

wait(25)

u:Disconnect()
