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
	end--end "game start" draw
end--end _draw()