function _draw()

	if game_state == "intro" then
		intro_screen_draw()
	end
	
	if game_state == "title_screen" then
	end
	
    if game_state == "game_start" then
        cls()
        
        camera(0,0)
        local m_offset = m_offset_active

        --if test ~= "false" then
        --    m_offset = m_offset_next
        --end

        map(m_offset[1], m_offset[2])
        
        draw_items()
        draw_active_bomb()
        draw_bomb_explode()
        draw_enemies()

        if not is_player_dead() then        
            if p.i_frame_count == 0 then
                draw_player()
            else
                draw_sp_mask(p.sp, p.x, p.y, p.f, (global_timer%2) + 7)
            end

            if room_transition then
                draw_vignette(p.x + 4, p.y + 4, radius_room_trans_vignette, radius_room_trans_vignette)
            end

            draw_ui()
            
        else -- player is dead
            local cx = p.x + 4
            local cy = p.y + 4
            local circ_bounds = get_circle_bounds_at_y(cy, cx, cy, radius_outer_death_vignette)

            rectfill(0,0,127,7,0)
           	if game_mode ~= "endless_demo" then
		        rectfill(0, 120, 127, 127, 0)
	        end

            draw_vignette(cx, cy, radius_outer_death_vignette, radius_inner_death_vignette, ░)
            
            draw_player()  --maybe update to a "death" pose, instead of just drawing the player?
            draw_player_hp()
        end
    end

    if display_cpu_usage then
        print("cpu: "..flr(stat(1)*100).."%", 1, 121, 7)
    end

    --debugging and testing
    for i in all(path_test) do
        local x1 = i.x*8
        local y1 = i.y*8
        local x2 = x1+8
        local y2 = y1+8
        rect(x1, y1, x2, y2, 14)
    end
    if path_test then
        print(tostr(path_test[1].x*8).." "..tostr(path_test[1].y*8), 10, 10, 14)
    end
    for e in all(enemies) do
        print(tostr(e.x).." "..tostr(e.y), 10, 18, 14)
    end
end