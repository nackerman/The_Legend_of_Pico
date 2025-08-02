function bomb_sfx()
	if bomb_explode_time == bomb_explode_time_start - 1 then
		sfx(8)
	end
end

function play_song_of_healing()
	if stat(16) == -1 and stat(17) == -1 then
		if soh_pos <= #soh.track1 then
			sfx(soh.track1[soh_pos], 0)
		end
	end

	if stat(17) == -1 then
		if soh_pos <= #soh.track1 then
			sfx(soh.track2[soh_pos], 1)
			soh_pos += 1
		else
			soh_pos = 1
		end
	end
end