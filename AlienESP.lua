local Players = game:GetService'Players'
local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local UserInput = game:GetService'UserInputService'
local RunService = game:GetService'RunService'
local V2New = Vector2.new
local V3New = Vector3.new
local MousePosition = V2New()
local Camera = workspace.CurrentCamera
local WTVP, Floor = Camera.WorldToViewportPoint, math.floor
local WorldToScreen = function(...) return WTVP(Camera, ...) end
local fromOffset = UDim2.fromOffset
-- local WorldToScreen = function(WorldPosition) return worldtoscreen(WorldPosition) end
local Enabled = true
local UseTeamColors = false
local Marked = {}
local Spectating

local Green, Red = Color3.new(0, 1, 0), Color3.new(1, 0, 0)

-- local TextFont = nil -- shared.TextFont
local G_TextSize = 13
local TextFont = Font.RegisterDefault('ProggyClean', { PixelSize = G_TextSize, UseStb = true, Scale = false, Bold = false }) --shared.TextFont

if not TextFont then
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/fonts/VCR_OSD_MONO_1.001.ttf'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/AmongUs-Regular.ttf'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/smallpixelfont.ttf'
    -- local fc = FontCollection.new()
    -- fc:AddFont(game:HttpGet'https://ic3w0lf.xyz/fonts/ProggyClean.ttf')
    -- fc:Register()
    -- TextFont = fc:GetFont'ProggyCleanTT'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/fonts/ProggyClean.ttf'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/fonts/gallifreyan.ttf'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/fonts/smallestfont.ttf'
    -- TextFont = game:HttpGet'https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf'
    -- TextFont = game:HttpGet'https://ic3w0lf.xyz/verdanab.ttf'
    TextFont = Font.Register(game:HttpGet'https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf', {
        Scale = false,
        Bold = false,
        UseStb = true,
        PixelSize = G_TextSize
    })
    -- TextFont = Font.GetDefault'AnonymousPro-Regular'
    shared.TextFont = TextFont
    -- wait(1)
end

if shared.ClearESP then shared.ClearESP() end

local PlayerGlobalUpdate

local function Scramble(String)
    local Chars = string.split(String, '')

    for i = 1, #String do
        local R = math.floor(math.random() * (i)) + 1
        local tmp = Chars[i]

        Chars[i] = Chars[R]
        Chars[R] = tmp
    end

    return table.concat(Chars, '')
end

local function IsEven(Num)
    return Num % 2 == 0
end

