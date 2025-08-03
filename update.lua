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
        if not is_player_dead() and not room_transition then
            update_dir_input()
            player_move()
            move_enemies()
            update_enemies()
            get_player_hitbox()
            player_attack()
            get_player_att_hitbox()
            player_collision()
            update_b_input()
            update_active_bomb()
            deploy_bomb()
            player_take_bomb_dmg()
            enemy_take_bomb_dmg()
            calc_hp_sprites()
            collect_item()
            for dir in all({"left", "right", "up", "down"}) do
	            bomb_secret_door(dir)
            end
            
            --setup initial room, the rest will be handled during room transitions
            if game_mode == "normal" and not active_room_configured then
                copy_room_tiles(m_offset_template, m_offset_active)
                set_door_tiles(room_current, m_offset_active)
                active_room_configured = true
            end

            if game_mode == "endless_demo" then
                spawn_enemies_endless() --"endless mode" demo
            end

            --sfx
            bomb_sfx()
            
            --music
            if time() > 0.2 then
                --play_song_of_healing()
            end

           if game_mode == "normal" then
                check_player_in_door()
           end

        elseif room_transition then
            active_room_configured = false

            if not room_vignette_close_complete then
                if radius_room_trans_vignette > 0 then
                    radius_room_trans_vignette -= 10
                else
                    room_current = room_next
                    copy_room_tiles(m_offset_template, m_offset_active)
                    set_door_tiles(room_current, m_offset_active)
                    room_vignette_close_complete = true
                    if p.dir == "left" then
                        p.x = 104
                    elseif p.dir == "right" then
                        p.x = 16
                    elseif p.dir == "up" then
                        p.y = 88
                    elseif p.dir == "down" then
                        p.y = 32
                    end
                end
            elseif not room_vignette_open_complete then
                if radius_room_trans_vignette < 120 then
                    radius_room_trans_vignette += 10
                else
                    room_vignette_open_complete = true
                end
            else
                room_vignette_close_complete = false
                room_vignette_open_complete = false
                room_transition = false
                active_room_configured = true
            end
        else -- player is dead
            calculate_player_death_vignettes()
        end -- player is dead
	end
end --update