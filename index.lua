Network.init()

json = dofile("ux0:/app/RAND00001/deps/json.lua")
h,m,s = System.getTime()
math.randomseed(s)

if Network.isWifiEnabled() then
	Network.downloadFile("https://konachan.com/post.json?limit=250&tags=-pool:309+order:score+rating:explict", "ux0:/data/post.json")
	file = System.openFile("ux0:/data/post.json", FREAD)
	size = System.sizeFile(file)
	jsonEncoded = System.readFile(file, size)
	jsonDecoded = json.decode(jsonEncoded)
end

::gethentai::

if Network.isWifiEnabled() then
	if img ~= nil then
		Graphics.freeImage(img)
		img = nil
	end
	rand = math.random(#jsonDecoded)
	url = jsonDecoded[rand]["jpeg_url"]
	Network.downloadFile(url, "ux0:/data/randomhentai.jpg")
	img = Graphics.loadImage("ux0:/data/randomhentai.jpg")
	System.deleteFile("ux0:/data/randomhentai.jpg")
	width = Graphics.getImageWidth(img)
	height = Graphics.getImageHeight(img)
	drawWidth = 480 - (width * 544 / height / 2)
	drawHeight = 272 - (height * 960 / width / 2)

end

while true do

	Graphics.initBlend()
	Screen.clear()
	if not Network.isWifiEnabled() then
		Graphics.debugPrint(5, 220, "Please enable WiFi.", Color.new(255,255,255))
	end
	if img == nil then
		Graphics.debugPrint(5, 220, "Please enable WiFi.", Color.new(255,255,255))
	else
		if height > width then
			Graphics.drawScaleImage(drawWidth, 0, img, 544 / height, 544 / height)
		elseif width > height then
			Graphics.drawScaleImage(0, drawHeight, img, 960 / width, 960 / width)
		end
	end
	Graphics.termBlend()
	Screen.flip()
	Screen.waitVblankStart()

	if Controls.check(Controls.read(), SCE_CTRL_CROSS) then
		goto gethentai
	end

end