local cPlayer = {} do
    cPlayer.__index = cPlayer

    function cPlayer.new(PlayerInstance)
        assert(typeof(PlayerInstance) == 'Instance' and PlayerInstance:IsA'Player')

        local Player = {} setmetatable(Player, cPlayer)

        Player.Player = PlayerInstance
        Player.Character = PlayerInstance.Character
        Player.Name = game.PlaceId == 5208655184-1 and Scramble(PlayerInstance.Name) or PlayerInstance.Name
        Player.Drawings = table.create(8)
        Player.Points = table.create(8)
        Player.C_CharacterAdded = PlayerInstance.CharacterAdded:Connect(function(Character) Player:SetupCharacter(Character) end)
        Player.C_CharacterRemoved = PlayerInstance.CharacterRemoving:Connect(function() Player.Character = nil end)
        Player.ScreenPosition = V2New()
        Player.ScreenBounds = Rect.new()
        Player.Color = Color3.new(1, 1, 1)
        Player.OutlineColor = Color3.new(0.15, 0.15, 0.15)
        Player.LastCharacterCheck = 0
        Player.vdt = table.create(0)
        Player.BodyParts = table.create(6)
        Player.IsR6 = false
        Player.Tags = table.create(0)

        Player:SetupCharacter(Player.Character)
        Player:SetupDrawings()

        return Player
    end

    function cPlayer:SetupCharacter(Character)
        self.Character = Character
        self.RootPart = Character and Character:WaitForChild('HumanoidRootPart', 1)
        self.Humanoid = Character and Character:FindFirstChildOfClass'Humanoid'
        self.IsR6 = self.Humanoid and self.Humanoid.RigType == 0
        self.Health = self.Humanoid and self.Humanoid.Health or 100
        self.MHealth = self.Humanoid and self.Humanoid.MaxHealth or 100
    end

    function cPlayer:SetupDrawings()
        -- local OutlineBox = RectDynamic.new()
        -- OutlineBox.Color = self.OutlineColor
        -- OutlineBox.Filled = false
        -- OutlineBox.Visible = true
        -- OutlineBox.Opacity = 1
        -- OutlineBox.ZIndex = 0
        -- OutlineBox.Thickness = 4
        -- OutlineBox.Position = Point2D.new()

        local Box = RectDynamic.new()
        Box.Color = self.Color
        Box.Filled = false
        Box.Visible = true
        Box.Opacity = 1
        Box.Thickness = 1.5
        Box.ZIndex = 2
        Box.Position = Point2D.new(-400, -400)
        Box.Rounding = 5
        Box.Outlined = true
        Box.OutlineOpacity = 1
        Box.OutlineColor = Color3.fromRGB(10, 10, 10)
        Box.OutlineThickness = 1

        -- OutlineBox.Rounding = Box.Rounding

        local HealthBarOutline = RectDynamic.new()
        HealthBarOutline.Color = Color3.new(0, 0, 0)
        HealthBarOutline.Filled = false
        HealthBarOutline.Visible = true
        HealthBarOutline.Opacity = 1
        HealthBarOutline.Thickness = 1
        HealthBarOutline.ZIndex = 1
        HealthBarOutline.YAlignment = YAlignment.Bottom

        local HealthBar = RectDynamic.new()
        HealthBar.Color = Color3.new(0, 1, 0)
        HealthBar.Filled = true
        HealthBar.Visible = true
        HealthBar.Opacity = 1
        HealthBar.Thickness = 1
        HealthBar.YAlignment = YAlignment.Bottom
        HealthBar.ZIndex = 2
        HealthBar.Position = Point2D.new(-400, -400)
        HealthBarOutline.Position = PointOffset.new(HealthBar.Position, 0, -1)

        local TextSizeT = G_TextSize

        local HealthText = TextDynamic.new()
        HealthText.Font = TextFont
        HealthText.Size = TextSizeT
        HealthText.Color = self.Color
        HealthText.Outlined = true
        HealthText.OutlineOpacity = 1
        HealthText.OutlineColor = self.OutlineColor
        HealthText.XAlignment = XAlignment.Left
        HealthText.YAlignment = YAlignment.Bottom
        HealthText.ZIndex = 2
        HealthText.Position = Point2D.new()

        local Name = TextDynamic.new()
        Name.Font = TextFont
        Name.Size = TextSizeT
        Name.Color = self.Color
        Name.Outlined = true
        Name.OutlineOpacity = 0.5
        Name.OutlineColor = self.OutlineColor
        Name.XAlignment = XAlignment.Center
        Name.YAlignment = YAlignment.Top
        Name.ZIndex = 2
        Name.Position = Point2D.new()

        local Tags = TextDynamic.new()
        Tags.Font = TextFont
        Tags.Size = TextSizeT
        Tags.Color = self.Color
        Tags.Outlined = true
        Tags.OutlineOpacity = 0.5
        Tags.OutlineColor = self.OutlineColor
        Tags.XAlignment = XAlignment.Right
        Tags.YAlignment = YAlignment.Bottom
        Tags.ZIndex = 2
        Tags.Position = Point2D.new()
        
        local Distance = TextDynamic.new()
        Distance.Font = TextFont
        Distance.Size = TextSizeT
        Distance.Color = self.Color
        Distance.Outlined = true
        Distance.OutlineOpacity = 0.5
        Distance.OutlineColor = self.OutlineColor
        Distance.XAlignment = XAlignment.Center
        Distance.YAlignment = YAlignment.Bottom
        Distance.ZIndex = 2
        Distance.Position = Point2D.new()

        self.Drawings.OutlineBox = OutlineBox
        self.Drawings.Box = Box
        self.Drawings.Name = Name
        self.Drawings.Tags = Tags
        self.Drawings.Distance = Distance
        self.Drawings.HealthBar = HealthBar
        self.Drawings.HealthText = HealthText
        self.Drawings.HealthBarOutline = HealthBarOutline
    end

    function cPlayer:Update()
        local Tick = tick()

        if Tick - self.LastCharacterCheck > 0.25 and self.Character then
            self.LastCharacterCheck = Tick
            self.RootPart = self.Character:FindFirstChild'HumanoidRootPart'
            self.Humanoid = self.Character:FindFirstChild'Humanoid'
            self.BodyParts[1] = self.Character:FindFirstChild('Head')
            self.BodyParts[2] = self.Character:FindFirstChild(self.IsR6 and 'Right Arm' or 'RightLowerArm')
            self.BodyParts[3] = self.Character:FindFirstChild(self.IsR6 and 'Left Arm' or 'LeftLowerArm')
            self.BodyParts[4] = self.Character:FindFirstChild(self.IsR6 and 'Right Leg' or 'RightLowerLeg')
            self.BodyParts[5] = self.Character:FindFirstChild(self.IsR6 and 'Left Leg' or 'LeftLowerLeg')

            if PlayerGlobalUpdate then PlayerGlobalUpdate(self) end

            if not self.Character:IsDescendantOf(workspace) then
                self.Character = nil
            end
        end

        if self.Character and self.RootPart then
            self.CFrame = self.RootPart.CFrame
            self.Position = self.RootPart.Position
            self.Relative = (self.Position - Camera.CFrame.Position)
            self.Distance = self.Relative.Magnitude
            self.OnScreen = self.Relative:Dot(Camera.CFrame.LookVector) > 0

            if self.OnScreen then
                -- local Center, Size = getboundingbox(self.BodyParts, Camera:GetRenderCFrame())
                -- Size /= 1.75

                -- local sX, sY = Size.X, Size.Y
                -- local Points = worldtoscreen({
                --     (Center * CFrame.new(-sX, sY, 0)).p, -- topLeft
                --     (Center * CFrame.new(sX, sY, 0)).p, -- topRight

                --     (Center * CFrame.new(0, sY, 0)).p, -- topMiddle
                --     (Center * CFrame.new(0, -sY, 0)).p, -- bottomMiddle

                --     (Center * CFrame.new(-sX, -sY, 0)).p, -- bottomLeft
                --     (Center * CFrame.new(sX, -sY, 0)).p, -- bottomRight
                -- })

                -- local Count = #Points

                -- if Count <= 4 then
                    -- cprint(tableToString(Points))
                -- end

                -- if #Points == 6 then
                    local Drawings = self.Drawings
                    local Position = WorldToScreen(self.Position) -- if not Position then self:HideDrawings() return end
                    local ScreenPosition = V2New(Floor(Position.X), Floor(Position.Y))
                    -- local Size = Points[6] - Points[1]
                    local Distance = (self.Position - Camera.CFrame.Position).Magnitude
                    local TrueSize = V2New(2800, 3800) / Distance
                    local SX = Floor(TrueSize.X) if not IsEven(SX) then SX += 1 end
                    local SY = Floor(TrueSize.Y) if not IsEven(SY) then SY += 1 end
                    local Size = V2New(math.max(SX, 4), math.max(SY, 6))
                    local RM = (ScreenPosition - MousePosition)
                    local MouseOver = RM.Magnitude < 50
                    local Humanoid = self.Humanoid
                    local Health = Humanoid and Humanoid.Health or 100
                    local MHealth = Humanoid and Humanoid.MaxHealth or 100

                    self.ScreenPosition = ScreenPosition
                    self.ScreenBounds = Bounds

                    if self.TrueLastSize ~= TrueSize or self.Health ~= Health or MouseOver then -- Only update things on the side if they need updating instead of every single frame, should be accurate 99.8% of the time, saves some compootr time when someone isnt moving
                        self.TrueLastSize = TrueSize
                        self.Health = Health
                        self.MaxHealth = MHealth
                        self:ShowDrawings'Box, Name, Distance, Tags'

                        local Opacity = math.clamp(1 - Distance / 1000, 0.35, 1)
                        local OutlineOpacity = Opacity - 0.1
                        local TopLeft, BottomRight = ScreenPosition - Size / 2, ScreenPosition + Size / 2
                        -- local Bounds = Rect.new(TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y)

                        if MouseOver then
                            Opacity = math.clamp(Opacity + (1 - RM.Magnitude / 50), 0.35, 1)
                        end
                        
                        local TextSize = G_TextSize
                        -- math.clamp(700 / Distance * 2.5, 8.5, 10) + (math.clamp((Opacity * 10), 0, 10) - 0.35) -- 10

                        local Box = Drawings.Box
                        local OutlineBox = Drawings.OutlineBox
                        local Name = Drawings.Name
                        local Distance = Drawings.Distance
                        local HealthBar = Drawings.HealthBar
                        local HealthBarOutline = Drawings.HealthBarOutline
                        local HealthText = Drawings.HealthText
                        local Tags = Drawings.Tags
                        
                        Box.Position.Point = fromOffset(ScreenPosition.X, ScreenPosition.Y)
                        Box.Size = Size
                        Box.Opacity = Opacity + 1
                        Box.Outlined = true
                        Box.OutlineOpacity = Opacity - 0.1
                        -- OutlineBox.Position = Box.Position
                        -- OutlineBox.Size = Box.Size
                        -- OutlineBox.Opacity = Box.Opacity - 0.25

                        -- local Rounding = math.abs(math.sin(elapsedTime() * 3) * 64)

                        -- Box.Rounding = Rounding
                        -- OutlineBox.Rounding = Rounding

                        Name.Text = string.format('%s', self.Name) --:upper())
                        Name.Position.Point = fromOffset(ScreenPosition.X, ScreenPosition.Y - Size.Y / 2 - 1)
                        Name.Size = TextSize
                        Name.Opacity = Opacity
                        Name.OutlineOpacity = OutlineOpacity

                        Distance.Text = string.format('%d', self.Distance)
                        Distance.Position.Point = fromOffset(ScreenPosition.X, ScreenPosition.Y + Size.Y / 2)
                        Distance.Size = TextSize --* 0.95
                        Distance.Opacity = Opacity
                        Distance.OutlineOpacity = OutlineOpacity

                        Tags.Text = string.format('%s', table.concat(self.Tags, '\n'))
                        Tags.Position.Point = fromOffset(ScreenPosition.X + Size.X / 2 + 4, ScreenPosition.Y - Size.Y / 2)
                        Tags.Size = TextSize --* 0.95
                        Tags.Opacity = Opacity
                        Tags.OutlineOpacity = OutlineOpacity

                        if self.Humanoid then
                            self:ShowDrawings'HealthBar, HealthBarOutline, HealthText'

                            local MaxHealth = 100 if MHealth < MaxHealth then MaxHealth = MHealth end if Health > MHealth then Health = MHealth end
                            local HP = math.clamp((Health / MaxHealth), 0, MaxHealth) -- Scales up to 10000%
                            local CHP = math.clamp((Health / MHealth), 0, 1)
                            local YSize = Floor(Size.Y * CHP)
                            local HBSize = V2New(2, YSize)
                            local Position = V2New(Floor(ScreenPosition.X - Size.X / 2 - 6), Floor(ScreenPosition.Y - Size.Y / 2 + ((Humanoid.MaxHealth - Health) / Humanoid.MaxHealth) * Size.Y))

                            HealthBar.Position.Point = fromOffset(Position.X, Position.Y)
                            HealthBar.Size = HBSize
                            HealthBar.Opacity = Opacity
                            HealthBar.Color = Green:Lerp(Red, math.clamp(1 - CHP, 0, 1))

                            HealthBarOutline.Size = HealthBar.Size + Vector2.new(2, 2)
                            HealthBarOutline.Opacity = HealthBar.Opacity - 0.25

                            HealthText.Text = string.format('%d', HP * 100)
                            HealthText.Position.Point = fromOffset(Position.X - HealthText.TextBounds.X / 2 + 2, Position.Y)
                            HealthText.Size = TextSize -- / 1.6
                            HealthText.Opacity = Opacity
                            HealthText.OutlineOpacity = OutlineOpacity
                        else
                            self:HideDrawings'HealthBar, HealthBarOutline, HealthText'
                        end
                    end
                -- else
                --     self:HideDrawings()
                -- end
            else
                self:HideDrawings()
            end
        else
            self:HideDrawings()
        end
    end

    function cPlayer:AddTag(Tag, Index)
        if table.find(self.Tags, Tag) then return false end

        if Index then return table.insert(self.Tags, Index, Tag) end

        table.insert(self.Tags, Tag)
    end

    function cPlayer:RemoveTag(Tag)
        local Index = table.find(self.Tags, Tag)

        if Index then table.remove(self.Tags, Index) end
    end

    function cPlayer:ToggleTag(Tag, Bool, InsertIndex)
        local Index = table.find(self.Tags, Tag)

        if not Bool and Index then
            table.remove(self.Tags, Index)
        elseif Bool and not Index then
            if InsertIndex then return table.insert(self.Tags, InsertIndex, Tag) end

            table.insert(self.Tags, Tag)
        end
    end

    function cPlayer:SetColor(Color, Outline)
        self.Color = Color
        self.OutlineColor = Outline or self.OutlineColor

        self.Drawings.Name.Color = Color
        self.Drawings.Name.OutlineColor = Outline
        self.Drawings.HealthText.Color = Color
        self.Drawings.HealthText.OutlineColor = Outline
        self.Drawings.Distance.Color = Color
        self.Drawings.Distance.OutlineColor = Outline
        self.Drawings.Box.Color = Color
        -- self.Drawings.OutlineBox.Color = Outline
    end

    function cPlayer:IncreaseZIndex(Amount)
        local Amount = Amount or 1
        
        for Index, Drawing in pairs(self.Drawings) do
            Drawing.ZIndex += Amount
        end
    end

    function cPlayer:DecreaseZIndex(Amount)
        local Amount = Amount or 1
        
        for Index, Drawing in pairs(self.Drawings) do
            Drawing.ZIndex -= Amount
        end
    end

    function cPlayer:ShowDrawings(String)
        if String and not self.vdt[String] then
            self.vdt[String] = true
            self.DrawingsShown = true
            
            for Match in String:gmatch'[^, ]+' do
                if self.Drawings[Match] then
                    self.Drawings[Match].Visible = true
                end
            end
            
            return
        end
    end

    function cPlayer:HideDrawings(String)
        if String and self.vdt[String] then
            self.vdt[String] = false

            for Match in String:gmatch'[^, ]+' do
                if self.Drawings[Match] then
                    self.Drawings[Match].Visible = false
                end
            end

            return
        end

        if self.DrawingsShown then
            self.DrawingsShown = false

            for i, v in pairs(self.vdt) do
                self.vdt[i] = false
            end

            for i, v in pairs(self.Drawings) do
                v.Visible = false
            end
        end
    end

    function cPlayer:GetAngle()
        if not self.Character or not self.Character:FindFirstChild'Head' then return 360 end

        local BasePosition = Camera.CFrame.Position
        local Relative = (self.Character.Head.Position - BasePosition)
        local Direction = PlayerMouse.UnitRay.Direction
        local Normal = Relative.Unit
        local Angle = math.atan2(Normal:Cross(Direction).Magnitude, Normal:Dot(Direction)) * (180 / math.pi) * 6

        return Angle
    end

    function cPlayer:Dispose()
        self.C_CharacterAdded:Disconnect()
        self.C_CharacterRemoved:Disconnect()

        for Index, Element in pairs(self.Drawings) do
            Element.Visible = false
        end
    end
