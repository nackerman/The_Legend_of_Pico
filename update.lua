function _update()
	timers()
	
	if game_state == "intro" then
		intro_screen_update()
				
		--music
		if time() > 0.2 then
			play_song_of_healing()
		end
	end
	
	if game_state == "title_screen" then
	end
	
	if game_state == "game_start" then
		update_dir_input()
		update_b_input()
		enemy_take_bomb_dmg()
		update_active_bomb()
		deploy_bomb()
		player_move()
		get_player_hitbox()
		update_enemies()
		player_collision()
		player_attack()
		get_player_att_hitbox()
		calc_hp_sprites()
		collect_item()
		
		--sfx
		bomb_sfx()
		
		--music
		if time() > 0.2 then
			--play_song_of_healing()
		end
	end
end --update