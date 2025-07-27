function update_enemies()
	for e in all(enemies) do
		--update current hitbox positon
		e.hb_cur.x1 = e.x + e.hb_dim.x1
		e.hb_cur.y1 = e.y + e.hb_dim.y1 
		e.hb_cur.x2 = e.x + e.hb_dim.x2
		e.hb_cur.y2 = e.y + e.hb_dim.y2

		--update animations
		if e.id == "bat" then
			e.sp = 64 + npc_anim_timer%2
		end --bats
	end --for e in all enemies
end --update_enemies()

function draw_enemies()
	for e in all(enemies) do
		--update this - it was initially set up for bats, but, it can be more generic now that the enemies table exists
        if e.id == "bat" then
			spr(e.sp, e.x, e.y)
			
			--hitbox
			if display_hitbox == true then
				color(10)
                rect(e.hb_cur.x1, e.hb_cur.y1, e.hb_cur.x2, e.hb_cur.y2)
			end --bat hitbox
		end --bats
	end -- for e in all enemies
end --draw_enemies()

function enemy_in_bomb_r(hb_cur)
	if bomb_explode_time == bomb_explode_time_start - 5 then	
		for i = hb_cur.x1, hb_cur.x2 do
			for j = hb_cur.y1, hb_cur.y2 do
				if  in_circle(i, j, bomb_coord.x+3, bomb_coord.y+4, bomb_explode_r) then
					return true
				end
			end
		end
	end
end

function enemy_take_bomb_dmg()
	for e in all(enemies) do
		if enemy_in_bomb_r(e.hb_cur) then
			e.hp -= 1
			if e.hp <= 0 then
				del(enemies, e)
			end
		end
	end
end