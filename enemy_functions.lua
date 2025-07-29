function update_enemies()
	for e in all(enemies) do
		--update current hitbox positon
		e.hb_cur.x1 = e.x + e.hb_dims.x1
		e.hb_cur.y1 = e.y + e.hb_dims.y1 
		e.hb_cur.x2 = e.x + e.hb_dims.x2
		e.hb_cur.y2 = e.y + e.hb_dims.y2

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

function enemy_take_bomb_dmg()
	for e in all(enemies) do
		if hitbox_in_bomb_r(e.hb_cur) then
			e.hp -= 1
			if e.hp <= 0 then
				del(enemies, e)
			end
		end
	end
end

function move_enemies()
	for e in all(enemies) do
		--check direction to player
		local dx = e.x - p.x
		local dy = e.y - p.y
		
		if e.id == "bat" then
			--move towards player
			if global_timer%npc_anim_delay == 0 then
				if (abs(dx) > abs(dy)) then
					e.x = e.x - sgn(dx)
				else
					e.y = e.y - sgn(dy)
				end
			end
		end
	end
end

function spawn_enemies_endless()
	while #enemies < 10 do
		local key = abs(ceil(rnd(1))) --just bats, for now
		local sp_x, sp_y

		local x1 = enemy_type_def[key].hb_dims.x1
		local y1 = enemy_type_def[key].hb_dims.y1
		local x2 = enemy_type_def[key].hb_dims.x2
		local y2 = enemy_type_def[key].hb_dims.y2

		local wall = abs(ceil(rnd(3))) --1 = left, 2 = right, 3 = top, 4 = bottom

		if wall == 1 then
			sp_x = 0
			sp_y = abs(ceil(rnd(127 - y1)))
		end
		if wall == 2 then
			sp_x = 127 - x2
			sp_y = abs(ceil(rnd(127)))
		end
		if wall == 3 then
			sp_x = abs(ceil(rnd(127 - x2)))
			sp_y = 8
		end
		if wall == 4 then
			sp_x = abs(ceil(rnd(127 - x2)))
			sp_y = 127 - y1
		end

		add(enemies, 
			{	
				id = enemy_type_def[key].id,
				sp = 64, 
				x = sp_x,
				y = sp_y,
				hp = enemy_type_def[key].hp_start,
				hb_dims = enemy_type_def[key].hb_dims,
				hb_cur = {
					x1 = x1 + sp_x,
					y1 = y1 + sp_y,
					x2 = x2 + sp_x,
					y2 = y2 + sp_y
				},
				sword_dmg_taken = false
			}
		)
	end
end