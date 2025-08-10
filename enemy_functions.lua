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

function can_move_e(dir, e, e1)
	if collision({x1 = e.hb_cur.x1 + dir[1], y1 = e.hb_cur.y1 + dir[2], x2 = e.hb_cur.x2 + dir[1], y2 = e.hb_cur.y2 + dir[2]}, e1.hb_cur) then
		return false
	else
		return true
	end
end

function move_enemies()	
	for e in all(enemies) do
		--default to no movment
		e.x_next = e.x
		e.y_next = e.y

		if e.id == "bat" then
			local dx_p = e.x - p.x --delta x to player
			local dy_p = e.y - p.y -- delta y to player

			local new_dir = {0, 0}
			if (abs(dx_p) > abs(dy_p)) then --move in x direction
				if sgn(dx_p) == 1 then
					new_dir = {-1, 0}
				else
					new_dir = {1, 0}
				end
			else -- move in y direction
				if sgn(dy_p) == 1 then
					new_dir = {0, -1}
				else
					new_dir = {0, 1}
				end
			end
			
			-- update enemies' next move coord in new dir if they aren't blocked and if not stunned from taking damage
			if global_timer%npc_anim_delay == 0 then
				if not e.sword_dmg_taken and not e.bomb_dmg_taken then 
					e.x_next = e.x + new_dir[1]
					e.y_next = e.y + new_dir[2]
				end
			end
		else -- not a bat, ground-based enemies:
			local enemy_tile = { x = flr(e.x/8), y = flr(e.y/8) }
			local player_tile = { x = flr(p.x/8), y = flr(p.y/8) }
			local path = a_star(enemy_tile, player_tile)

			if path and #path > 1 and global_timer%npc_anim_delay == 0 then
				local next_tile = path[2]
				local target_x = next_tile.x*8
				local target_y = next_tile.y*8

				local dx = target_x - e.x
				local dy = target_y - e.y

				if abs(dx) > abs(dy) then
					-- move in x direction only
					if dx > 0 then
						e.x_next = e.x + 1
					elseif dx < 0 then
						e.x_next = e.x - 1
					end
					e.y_next = e.y
				else
					-- move in y direction only
					if dy > 0 then
						e.y_next = e.y + 1
					elseif dy < 0 then
						e.y_next = e.y - 1
					end
					e.x_next = e.x
				end
			end
		end
	end

	-- Validate moves, move if able
	local reserved = {}

	for e in all(enemies) do
		local next_hb = get_hitbox_at(e.hb_dims, e.x_next, e.y_next, "full")
        local can_move = true

		if e.id ~= "bat" and collides_with_wall(e.x_next, e.y_next, {x1=0,y1=0,x2=8,y2=8}) then
			can_move = false
		end

		--check collision with stationary enemies
		for other in all(enemies) do
			if other ~= e then
				local other_stationary = (other.x_next == other.x and other.y_next == other.y)
				if other_stationary and collision(next_hb, other.hb_cur, false) then
					can_move = false
					break
				end
			end
		end

		--check against reserved positions
		if can_move then
			for r in all(reserved) do
				if collision(r, next_hb, false) then
					can_move = false
					break
				end
			end
		end

		--if can move, make move
		if can_move then
			add(reserved, next_hb)
			e.x = e.x_next
			e.y = e.y_next
		else
			e.x_next = e.x
			e.y_next = e.y
		end
	end
end

function spawn_enemies_endless()
	local attempts = 0

	while #enemies < 10 and attempts < 50 do
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