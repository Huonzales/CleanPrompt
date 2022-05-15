--!nocheck

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



promptService.PromptShown:Connect(function(prompt ,inputType)
	if not (prompt.Style == promptStyle.Custom) then
		return nil -- not custom ,ignoring it
		
	else -- using our custom prompt
		local _cleanup = _getprompt(prompt ,inputType)
		prompt.PromptHidden:Wait()
		_cleanup() -- from _closePrompt()
	end
end)
-- this should fires when a prompt is shown 



function _createPromptUI(currentDevice ,prompt ,ui)
	
end
-- create a new prompt



function _onHoldBegan(deviceName ,prompt ,ui)

end
-- on hold prompt holding down



function _onHoldEnded(deviceName ,prompt ,ui)

end
-- on stopped holding a prompt



function _onTapped(currentDevice ,prompt ,ui)
	
end
-- on tapped



function _closePrompt(deviceName ,prompt ,ui)	
	debris:AddItem(ui ,2)
end
-- use to cleanup a prompt



function _getprompt(prompt ,inputType)
	
	local currentDevice = _getDeviceName(inputType)
	local ui : Instance
	
	if not currentDevice then
		return nil -- this is impossible right?
		
	else -- found valid device ,creating a prompt
		ui = _createPromptUI(currentDevice ,prompt ,ui)
		_setupPromptEvent(currentDevice ,prompt ,ui)
		playingTween[ui] = {}
		
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
	table.insert(playingTween[ui][tag] ,tween)
end
-- put tween in a tag ,for later cancellation