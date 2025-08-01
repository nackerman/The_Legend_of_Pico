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
        if not is_player_dead() then
            update_dir_input()
            player_move()
            move_enemies()
            update_enemies()
            get_player_hitbox()
            player_attack()
            get_player_att_hitbox()
            player_collision()
            update_b_input()
            player_take_bomb_dmg()
            enemy_take_bomb_dmg()
            update_active_bomb()
            deploy_bomb()
            calc_hp_sprites()
            collect_item()
            
            if game_mode == "endless_demo" then
                spawn_enemies_endless() --"endless mode" demo
            end

            --sfx
            bomb_sfx()
            
            --music
            if time() > 0.2 then
                --play_song_of_healing()
            end

        else -- player is dead
        
            calculate_player_death_vignettes()
        end -- player is dead
	end
end --update