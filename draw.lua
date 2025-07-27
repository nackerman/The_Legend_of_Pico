function _draw()

	if game_state == "intro" then
		intro_screen_draw()
	end
	
	if game_state == "title_screen" then
	end
	
    if game_state == "game_start" then

            --clear screen, draw the map
            cls()
            map()
            
            --draw items
            draw_items()
            draw_active_bomb()
            draw_bomb_explode()
            
            --draw npcs
            draw_enemies()
        
            --draw player
            if p.i_frame_count == 0 then
                --regular draw
                draw_player()
            else
                --flashing i-frame draw
                draw_sp_mask(p.sp, p.x, p.y, p.f, (global_timer%2) + 7)
            end
            
            --hud elements
            draw_player_hp()
            draw_rupee_ui()
            draw_bomb_ui()
            draw_key_ui()
        
        if is_player_dead() then
            local x_offset = 0

            draw_player()

            for x = 0, 127 do
                for y = 0, 127 do

                    --dithered
                    if not is_in_circle(x, y, p.x + 4, p.y + 4, radius_inner_death_vignette) then
                        if y%2 == 0 then 
                            x_offset = 0
                        else
                            x_offset = 1
                        end

                        if x%2 == 0 then
                            pset(x - x_offset,y,0)
                        end
                    end
                    --solid
                    if not is_in_circle(x, y, p.x + 4, p.y + 4, radius_outer_death_vignette) then
                        pset(x,y,0)
                    end
                end
            end
        end
    end

end--end _draw()