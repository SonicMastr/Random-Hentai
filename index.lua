pcall(Network.term)
-- Initialize network
Network.init()

-- Load JSON parser
local json = dofile("app0:/deps/lua/json.lua")
-- Load font and set font size
local fnt0 = Font.load("app0:/deps/font/mvboli.ttf")
Font.setPixelSizes(fnt0, 40)
-- Define colors
local white, translucentBlack = Color.new(255,255,255), Color.new(0,0,0,160)
-- Init values
local currentId = nil		-- ID of the currently loaded image, used when saving images
local autoNext = 0			-- Auto next variable
local seconds = 5			-- Delay in seconds
local response = nil		-- Response of function ID (used in main loop)
local message = nil			-- Callback Message (used in main loop)
local status = nil			-- Callback Status	(used in main loop)
local tmr = Timer.new()		-- Set timer for auto next
Timer.pause(tmr)			-- Pause timer at 0 (would run otherwise)
local tmr2 = Timer.new()	-- Set timer for delays in main loop
Timer.pause(tmr2)			-- Pause timer at 0
local buttonDown = false	-- Ensures no input lag and no unpredicted calls to functions every loop
local menu = false			-- If menu is open
local jsonValid = true		-- Valid JSON Response (Default True)
local size = 0				-- Current image's file size

-- Functions

-- Increases auto next delay
function timerIncrease()
	local id = 1
	if menu then
		if seconds >= 5 and seconds < 60 then
			seconds = seconds + 5
		end
	end
	return id
end
-- Decreases auto next delay
function timerDecrease()
	local id = 2
	if menu then
		if seconds > 5 and seconds <= 60 then
			seconds = seconds - 5
		end
	end
	return id
end
-- Toggles auto next
function toggleAutoNext()
	local id = 3
	if menu then
		if autoNext == 0 then
			if not Timer.isPlaying(tmr) then
				Timer.resume(tmr)
			end
			Timer.setTime(tmr, seconds * 1000)	-- Set time in milliseconds
			autoNext = 1
		else
			if Timer.isPlaying(tmr) then
				Timer.pause(tmr)
			end
			autoNext = 0
		end
	end
	return id
end
-- Saves image with the ID as name
function saveImage()
	local id = 4
	if System.doesFileExist("ux0:/data/randomhentai/saved/" .. currentId .. ".jpg") then
		return id, "Image already saved", 0
	elseif img ~= nil then
		local new = System.openFile("ux0:/data/randomhentai/saved/" .. currentId .. ".jpg", FCREATE)
		System.writeFile(new, image, size)		-- Image data and Size Loaded in getHentai()
		System.closeFile(new)
		return id, "Saved Image as " .. currentId .. ".jpg", 1
	else	
		return id, "Failed to save", 2
	end
