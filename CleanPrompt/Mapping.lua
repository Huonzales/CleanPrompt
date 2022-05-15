
local rbxdefault = "rbxasset://textures/ui/Controls/"
local keyCode = Enum.KeyCode
----------------- ----------------- Locals

-- Contains all data for buttons
return {
	
	
	-- special Image for specific keys
	gamepadImage = {
		[keyCode.ButtonX] = rbxdefault.."xboxX.png";
		[keyCode.ButtonY] = rbxdefault.."xboxY.png";
		[keyCode.ButtonA] = rbxdefault.."xboxA.png";
		[keyCode.ButtonB] = rbxdefault.."xboxB.png";
		-- Buttons
		
		[keyCode.DPadLeft] = rbxdefault.."dpadLeft.png";
		[keyCode.DPadRight] = rbxdefault.."dpadRight.png";
		[keyCode.DPadUp] = rbxdefault.."dpadUp.png";
		[keyCode.DPadDown] = rbxdefault.."dpadDown.png";
		-- Dpads
		
		[keyCode.ButtonSelect] = rbxdefault.."xboxmenu.png";
		[keyCode.ButtonL1] = rbxdefault.."xboxLS.png";
		[keyCode.ButtonR1] = rbxdefault.."xboxRS.png";
		-- Others
	};
	
	
	-- special Image for specific keys
	keyboardImage = {
		[keyCode.Backspace] = rbxdefault.."backspace.png";
		[keyCode.Return] = rbxdefault.."return.png";
		[keyCode.LeftShift] = rbxdefault.."shift.png";
		[keyCode.RightShift] = rbxdefault.."shift.png";
		[keyCode.Tab] = rbxdefault.."tab.png";
	};
	
	
	-- special Image for specific keys
	keyboardMapping = {
		["'"] = rbxdefault.."apostrophe.png";
		[","] = rbxdefault.."comma.png";
		["`"] = rbxdefault.."graveaccent.png";
		["."] = rbxdefault.."period.png";
		[" "] = rbxdefault.."spacebar.png";
	};
	
	
	-- format special keycode to text ;for better understanding
	keycodeText = {
		[keyCode.LeftControl] = "Ctrl";
		[keyCode.RightControl] = "Ctrl";
		[keyCode.LeftAlt] = "Alt";
		[keyCode.RightAlt] = "Alt";
		[keyCode.F1] = "F1";
		[keyCode.F2] = "F2";
		[keyCode.F3] = "F3";
		[keyCode.F4] = "F4";
		[keyCode.F5] = "F5";
		[keyCode.F6] = "F6";
		[keyCode.F7] = "F7";
		[keyCode.F8] = "F8";
		[keyCode.F9] = "F9";
		[keyCode.F10] = "F10";
		[keyCode.F11] = "F11";
		[keyCode.F12] = "F12";
	};
}
