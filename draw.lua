function _draw()

	if game_state == "intro" then
		intro_screen_draw()
	end
	
	if game_state == "title_screen" then
	end
	
    if game_state == "game_start" then
        cls()
        if game_mode == "normal" then
            map(m_offset_active[1], m_offset_active[2])
        elseif game_mode == "endless_demo" then
            map()
        end
        
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

            draw_ui()
        
        else -- player is dead
            local cx = p.x + 4
            local cy = p.y + 4
            local circ_test = get_circle_bounds_at_y(cy, cx, cy, radius_outer_death_vignette)
            local circ_test_x1 = circ_test.x1
            local circ_test_x2 = circ_test.x2

            rectfill(0, 0, circ_test_x1, 127, 0)
            rectfill(circ_test_x2, 0, 127, 127, 0)
            rectfill(0, 0, 127, cy - radius_outer_death_vignette, 0)
            rectfill(0, 127, 127, cy + radius_outer_death_vignette, 0)
            fillp()

            for row = (cy - radius_outer_death_vignette), (cy + radius_outer_death_vignette) do
                local inner_bounds = get_circle_bounds_at_y(row, cx, cy, radius_inner_death_vignette)
                local outer_bounds = get_circle_bounds_at_y(row, cx, cy, radius_outer_death_vignette)
                local inner_x1 = inner_bounds.x1
                local inner_x2 = inner_bounds.x2
                local outer_x1 = outer_bounds.x1
                local outer_x2 = outer_bounds.x2

                rectfill(cx - radius_outer_death_vignette, row, outer_x1, row, 0)
                rectfill(outer_x2, row, cx + radius_outer_death_vignette, row, 0)
                fillp(░)
                rectfill(cx - radius_outer_death_vignette, row, inner_x1, row, 0)
                rectfill(inner_x2, row, cx + radius_outer_death_vignette, row, 0)
                fillp()
            end
            
            draw_player()  --maybe update to a "death" pose, instead of just drawing the player?
            draw_player_hp()

        end
    end

    if display_cpu_usage then
        print("cpu: "..flr(stat(1)*100).."%", 1, 121, 7)
    end
end