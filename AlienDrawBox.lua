local objs = {};
local function drawPoly(instance, offsets)
    local points = table.create(#offsets)
    for i = 1, #offsets do
        points[i] = PointInstance.new(instance, offsets[i])
    end

    local object = PolyLineDynamic.new(points)
    object.Color = Color3.new(1, 1, 1)
    object.FillType = PolyLineFillType.ConvexFilled;

    objs[#objs + 1] = object;
end


local function drawBlock(part)
    local cf, size = part.CFrame, part.Size;

    -- front
    -- top right corner
    local frontTopRight = CFrame.new(-size.X/2, size.Y/2, -size.Z/2)
    -- top left corner
    local frontTopLeft = CFrame.new(size.X/2, size.Y/2, -size.Z/2)
    -- bottom left corner
    local frontBotLeft = CFrame.new(size.X/2, -size.Y/2, -size.Z/2)
    -- bottom right corner
    local frontBotRight = CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)

    -- back
    -- top right corner
    local backTopRight = CFrame.new(-size.X/2, size.Y/2, size.Z/2)
    -- top left corner
    local backTopLeft = CFrame.new(size.X/2, size.Y/2, size.Z/2)
    -- bottom left corner
    local backBotLeft = CFrame.new(size.X/2, -size.Y/2, size.Z/2)
    -- bottom right corner
    local backBotRight = CFrame.new(-size.X/2, -size.Y/2, size.Z/2)


    drawPoly(part, { frontTopRight, frontTopLeft, frontBotLeft, frontBotRight })
    drawPoly(part, { backTopRight, backTopLeft, backBotLeft, backBotRight })
    drawPoly(part, { backTopRight, backTopLeft, frontTopLeft, frontTopRight })
    drawPoly(part, { backBotRight, backBotLeft, frontBotLeft, frontBotRight })
    drawPoly(part, { frontTopLeft, backTopLeft, backBotLeft, frontBotLeft })
    drawPoly(part, { frontTopRight, backTopRight, backBotRight, frontBotRight })
end

local character = game.Players.LocalPlayer.Character

for i, part in next, {
    character.Head,
    character['Left Arm'],
    character['Left Leg'],
    character['Right Arm'],
    character['Right Leg'],
    character.HumanoidRootPart
} do
    drawBlock(part)
end

wait(10)
