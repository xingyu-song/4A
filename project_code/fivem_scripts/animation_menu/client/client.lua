-- ############################################
-- --------------------------------------------
-- Animenu : a "menu" to play any animation
-- Author : Elio
-- --------------------------------------------
-- ############################################

local find = string.find

local numberNow = 17290
-- --------------------------------------------
-- Variables
-- --------------------------------------------

local index = 1
local draw = false
local searching = false
local searchingString = ""

-- --------------------------------------------
-- Display functions
-- --------------------------------------------

-- OBJ : display text on screen
-- PARAMETERS :
-- 		- x : x coordinate of the text
--		- y : y coordinate of the text
-- 		- text : text to display
local function DrawTextAdvanced(x, y, text)
    SetTextFont(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(230, 230, 230, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(x,y)
end

-- OBJ : display instructionnal buttons
-- PARAMETERS :
-- 		- buttons : array of the buttons and their names
local function InstructionnalButtons(buttons)
    local instructionScaleform = RequestScaleformMovie("instructional_buttons")

    while not HasScaleformMovieLoaded(instructionScaleform) do
        Wait(0)
    end

    PushScaleformMovieFunction(instructionScaleform, "CLEAR_ALL")
    PushScaleformMovieFunction(instructionScaleform, "TOGGLE_MOUSE_BUTTONS")
    PushScaleformMovieFunctionParameterBool(0)
    PopScaleformMovieFunctionVoid()

    for buttonIndex, buttonValues in ipairs(buttons) do
        PushScaleformMovieFunction(instructionScaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(buttonIndex - 1)

        PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, buttonValues.button, 0))
        PushScaleformMovieFunctionParameterString(buttonValues.name)
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(instructionScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PushScaleformMovieFunctionParameterInt(-1)
    PopScaleformMovieFunctionVoid()
    DrawScaleformMovieFullscreen(instructionScaleform, 255, 255, 255, 255)
end

-- OBJ : get the input of a user
-- PARAMETERS :
-- 		- windowTitle : the title of the windowTitle
--		- defaultText : the text to display by default
--		- maxInputLength : the maximum length of the input
local function GetUserInput(windowTitle, defaultText, maxInputLength)

	windowTitle = windowTitle or ""
	defaultText = defaultText or ""
	maxInputLength = maxInputLength or 128

	AddTextEntry("ANIM_WINDOW_TITLE", windowTitle .. " (MAX. LENGTH : " .. maxInputLength .. ") :")
	DisplayOnscreenKeyboard(1, "ANIM_WINDOW_TITLE", "", defaultText, "", "", "", maxInputLength)

	while UpdateOnscreenKeyboard() == 0 do
		Wait(100)
	end

	local result = GetOnscreenKeyboardResult()

	return result

end

-- OBJ : send a native notification
-- PARAMETERS :
-- 		- text : the text to display
function SendNotification(text)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentString(text)
    EndTextCommandThefeedPostTicker(true, true)
end

-- --------------------------------------------
-- Fundamental functions
-- DO NOT TOUCH
-- --------------------------------------------

local function GoUpInAnimations(deepness)
	deepness = deepness or 1

	if index == 1 then
		index = #Animations
	else
		index = index - 1
	end

	if deepness <= #Animations then
		if searching then
			if not find(Animations[index][1]..Animations[index][2], searchingString) then
				GoUpInAnimations(deepness + 1)
			end
		end
	else
		SendNotification("~r~~h~ERROR ~h~~w~: No results found. Your research parameter got deleted.")
		searching = false
		searchingString = ""
	end
end

local function GoDownInAnimations(deepness)
	deepness = deepness or 1

	if index == #Animations then
		index = 1
	else
		index = index + 1
	end

	if deepness <= #Animations then
		if searching then
			if not find(Animations[index][1]..Animations[index][2], searchingString) then
				GoDownInAnimations(deepness + 1)
			end
		end
	else
		SendNotification("~r~~h~ERROR ~h~~w~: No results found. Your research parameters got deleted.")
		searching = false
		searchingString = ""
	end
end

local function gotoAnimation()
	index = numberNow
end



local function PlayAnimation()
	local playerPed = PlayerPedId()
	RequestAnimDict(Animations[index][1])
	local j = 0
	while not HasAnimDictLoaded(Animations[index][1]) and j <= 10 do 
		Citizen.Wait(100)
		j = j + 1
	end

	if j >= 10 then
		SendNotification("~r~~h~ERROR ~h~~w~: The animation dictionnary took too long to load.")
		GoDownInAnimations()
	else
		local playerCoords_old = GetEntityCoords(playerPed)
		TaskPlayAnim(playerPed, Animations[index][1], Animations[index][2], 8.0, 1.0, -1, 0)
		duration = GetAnimDuration(Animations[index][1], Animations[index][2])
		TriggerServerEvent('animation:write_duration', Animations[index][1], Animations[index][2], duration)
		Citizen.CreateThread(function()
			while IsEntityPlayingAnim(playerPed, Animations[index][1], Animations[index][2], 3) do
			  Citizen.Wait(0)
			end
			
			local playerCoords_new = GetEntityCoords(playerPed)
			if playerCoords_new ~= playerCoords_old then
				-- Move the player to the desired coordinates
				SetEntityCoords(playerPed, playerCoords_old)
			end
		end)


		RemoveAnimDict(Animations[index][1])
	end
end

local function SearchAnimation()
	searchingString = GetUserInput("Animation name", "", 32):lower()
	searching = searchingString ~= "" and searchingString ~= nil
end

local function CancelAnimation()
	ClearPedTasksImmediately(PlayerPedId())
end

local function PrintAnimation()
	print("-----------------------------------------")
	print("Animation :")
	print("		- Dict : " .. Animations[index][1])
	print("		- Clip : " .. Animations[index][2])
	print("-----------------------------------------")
end

local function FocusCamToPlayer()
	local playerPed = GetPlayerPed(-1)
	local x, y, z = table.unpack(GetEntityCoords(playerPed, false))
    SetCamCoord(CreateCam("DEFAULT_SCRIPTED_CAMERA", x, y, z + 100.0), x, y, z + 100.0)
    PointCamAtEntity(CreateCam("DEFAULT_SCRIPTED_CAMERA", x, y, z + 100.0), playerPed, 0.0, 0.0, 0.0, true)
    RenderScriptCams(true, false, 0, true, true)
end

-- --------------------------------------------
-- Parameters
-- --------------------------------------------

local options = {
	-- { button = 17, name = "Go up in animations", func = GoUpInAnimations },
	-- { button = 16, name = "Go down in animations", func = GoDownInAnimations },
	{ button = 172, name = "Go up in animations", func = GoUpInAnimations },
	{ button = 173, name = "Go down in animations", func = GoDownInAnimations },
	{ button = 323, name = "Play animation", func = PlayAnimation },
	{ button = 74, name = "Search for an animation", func = SearchAnimation },
	{ button = 19, name = "Cancel animation", func = CancelAnimation },
	{ button = 51, name = "Print animation informations", func = PrintAnimation },
	{ button = 21, name = "Go to a animation with number", func = gotoAnimation },
	--{ button = 212, name = "Focus camera to the player", func = FocusCamToPlayer},
}

-- --------------------------------------------
-- Command
-- --------------------------------------------

RegisterCommand('ani', function()
	draw = not draw
	-- local playerPed = PlayerPedId()
	-- index = 6227
	-- while true do
	-- 	if index == 6228 then
	-- 		return
	-- 	else 
	-- 		PlayAnimation()
	-- 		duration = GetAnimDuration(Animations[index][1], Animations[index][2])
	-- 		TriggerServerEvent('teleporter:goto', Animations[index][1], Animations[index][2], duration)

	-- 		TriggerEvent('chat:addMessage',{
	-- 			args = {'Number ' ..index.. ' duration ' ..duration}
	-- 		})
	-- 		GoDownInAnimations()
	-- 		--LeaderboardsClearCacheData()
	-- 		Wait(0)
	-- 	end
	-- end

end)

-- --------------------------------------------
-- Main thread
-- --------------------------------------------

Citizen.CreateThread(function()
	local duration
	-- local animFinished
	local playerPed = PlayerPedId()

	while true do
		if draw then

			duration = GetAnimDuration(Animations[index][1], Animations[index][2])
			
			DrawTextAdvanced(0.5, 0, "Animation " .. index .. ": Dict: " .. Animations[index][1])
			DrawTextAdvanced(0.5, 0.02, 'Clip: ' .. Animations[index][2].. ' Duration: ' .. duration)
			-- DrawTextAdvanced(0.91, 0.07, 'Clip: ' .. Animations[index][2])
			-- DrawTextAdvanced(0.91, 0.09, 'Duration: ' .. duration)

			
			-- InstructionnalButtons(options)


			for i = 1, #options do
				DisableControlAction(0, options[i].button, true)
	
				if IsDisabledControlJustPressed(1, options[i].button) then
					options[i].func()
				end
	
			end

			-- TriggerServerEvent('teleporter:goto', Animations[index][1], Animations[index][2], duration)

			-- TriggerEvent('chat:addMessage',{
			-- 	args = {'Number ' ..index.. ' duration ' ..duration}
			-- })

		end

		Wait(0)

	end
end)




