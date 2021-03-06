function Initialize()
	sJSONParser = SELF:GetOption('JSONParser')
	sFileToRead = SELF:GetOption('FileToRead')
	
	--load the external JSON library
	JSON = assert(loadfile(sJSONParser))()
    JSON.strictTypes = true
end

function Update()
	--Create oldSongInfo if it doesn't exist
	if oldSongInfo == nill then
		local oldSongInfo
	end
	
	local File = io.open(sFileToRead)
	-- HANDLE ERROR OPENING FILE.
	if not File then
		print('ReadFile: unable to open file at ' .. sFileToRead)
		return
	end

	-- READ FILE CONTENTS AND CLOSE.
	local FileContents = File:read("*all")
	File:close()
	
	--Convert JSON to lua table and set meters
		nowPlaying_info = JSON:decode(FileContents)
	if nowPlaying_info ~= nill then
		if nowPlaying_info.playing then
			if oldSongInfo == nil or oldSongInfo.title ~= nowPlaying_info.song.title then
				if SKIN:GetMeter(SKIN:GetVariable("MeterTitleName")) ~= nil then
					SKIN:GetMeter(SKIN:GetVariable("MeterTitleName")):SetText(nowPlaying_info.song.title)
				end
				if SKIN:GetMeter(SKIN:GetVariable("MeterArtistName")) ~= nil then
					SKIN:GetMeter(SKIN:GetVariable("MeterArtistName")):SetText(nowPlaying_info.song.artist)
				end
				if SKIN:GetMeter(SKIN:GetVariable("MeterAlbumName")) ~= nil then
					SKIN:GetMeter(SKIN:GetVariable("MeterAlbumName")):SetText(nowPlaying_info.song.album)
				end

				SKIN:Bang('!SetVariable', 'CoverUrl', nowPlaying_info.song.albumArt)
				SKIN:Bang('!CommandMeasure', 'MeasureImageDownload', "Update")
			end
			local seconds = nowPlaying_info.time.total/1000
			if  SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")) ~= nil then
				if math.floor(seconds/(60*60)) ~= 0  then
					SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")):SetText(string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60))
				else
					SKIN:GetMeter(SKIN:GetVariable("MeterTotalTime")):SetText(string.format("%.2d:%.2d", seconds/60%60, seconds%60))
				end
			end
			local currentSeconds = nowPlaying_info.time.current/1000
			if SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")) ~= nil then
				if math.floor(currentSeconds/(60*60)) ~= 0 then
					SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")):SetText(string.format("%.2d:%.2d:%.2d", currentSeconds/(60*60), currentSeconds/60%60, currentSeconds%60))
				else
					SKIN:GetMeter(SKIN:GetVariable("MeterCurrentTime")):SetText(string.format("%.2d:%.2d", currentSeconds/60%60, currentSeconds%60))
				end
			end
			SKIN:Bang('!SetVariable', 'Length', nowPlaying_info.time.current / nowPlaying_info.time.total)
			oldSongInfo = nowPlaying_info.song
		end
	end
end