end

local Connections = {}
local PlayerList = {}
local MSDelay = 3
local CameraUpdate = 0

function UpdateESP(dt)
    if not PlayerList then return end

    MousePosition = UserInput:GetMouseLocation()
    CameraUpdate -= dt
    
    if CameraUpdate < 0 then
        CameraUpdate = 1

        Camera = workspace.CurrentCamera
    end

    if Enabled then
        for Name, Player in pairs(PlayerList) do
            Player:Update()
        end
    else
        for Name, Player in pairs(PlayerList) do
            Player:HideDrawings()
        end
    end
    -- end
end

-- PlayerList[LocalPlayer.Name] = cPlayer.new(LocalPlayer)

function shared.ClearESP()
    if not PlayerList then return end

    for i, v in pairs(PlayerList) do
        v:Dispose()
    end

    for i, v in pairs(Connections) do
        v:Disconnect()
    end

    PlayerList = nil

    shared.ClearESP = nil

    RunService:UnbindFromRenderStep'i-1'
end

-- print(tableToString(PlayerList))

for Index, Player in pairs(Players:GetPlayers()) do
    PlayerList[Player.Name] = cPlayer.new(Player)
end

local function GetTarget(FOV)
    local BestAngle, CPlayer, PlayerInstance, Character = FOV or 50

    for Index, Player in pairs(PlayerList) do
        local Angle = Player:GetAngle()

        if Angle < BestAngle then
            BestAngle = Angle
            CPlayer = Player
            PlayerInstance = Player.Player
            Character = Player.Character
        end
    end

    return CPlayer, PlayerInstance, Character, BestAngle