end
-- Gets and loads pictures from decoded JSON
function getHentai()
	::gethentai::
	if Network.isWifiEnabled() then
		Network.downloadFile("http://konachan.com/post.json?limit=1&tags=+uncensored+-pool:309+order:random+rating:explict", "ux0:/data/randomhentai/post.json")
		local file1 = System.openFile("ux0:/data/randomhentai/post.json", FREAD)
		local size = System.sizeFile(file1)
		local jsonEncoded = System.readFile(file1, size)					-- Encoded JSON file data
		local pcallStat, jsonDecoded = pcall(json.decode, jsonEncoded)		-- Decoded JSON to table
		System.closeFile(file1)
		System.deleteFile("ux0:/data/randomhentai/post.json")
		if not pcallStat then
			jsonValid = pcallStat
			return
		end
		jsonValid = pcallStat
		if img ~= nil then
			Graphics.freeImage(img)
			img = nil
		end
		rand = math.random(#jsonDecoded)
		url = jsonDecoded[1]["sample_url"]
		fileExt = string.lower(string.sub(url, -4, -1))
		if fileExt ~= "jpeg" and fileExt ~= ".jpg" then
			goto gethentai
		end
		currentId = jsonDecoded[1]["id"]
		Network.downloadFile(url, "ux0:/data/randomhentai/randomhentai.jpg")
		local file2 = System.openFile("ux0:/data/randomhentai/randomhentai.jpg", FREAD)
		size = System.sizeFile(file2)
		if size == 0 then
			System.closeFile(file2)
			goto gethentai
		end
		image = System.readFile(file2, size)
		System.closeFile(file2)
		img = Graphics.loadImage("ux0:/data/randomhentai/randomhentai.jpg")
		System.deleteFile("ux0:/data/randomhentai/randomhentai.jpg")
		width = Graphics.getImageWidth(img)
		height = Graphics.getImageHeight(img)
		drawWidth = 480 - (width * 544 / height / 2)
		drawHeight = 272 - (height * 960 / width / 2)
		if (autoNext == 1) then 
			Timer.setTime(tmr, seconds * 1000) -- Set time in seconds
		end
	else
		img = nil
	end
end

-- Check if ux0:/data/randomhentai exists
if not System.doesDirExist("ux0:/data/randomhentai") then
	System.createDirectory("ux0:/data/randomhentai")
end
-- Check if saved folder exists
if not System.doesDirExist("ux0:/data/randomhentai/saved") then
	System.createDirectory("ux0:/data/randomhentai/saved")
end

getHentai()

-- Main loop
while true do
	-- Local init values
	local time = Timer.getTime(tmr)			            -- Auto next timer value
	local timeSec = math.floor(-time / 1000) + 1		-- Auto next timer value in seconds for user
	local pad = Controls.read()                         -- Reading controls
	local delay = Timer.getTime(tmr2)		            -- Timer used for informational display delays
	local delaySec = 4000					            -- Value used for the delay timer

	-- Controls
	if Controls.check(pad, SCE_CTRL_CROSS) or Controls.check(pad, SCE_CTRL_DOWN) or (autoNext == 1 and time > 0) then
		getHentai()
	elseif Controls.check(pad, SCE_CTRL_CIRCLE) or Controls.check(pad, SCE_CTRL_RIGHT) then
		if not buttonDown then
			response = timerIncrease()
		end
		buttonDown = true
	elseif Controls.check(pad, SCE_CTRL_SQUARE) or Controls.check(pad, SCE_CTRL_LEFT) then
		if not buttonDown then
			response = timerDecrease()
		end
		buttonDown = true
	elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) or Controls.check(pad, SCE_CTRL_UP)) then
		if not buttonDown then
			response = toggleAutoNext()
		end
		buttonDown = true
	elseif (Controls.check(pad, SCE_CTRL_LTRIGGER) or Controls.check(pad, SCE_CTRL_RTRIGGER)) then
		if not buttonDown then
			response, message, status = saveImage()
		end
		buttonDown = true
	else
		buttonDown = false
	end

	-- "Menu" delay
	if buttonDown then		-- Button was pressed, show information
		if Timer.isPlaying(tmr2) then
			Timer.pause(tmr2)
		end
		Timer.resume(tmr2)
		Timer.setTime(tmr2, delaySec)	-- Set delay in milliseconds
	else					-- Handle the informational display delay timer
		if delay > 0 then
			Timer.pause(tmr2)
		end
	end

	-- Start drawing
	Graphics.initBlend()
	Screen.clear()
	if not Network.isWifiEnabled() then
		Graphics.debugPrint(5, 220, "Please enable WiFi.", Color.new(255,255,255))
	elseif not jsonValid then 
		Graphics.debugPrint(5, 220, "Error: Site may be blocked in your country", Color.new(255,255,255))
	elseif img == nil then
		Graphics.debugPrint(5, 220, "Please enable WiFi.", Color.new(255,255,255))
	else
		if height > width then
			Graphics.drawScaleImage(drawWidth, 0, img, 544 / height, 544 / height)
		elseif width > height then
			Graphics.drawScaleImage(0, drawHeight, img, 960 / width, 960 / width)
		end
	end

	-- "Menu"
	if delay < 0 then			-- Informational display delay dimer is set, print info by function ID
		menu = true				-- Set menu visibility to false
		if response == 1 or response == 2 then 													-- timerIncrease()/timerDecrease()
			Graphics.fillRect(15, 236, 30, 80, translucentBlack)
			Font.print(fnt0, 20, 30, string.format("Delay: %02ds", seconds), white)
		elseif response == 3 then																-- toggleAutoNext()
			Graphics.fillRect(15, 245, 30, 78, translucentBlack)								
			if Timer.isPlaying(tmr) then
				Font.print(fnt0, 20, 30, string.format("Timer: %02ds", timeSec), white)
			else
				Font.print(fnt0, 20, 30, "Timer: Off", white)
			end
		elseif response == 4 then
			menu = false
			if status == 0 then
				Graphics.fillRect(15, 415, 30, 80, translucentBlack)
			elseif status == 1 then
				Graphics.fillRect(15, 555, 30, 80, translucentBlack)
			else
				Graphics.fillRect(15, 290, 30, 78, translucentBlack)
			end
			Font.print(fnt0, 20, 30, message, white)
		else
			menu = false
			Graphics.fillRect(15, 320, 30, 80, translucentBlack)
			Font.print(fnt0, 20, 30, message, white)
		end
	else
		menu = false		-- Set menu visibility to false
	end
	-- Finish drawing
	Graphics.termBlend()
	Screen.flip()
	Screen.waitVblankStart()
end
