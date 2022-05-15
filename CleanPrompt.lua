--!nocheck

local overrideDefaultPrompt = true
-- if this is false ,you need to set ProximityPrompt.Style to Custom
-- or use your own method

--[[
--------------- ------------------------------ ---------------

	This is a template ,so you can make yours
	prompt easier hopefully.
	
	most of the variables ,function name
	are pretty strightforward.
	
	function you mostly want to work on
	are all above and arrange down from
	their priority.
	
--------------- ------------------------------ --------------- 
]]--

local promptService = game:GetService("ProximityPromptService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local textService = game:GetService("TextService")
local debris = game:GetService("Debris")
local players = game:GetService("Players")
-- Services

local user = players.LocalPlayer
local playerGui = user.PlayerGui
local playingTween = {}
-- Locals

local deviceTypes = {"Keyboard" ,"Touch" ,"Gamepad"}
local promptStyle = Enum.ProximityPromptStyle
local promptInput = Enum.ProximityPromptInputType
-- Enums ,others


local mapping = require(script.Mapping)
local asset = script.Template
local buttonlike = TweenInfo.new(0.15 ,Enum.EasingStyle.Quad)
local slow = TweenInfo.new(0.85 ,Enum.EasingStyle.Quad)
local medium = TweenInfo.new(0.65 ,Enum.EasingStyle.Quad)
local fast = TweenInfo.new(0.35 ,Enum.EasingStyle.Quad)
------------- ------------- Locals 2



promptService.PromptShown:Connect(function(prompt ,inputType)
	if not (prompt.Style == promptStyle.Custom)
		and not overrideDefaultPrompt
	then
		return nil -- not custom ,ignoring it
		
	else -- using our custom prompt
		prompt.Style = promptStyle.Custom
		
		local _cleanup = _getprompt(prompt ,inputType)
		prompt.PromptHidden:Wait()
		_cleanup() -- from _closePrompt()
	end
end)
-- this should fires when a prompt is shown 



function _createPromptUI(currentDevice ,prompt ,ui)
	if (currentDevice == "Keyboard") then
		local prompt : ProximityPrompt = prompt

		local keycode = prompt.KeyboardKeyCode
		local holdDuration = prompt.HoldDuration
		local objectText = prompt.ObjectText
		local actionText = prompt.ActionText
		-- required Property ,will be use to create prompt

		actionText = if hasText(actionText) 
			then actionText 
			else "Intereact"
		-- actionText's Default

		local promptUI = if hasText(objectText)
			then asset.Complex:Clone()
			else asset.Simple:Clone()
		-- choosing between 2 ui models ,only complex supports ObjectText


		promptUI.Frame.Info.Action.Text = actionText
		if (promptUI.Name == "Complex") then
			promptUI.Frame.Info.Object.Text = objectText
		end
		-- writing down the text

		local keycodeText = userInputService:GetStringForKeyCode(keycode)
		local imageIcon : string -- will be defined later if exists in mapping	

		local keycodeForm = getFormat("keycodeText" ,keycode)
		local imageIcon = getFormat("keyboardImage" ,keycode)
		-- finding predefined format


		promptUI.Frame.Key.ButtonText.Text = keycodeForm or keycodeText	
		if imageIcon then
			promptUI.Frame.Key.IconImage.Image = imageIcon
			promptUI.Frame.Key.IconImage.Visible = true
		end
		-- showing Icon ,keycode text


		local border = calculateBorder(promptUI.Frame.Info.Action)
		if (#objectText > #actionText) then
			border = calculateBorder(promptUI.Frame.Info.Object)
		end
		border = math.clamp(border + 55 ,125 ,500)
		-- get extended border for TextLabel


		promptUI.Size = UDim2.fromOffset(border ,45)
		promptUI.Adornee = prompt.Parent	

		return promptUI
		
	elseif (currentDevice == "Touch") then
		
		local prompt : ProximityPrompt = prompt

		local holdDuration = prompt.HoldDuration
		local objectText = prompt.ObjectText
		local actionText = prompt.ActionText
		-- required Property ,will be use to create prompt

		actionText = if hasText(actionText) 
			then actionText 
			else "Intereact"
		-- actionText's Default

		local promptUI = if hasText(objectText)
			then asset.Complex:Clone()
			else asset.Simple:Clone()
		-- choosing between 2 ui models ,only complex supports ObjectText


		promptUI.Frame.Info.Action.Text = actionText
		if (promptUI.Name == "Complex") then
			promptUI.Frame.Info.Object.Text = objectText
		end
		-- writing down the text

		local imageIcon = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		promptUI.Frame.Key.ButtonText.Text = ""	
		promptUI.Frame.Key.ButtonImage.Image = imageIcon
		-- showing Icon ,keycode text


		local border = calculateBorder(promptUI.Frame.Info.Action)
		if (#objectText > #actionText) then
			border = calculateBorder(promptUI.Frame.Info.Object)
		end
		border = math.clamp(border + 55 ,125 ,500)
		-- get extended border for TextLabel


		promptUI.Size = UDim2.fromOffset(border ,45)
		promptUI.Adornee = prompt.Parent	

		return promptUI
		
	elseif (currentDevice == "Gamepad") then
		local prompt : ProximityPrompt = prompt

		local padkeycode = prompt.GamepadKeyCode
		local holdDuration = prompt.HoldDuration
		local objectText = prompt.ObjectText
		local actionText = prompt.ActionText
		-- required Property ,will be use to create prompt

		actionText = if hasText(actionText) 
			then actionText 
			else "Intereact"
		-- actionText's Default

		local promptUI = if hasText(objectText)
			then asset.Complex:Clone()
			else asset.Simple:Clone()
		-- choosing between 2 ui models ,only complex supports ObjectText


		promptUI.Frame.Info.Action.Text = actionText
		if (promptUI.Name == "Complex") then
			promptUI.Frame.Info.Object.Text = objectText
		end
		-- writing down the text

		local imageIcon = getFormat("gamepadImage" ,padkeycode)
		promptUI.Frame.Key.ButtonText.Text = ""	
		promptUI.Frame.Key.ButtonImage.Image = imageIcon
		-- showing Icon ,keycode text


		local border = calculateBorder(promptUI.Frame.Info.Action)
		if (#objectText > #actionText) then
			border = calculateBorder(promptUI.Frame.Info.Object)
		end
		border = math.clamp(border + 55 ,125 ,500)
		-- get extended border for TextLabel


		promptUI.Size = UDim2.fromOffset(border ,45)
		promptUI.Adornee = prompt.Parent	

		return promptUI
	end
end
-- create a new prompt



function _onHoldBegan(currentDevice ,prompt ,ui)
	_clearTweens(ui ,"onRelease")
	
	local fullduration = TweenInfo.new(prompt.HoldDuration ,Enum.EasingStyle.Linear)
	
	-- moving Key to center
	local keymoveT = tweenService:Create(ui.Frame.Key ,fast ,{
		Position = UDim2.fromScale(0.5 ,0);
		AnchorPoint = Vector2.new(0.5 ,0);
	}) 


	-- scale the size of frame
	ui.Frame.Sized.MaxSize = Vector2.new(ui.Frame.AbsoluteSize.X ,45)
	local keyscaleT = tweenService:Create(ui.Frame.Sized ,fast ,{
		MaxSize = Vector2.new(45 ,45);
	}) 


	-- tween text's visibility
	for _,label in next ,ui.Frame.Info:GetChildren() do
		local labelscaleT = tweenService:Create(label ,fast ,{
			TextTransparency = 1;
		}) labelscaleT:Play()
		_addTween(ui ,"onHold" ,labelscaleT)
	end


	-- progress bar
	ui.Frame.Load.Size = UDim2.fromScale(0,1)
	ui.Frame.Load.Transparency = 0.75
	local progressT = tweenService:Create(ui.Frame.Load ,fullduration ,{
		Size = UDim2.fromScale(1,1)
	})
	
	_addTween(ui ,"onHold" ,progressT)
	_addTween(ui ,"onHold" ,keymoveT)
	_addTween(ui ,"onHold" ,keyscaleT)
end
-- on hold prompt holding down



function _onHoldEnded(currentDevice ,prompt ,ui)
	_clearTweens(ui ,"onHold")
	
	-- moving Key back
	local keymoveT = tweenService:Create(ui.Frame.Key ,fast ,{
		Position = UDim2.fromScale(0 ,0);
		AnchorPoint = Vector2.new(0 ,0);
	}) 


	-- scale the size of frame
	ui.Frame.Sized.MaxSize = Vector2.new(ui.Frame.AbsoluteSize.X ,45)
	local keyscaleT = tweenService:Create(ui.Frame.Sized ,slow ,{
		MaxSize = Vector2.new(500 ,45);
	})


	-- tween text's visibility
	for _,label in next ,ui.Frame.Info:GetChildren() do
		local labelscaleT = tweenService:Create(label ,fast ,{
			TextTransparency = 0;
		}) labelscaleT:Play()
		_addTween(ui ,"onRelease" ,labelscaleT)
	end


	-- progress bar
	local progressT = tweenService:Create(ui.Frame.Load ,fast ,{
		Transparency = 1
	})
	
	_addTween(ui ,"onRelease" ,keyscaleT)
	_addTween(ui ,"onRelease" ,progressT)
	_addTween(ui ,"onRelease" ,keymoveT)
end
-- on stopped holding a prompt



function _onTapped(currentDevice ,prompt ,ui)
	tweenService:Create(ui.Frame.Key.ButtonImage ,buttonlike ,{
		Size = UDim2.fromOffset(25 ,25)
	}):Play()
	task.wait(0.15)
	tweenService:Create(ui.Frame.Key.ButtonImage ,buttonlike ,{
		Size = UDim2.fromOffset(30 ,30)
	}):Play()
	
	ui.Frame.Load.Size = UDim2.fromScale(1 ,1)
	ui.Frame.Load.Transparency = 0.75
	tweenService:Create(ui.Frame.Load ,medium ,{
		Transparency = 1
	}):Play()
end
-- on triggerred



function _showPrompt(currentDevice ,prompt ,ui)
	for _,object in next ,ui:GetDescendants() do
		if object:IsA("Frame") then
			local lastTransparency = script:FindFirstChild(object.Name ,true).BackgroundTransparency
			object.BackgroundTransparency = 1
			local temp = tweenService:Create(object ,fast ,{
				BackgroundTransparency = lastTransparency;
			})
			
			_addTween(ui ,"show" ,temp)

		elseif object:IsA("TextLabel") then
			local lastTransparency = script:FindFirstChild(object.Name ,true).TextTransparency			
			object.TextTransparency = 1
			local temp = tweenService:Create(object ,fast ,{
				TextTransparency = lastTransparency;
			})
			_addTween(ui ,"show" ,temp)

		elseif object:IsA("ImageLabel") then
			local imageTransparency = script:FindFirstChild(object.Name ,true).ImageTransparency
			object.ImageTransparency = 1
			local temp = tweenService:Create(object ,fast ,{
				ImageTransparency = imageTransparency;
			})
			_addTween(ui ,"show" ,temp)
		end
	end
	
	
	-- moving Key back
	ui.Frame.Key.Position = UDim2.fromScale(0.5 ,0)
	ui.Frame.Key.AnchorPoint = Vector2.new(0.5 ,0)
	local keymoveT = tweenService:Create(ui.Frame.Key ,fast ,{
		Position = UDim2.fromScale(0 ,0);
		AnchorPoint = Vector2.new(0 ,0);
	})
	
	
	-- scale the size of frame
	ui.Frame.Sized.MaxSize = Vector2.new(45 ,45)
	local keyscaleT = tweenService:Create(ui.Frame.Sized ,slow ,{
		MaxSize = Vector2.new(500 ,45);
	})
	
	_addTween(ui ,"show" ,keymoveT)
	_addTween(ui ,"show" ,keyscaleT)
end
-- show a prompt



function _closePrompt(currentDevice ,prompt ,ui)	
	for _,object in next ,ui:GetDescendants() do
		if object:IsA("Frame") then
			local temp = tweenService:Create(object ,fast ,{
				BackgroundTransparency = 1;
			})
			_addTween(ui ,"show" ,temp)

		elseif object:IsA("TextLabel") then
			local temp = tweenService:Create(object ,fast ,{
				TextTransparency = 1;
			})
			_addTween(ui ,"show" ,temp)

		elseif object:IsA("ImageLabel") then
			local temp = tweenService:Create(object ,fast ,{
				ImageTransparency = 1;
			})
			_addTween(ui ,"show" ,temp)
		end
	end
	
	-- moving Key to center
	local keymoveT = tweenService:Create(ui.Frame.Key ,fast ,{
		Position = UDim2.fromScale(0.5 ,0);
		AnchorPoint = Vector2.new(0.5 ,0);
	}) 


	-- scale the size of frame
	ui.Frame.Sized.MaxSize = Vector2.new(ui.Frame.AbsoluteSize.X ,45)
	local keyscaleT = tweenService:Create(ui.Frame.Sized ,fast ,{
		MaxSize = Vector2.new(45 ,45);
	})
	
	_addTween(ui ,"show" ,keymoveT)
	_addTween(ui ,"show" ,keyscaleT)
	
	task.wait(1)
	ui:Destroy()
	
	_clearTweens(ui ,"show")
end
-- use to cleanup a prompt



function _getprompt(prompt ,inputType)
	
	local currentDevice = _getDeviceName(inputType)
	local ui : Instance
	
	if not currentDevice then
		return nil -- this is impossible right?
		
	else -- found valid device ,creating a prompt
		ui = _createPromptUI(currentDevice ,prompt ,ui)
		
		ui.Parent = playerGui.Freecam
		playingTween[ui] = {}
		
		_setupPromptEvent(currentDevice ,prompt ,ui)		
		_showPrompt(currentDevice ,prompt ,ui)
		
		return function()
			_closePrompt(currentDevice ,prompt ,ui)
		end
	end
end
-- get a new prompt



function _setupPromptEvent(currentDevice ,prompt ,ui)
	local binded = {}
	
	local removing = ui.AncestryChanged:Connect(function(this ,parent)
		if not ui:IsDescendantOf(game) then
			for index ,bind in next ,binded do
				bind:Disconnect()
			end
			binded = nil
			playingTween[ui] = nil 
		end
	end)
	-- disconnecting all following events if ui is destroyed
	
	if (prompt.HoldDuration > 0) then
		local hold = prompt.PromptButtonHoldBegan:Connect(function()
			_onHoldBegan(currentDevice ,prompt ,ui)
		end)
		-- on hold prompt holding down


		local release = prompt.PromptButtonHoldEnded:Connect(function()
			_onHoldEnded(currentDevice ,prompt ,ui)
		end)
		-- on stopped holding a prompt
		
		table.insert(binded ,hold)
		table.insert(binded ,release)
		
	else -- tap ,I guess
		local tap = prompt.Triggered:Connect(function()
			_onTapped(currentDevice ,prompt ,ui)
		end)
		-- on tap
		
		table.insert(binded ,tap)
	end
	
	local buttonDown
	local down = ui.Button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and
			input.UserInputState ~= Enum.UserInputState.Change then
			prompt:InputHoldBegin()
			buttonDown = true
		end
	end)
	
	local up = ui.Button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if buttonDown then
				buttonDown = false
				prompt:InputHoldEnd()
			end
		end
	end)
	-- Handling clicking /tapping
	
	table.insert(binded ,down)
	table.insert(binded ,up)
	table.insert(binded ,removing)	
end
-- setting up prompt's event 



------------- -------------------------- -------------
-- helper ,useful functions


function _getDeviceName(inputType)
	local usingDevice : string
	for _ ,device in next ,deviceTypes do
		if (inputType == promptInput[device]) then
			usingDevice = device
			break
		end
	end
	return usingDevice
end
-- get user's device name



function _clearTweens(ui ,tag)
	if not playingTween[ui] then
		playingTween[ui] = {}
	end
	for index ,v in next ,playingTween[ui][tag] or {} do
		v:Cancel()
	end
	playingTween[ui][tag] = nil
end
-- cancel all tween and clear whole tag



function _addTween(ui ,tag ,tween)
	if not playingTween[ui][tag] then
		playingTween[ui][tag] = {}
	end
	tween:Play()
	table.insert(playingTween[ui][tag] ,tween)
end
-- put tween in a tag ,for later cancellation



function getFormat(format ,index)
	return mapping[format][index]
end
-- get format from mapping



function hasText(context)
	return not (context == "")
end
-- get boolean if context contain string or not



function calculateBorder(textLabel)
	local border = textService:GetTextSize(
		textLabel.Text,
		textLabel.TextSize,
		textLabel.Font,
		Vector2.new()
	)
	return border.X
end
-- get estimate border prompt will set to