end

table.insert(Connections, UserInput.InputEnded:Connect(function(Input)
    if Input.UserInputType.Name == 'Keyboard' then
        if Input.KeyCode.Name == 'F3' then
            Enabled = not Enabled
            return
        elseif Input.KeyCode.Name == 'T' and UserInput:IsKeyDown'LeftControl' then
            UseTeamColors = not UseTeamColors
            
            for Index, Player in pairs(PlayerList) do
                -- cprint(Player.Player.TeamColor.Color)
                Player:SetColor(Color3.new(1, 1, 1), UseTeamColors and Player.Player.TeamColor.Color or Color3.new(0.15, 0.15, 0.15))
                -- Player:SetColor(UseTeamColors and Player.Player.TeamColor.Color or Color3.new(1, 1, 1), UseTeamColors and Color3.new(1, 1, 1) or Color3.new(0.15, 0.15, 0.15))
            end

            return
        elseif Input.KeyCode.Name == 'N' and UserInput:IsKeyDown'LeftControl' then
            for Index, Player in pairs(PlayerList) do
                if Player.Name == Player.Player.Name then
                    Player.Name = Scramble(Player.Player.Name)
                else
                    Player.Name = Player.Player.Name
                end
            end
        end

        if UserInput:IsMouseButtonPressed(1) then
            if Input.KeyCode.Name == 'F1' then
                local C, Player = GetTarget()

                if Player and Player ~= LocalPlayer and Player ~= Spectating and Player.Character then
                    Camera.CameraSubject = Player.Character.Head
                    Spectating = Player
                else
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass'Humanoid' then
                        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass'Humanoid'
                        Spectating = nil
                    end
                end
            elseif Input.KeyCode.Name == 'K' then
                local Player = GetTarget()

                if Player then
                    if Marked[Player.Name] == nil then Marked[Player.Name] = false end

                    local IsMarked = not Marked[Player.Name]
                    Marked[Player.Name] = IsMarked

                    Player:SetColor(IsMarked and Color3.new(0.8, 0.2, 0.2) or Color3.new(1, 1, 1), IsMarked and Color3.new(1, 1, 1) or Color3.new(0.15, 0.15, 0.15))
                    Player[IsMarked and 'IncreaseZIndex' or 'DecreaseZIndex'](Player)
                end
            end
        end
    end
end))

if game.PlaceId == 5208655184 then
    PlayerGlobalUpdate = function(Player)
        if Player.Character then
            Player:ToggleTag('InDanger', Player.Character:FindFirstChild'Danger')
            Player:ToggleTag('Immortal', Player.Character:FindFirstChild'Immortal')
        end
    end
end

table.insert(Connections, Players.PlayerAdded:Connect(function(Player) PlayerList[Player.Name] = cPlayer.new(Player) end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(Player)
    PlayerList[Player.Name]:Dispose()
    PlayerList[Player.Name] = nil
end))

RunService:UnbindFromRenderStep'i-1'

RunService:BindToRenderStep('i-1', Enum.RenderPriority.Camera.Value, UpdateESP)
