if not game:IsLoaded() then
	game.Loaded:Wait()
end
TextFont = Font.Register(game:HttpGet'https://github.com/bluescan/proggyfonts/raw/master/ProggyOriginal/ProggyClean.ttf', { Scale = false, Bold = false, UseStb = true, PixelSize = G_TextSize })
local TextFont = Font.RegisterDefault('ProggyClean', { PixelSize = G_TextSize, UseStb = true, Scale = false, Bold = false })
--Set FPS Element
local FPSText = TextDynamic.new()
FPSText.Font = TextFont
FPSText.Size = 13
FPSText.XAlignment = XAlignment.Right
FPSText.YAlignment = YAlignment.Bottom
FPSText.Outlined = true
FPSText.OutlineOpacity = .5
FPSText.OutlineThickness = 10
FPSText.OutlineColor = Color3.fromRGB(0, 0, 0)
--Set Ping element
local PingText = TextDynamic.new()
PingText.Font = TextFont
PingText.Size = 13
PingText.XAlignment = XAlignment.Right
PingText.YAlignment = YAlignment.Bottom
PingText.Outlined = true
PingText.OutlineOpacity = .5
PingText.OutlineThickness = 10
PingText.OutlineColor = Color3.fromRGB(0, 0, 0)
--set locals
-- local GameName = (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)).Name
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TimeFunction = RunService:IsRunning() and time or os.clock
local LastIteration, Start
local FrameUpdateTable = {}
local G_TextSize = 13
--fps function
local function FramerateUpd()
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end
	FrameUpdateTable[1] = LastIteration
	local fps = math.floor(
		TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)
	)
	FPSText.Position = Point2D.new(camera.ViewportSize.X - FPSText.TextBounds.X - 2, 2)
	-- if fps is under *x* then set text color to *y*
	if fps <= 30 then
		FPSText.Color = Color3.fromRGB(255, 0, 0)
	elseif fps <= 60 then
		FPSText.Color = Color3.fromRGB(255, 217, 0)
	elseif fps <= 144 then
		FPSText.Color = Color3.fromRGB(0, 255, 0)
	else
		FPSText.Color = Color3.fromRGB(255, 255, 255)
	end
	FPSText.Text = fps .. " fps" --.. GameName
end
local function PingUpd()
	PingText.Position = Point2D.new(camera.ViewportSize.X - FPSText.TextBounds.X - 2, 15)
	local ping = tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("[^.]+"))
	if ping <= 60 then
		PingText.Color = Color3.fromRGB(255, 255, 255)
	elseif ping <= 100 then
		PingText.Color = Color3.fromRGB(0, 255, 0)
	elseif ping <= 300 then
		PingText.Color = Color3.fromRGB(255, 217, 0)
	else
		PingText.Color = Color3.fromRGB(255, 0, 0)
	end
	PingText.Text = ping .. "ms"
end
Start = TimeFunction()
RunService.Heartbeat:Connect(FramerateUpd)
RunService.Heartbeat:Connect(PingUpd)
