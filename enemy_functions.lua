function update_enemies()
	for e in all(enemies) do
		--update current hitbox positon
		e.hb_cur.x1 = e.x + e.hb_dims.x1
		e.hb_cur.y1 = e.y + e.hb_dims.y1 
		e.hb_cur.x2 = e.x + e.hb_dims.x2
		e.hb_cur.y2 = e.y + e.hb_dims.y2

		--update animations
		local sp_base
		
		if e.id == "bat" then
			sp_base = enemy_type_def[1].sp
		end
		if e.id == "slime" then
			sp_base = enemy_type_def[2].sp
		end
		if e.id == "skeleton" then
			sp_base = enemy_type_def[3].sp
		end

		e.sp = sp_base + npc_anim_timer%2
	end --for e in all enemies
end --update_enemies()

function draw_enemies()
	for e in all(enemies) do
		if not e.sword_dmg_taken then
			--draw regular enemy sprite
			spr(e.sp, e.x, e.y)
		else
			--draw enemy sprite filled with red color
			draw_sp_mask(e.sp, e.x, e.y, false, 8)
		end
		--hitbox
		if display_hitbox == true then
			color(10)
			rect(e.hb_cur.x1, e.hb_cur.y1, e.hb_cur.x2, e.hb_cur.y2)
		end --bat hitbox
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
		new_direction = nil

		if (abs(dx) > abs(dy)) then --move in x direction
			if sgn(dx) == 1 then
				new_direction = "left"
			else
				new_direction = "right"
			end
		else -- move in y direction
			if sgn(dy) == 1 then
				new_direction = "up"
			else
				new_direction = "down"
			end
		end
		
		if global_timer%npc_anim_delay == 0 then
			if (abs(dx) > abs(dy)) then
				e.x -= sgn(dx)
			else
				e.y -= sgn(dy)
			end
		end
	end
end

function spawn_enemies_endless()
	while #enemies < 10 do
		local key = abs(ceil(rnd(3))) --just bats, slimes, and skeletons, for now
		local sp_x, sp_y

		local x1 = enemy_type_def[key].hb_dims.x1
		local y1 = enemy_type_def[key].hb_dims.y1
		local x2 = enemy_type_def[key].hb_dims.x2
		local y2 = enemy_type_def[key].hb_dims.y2

		local wall = abs(ceil(rnd(4))) --1 = left, 2 = right, 3 = top, 4 = bottom

		-- spawn left edge of screen
		if wall == 1 then
			sp_x = 0
			sp_y = abs(ceil(rnd(127 - y2))) + y2
		end
		
		--spawn right edge of screen
		if wall == 2 then
			sp_x = 127 - x2
			sp_y = abs(ceil(rnd(127 - y2))) + y1
		end

		--spawn top edge of screen
		if wall == 3 then
			sp_x = abs(ceil(rnd(127 - x2)))
			sp_y = 8
		end

		--spawn bottom edge of screen
		if wall == 4 then
			sp_x = abs(ceil(rnd(127 - x2)))
			sp_y = 127 - y2
		end

		add(enemies, 
			{	
				id = enemy_type_def[key].id,
				sp = enemy_type_def[key].sp, 
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