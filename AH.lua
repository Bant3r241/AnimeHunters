if game.PlaceId == 118554563202898 then
    local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    local Window = OrionLib:MakeWindow({Name="ABI │ AnimeHunters", HidePremium=false, IntroEnabled=false, IntroText="ABI", SaveConfig=true, ConfigFolder="XlurConfig"})

local Tab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})



    OrionLib:MakeNotification({
	Name = "ABI",
	Content = "Loading Script!",
	Image = "rbxassetid://4483345998",
	Time = 5
})

Tab:AddBind({
	Name = "Bind",
	Default = Enum.KeyCode.f,
	Hold = false,
	Callback = function()
		print("press")
	end    
})

OrionLib:Init()
