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
            update_b_input()
            player_take_bomb_dmg()
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
            is_player_dead()

            --sfx
            bomb_sfx()
            
            --music
            if time() > 0.2 then
                --play_song_of_healing()
            end
        
        else -- player is dead
            i_frame_count = 0
            
            --if time() - p.time_of_death > 4 then
            --    radius_background_circ_vignette += 1
            --end

            if radius_outer_death_vignette >= radius_outer_death_vignette_min then
                radius_outer_death_vignette -= 5
            end
            
            if radius_inner_death_vignette >= radius_inner_death_vignette_min then
                radius_inner_death_vignette -= 5
            end
        end
	end
end --update