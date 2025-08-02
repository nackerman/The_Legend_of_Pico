function update_enemies()
	for e in all(enemies) do
		local sp_base

		e.hb_cur.x1 = e.x + e.hb_dims.x1
		e.hb_cur.y1 = e.y + e.hb_dims.y1 
		e.hb_cur.x2 = e.x + e.hb_dims.x2
		e.hb_cur.y2 = e.y + e.hb_dims.y2

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
	end
end

function draw_enemies()
	for e in all(enemies) do
		if not e.sword_dmg_taken and not e.bomb_dmg_taken then
			spr(e.sp, e.x, e.y)
		else
			draw_sp_mask(e.sp, e.x, e.y, false, 8)
		end
		if display_hitbox == true then
			color(10)
			rect(e.hb_cur.x1, e.hb_cur.y1, e.hb_cur.x2, e.hb_cur.y2)
		end
	end
end

function enemy_take_bomb_dmg()
	if bomb_explode then
		for e in all(enemies) do
			if hitbox_in_bomb_r(e.hb_cur) and not e.bomb_dmg_taken then
				e.hp -= 1
				e.bomb_dmg_taken = true
				if e.hp <= 0 then
					del(enemies, e)
				end
			end
		end
	end
end

function move_enemies()
	for e in all(enemies) do
		local dx_p = e.x - p.x --delta x to player
		local dy_p = e.y - p.y -- delta y to player
		local can_move_left = true
		local can_move_right = true
		local can_move_up = true
		local can_move_down = true

		new_direction = nil

		if (abs(dx_p) > abs(dy_p)) then --move in x direction
			if sgn(dx_p) == 1 then
				new_direction = "left"
			else
				new_direction = "right"
			end
		else -- move in y direction
			if sgn(dy_p) == 1 then
				new_direction = "up"
			else
				new_direction = "down"
			end
		end

		--check for collision with other enemies, prevent movement if collision would occur
		for e1 in all(enemies) do
			if e1 ~= e then
				if new_direction == "left" then
					if collision(
						{ 	x1 = e.hb_cur.x1 - 1,
							y1 = e.hb_cur.y1,
							x2 = e.hb_cur.x2 - 1,
							y2 = e.hb_cur.y2
						}, e1.hb_cur) then
						can_move_left = false
					end
				elseif new_direction == "right" then
					if collision(
						{ 	x1 = e.hb_cur.x1 + 1,
							y1 = e.hb_cur.y1,
							x2 = e.hb_cur.x2 + 1,
							y2 = e.hb_cur.y2
						}, e1.hb_cur) then
						can_move_right = false
					end
				elseif new_direction == "up" then
					if collision(
						{ 	x1 = e.hb_cur.x1,
							y1 = e.hb_cur.y1 - 1,
							x2 = e.hb_cur.x2,
							y2 = e.hb_cur.y2 - 1
						}, e1.hb_cur) then
						can_move_up = false
					end
				elseif new_direction == "down" then
					if collision(
						{ 	x1 = e.hb_cur.x1,
							y1 = e.hb_cur.y1 + 1,
							x2 = e.hb_cur.x2,
							y2 = e.hb_cur.y2 + 1
						}, e1.hb_cur) then
						can_move_down = false
					end
				end
			end
		end
		
		-- move enemies in new direction if they aren't blocked and if not stunned from taking damage
		if global_timer%npc_anim_delay == 0 then
			if new_direction == "left" and can_move_left 
			and not e.sword_dmg_taken and not e.bomb_dmg_taken then 
				e.x_next = e.x - 1 
			end
			
			if new_direction == "right" and can_move_right 
			and not e.sword_dmg_taken and not e.bomb_dmg_taken then
				e.x_next = e.x + 1 
			end

			if new_direction == "up" and can_move_up 
			and not e.sword_dmg_taken and not e.bomb_dmg_taken then 
				e.y_next = e.y - 1
			end

			if new_direction == "down" and can_move_down 
			and not e.sword_dmg_taken and not e.bomb_dmg_taken then
				e.y_next = e.y + 1
			end
		end
	end

	local reserved = {}

	for e in all(enemies) do
		if reserved == nil then
			add(reserved, get_hitbox_at(e.hb_dims, e.x_next, e.y_next))
			e.x = e.x_next
			e.y = e.y_next
		else
			local can_reserve = true
			for r in all(reserved) do
				if collision(r, get_hitbox_at(e.hb_dims, e.x_next, e.y_next)) then
					can_reserve = false
					break				
				end
			end
			
			if can_reserve then
				add(reserved, get_hitbox_at(e.hb_dims, e.x_next, e.y_next))
				e.x = e.x_next
				e.y = e.y_next
			end
			
		end
	end
end

function spawn_enemies_endless()
	local attempts = 0

	while #enemies < 20 and attempts < 50 do
		attempts += 1

		local key = flr(rnd(3)) + 1 --just bats, slimes, and skeletons, for now
		local sp_x, sp_y

		local x1 = enemy_type_def[key].hb_dims.x1
		local y1 = enemy_type_def[key].hb_dims.y1
		local x2 = enemy_type_def[key].hb_dims.x2
		local y2 = enemy_type_def[key].hb_dims.y2

		local wall = flr(rnd(4)) + 1 --1 = left, 2 = right, 3 = top, 4 = bottom

		-- spawn left edge of screen
		if wall == 1 then
			sp_x = 0
			sp_y = ceil(rnd(127 - y2)) + y2
		end
		
		--spawn right edge of screen
		if wall == 2 then
			sp_x = 127 - x2
			sp_y = ceil(rnd(127 - y2)) + y2
		end

		--spawn top edge of screen
		if wall == 3 then
			sp_x = ceil(rnd(127 - x2))
			sp_y = 8
		end

		--spawn bottom edge of screen
		if wall == 4 then
			sp_x = ceil(rnd(127 - x2))
			sp_y = 127 - y2
		end

		local can_spawn = true
		
		if collision(p.hb, 
		{
			x1 = x1 + sp_x,
			y1 = y1 + sp_y,
			x2 = x2 + sp_x,
			y2 = y2 + sp_y
		}) then
			can_spawn = false
		end

		for e in all(enemies) do
			if collision(e.hb_cur, 
			{
				x1 = x1 + sp_x,
				y1 = y1 + sp_y,
				x2 = x2 + sp_x,
				y2 = y2 + sp_y
			}) then
				can_spawn = false
			end
		end

		if can_spawn == true then
			add(enemies, 
					{	
						id = enemy_type_def[key].id,
						sp = enemy_type_def[key].sp, 
						x = sp_x,
						y = sp_y,
						x_next = sp_x,
						y_next = sp_y,
						hp = enemy_type_def[key].hp_start,
						hb_dims = enemy_type_def[key].hb_dims,
						hb_cur = {
							x1 = x1 + sp_x,
							y1 = y1 + sp_y,
							x2 = x2 + sp_x,
							y2 = y2 + sp_y
						},
						sword_dmg_taken = false,
						bomb_dmg_taken = false
					}
				)
		end
	end
end