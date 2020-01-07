Network.init()
::gethentai::

if Network.isWifiEnabled() then
	if not img == nil then
		Graphics.freeImage(img)
		img = nil
	end
	Network.downloadFile("http://api.jaylongowie.tk:3000/hentai", "ux0:/data/randomhentai.png")
	img = Graphics.loadImage("ux0:/data/randomhentai.png")
	System.deleteFile("ux0:/data/randomhentai.png")
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
	
	if Controls.check(Controls.read(), SCE_CTRL_CROSS) then
		System.wait(1000000)
		goto gethentai
	end
	
end