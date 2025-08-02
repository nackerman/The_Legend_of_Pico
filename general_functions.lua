--general functions
function timers()
	global_timer += 1
	if global_timer%p.anim_delay == 0 then
		p.anim_timer += 1
	end
	if global_timer%npc_anim_delay == 0 then
		npc_anim_timer += 1
	end
	if p.i_frame_count > 0 then
		p.i_frame_count -= 1
	end
end

function intro_screen_update()	
	if btn() ~= 0 then
		game_state = "game_start"
	end
end

function intro_screen_draw()
    cls()
    print("you've met with a terrible fate,\nhaven't you?")
    print("you cannot escape the past.")
    print("you must confront it.")
    print("the only way out is through.")
end

function is_blocked_at(x,y)
	local tile_x = flr(x/8)
	local tile_y = flr(y/8)
	local tile = mget(tile_x + m_offset_active[1], tile_y + m_offset_active[2])
	return fget(tile,0)
end

function update_dir_input()
    for input, id in pairs(dir.btns) do
		if btn(id) then
			dir.held[input] = true
			if not dir.prev_held[input] then
				dir.priority[input] = time()
			end
		else
			dir.held[input] = false
			dir.priority[input] =- 1
		end
		dir.prev_held[input] = dir.held[input]
	end
end

function get_priority_dir()
	local x =- 1
	local selected_dir =- 1
	
	for input,val in pairs(dir.priority) do
		if x < val then
			x = val
			selected_dir = input
		end
	end
	
	return selected_dir
end

function check_att_input()
	local is_held = btn(5)
	local was_held = p.att_held_prev
	
	p.att_held_prev = is_held
	
	if is_held and not was_held then
		return true
	end
	
	return false
end

function collision(h1, h2)
	return not (
		h1.x2<h2.x1 or
		h1.x1>h2.x2 or
		h1.y2<h2.y1 or
		h1.y1>h2.y2
	)
end

function draw_rupee_ui()
	local x = #(tostr(p.rupees))
	local pad = ""
	
	if x == 1 then pad="00"
	elseif x == 2 then pad="0"
	end
	
	spr(240, 104, 0)
	color(7)
	if p.rupees == p.max_rupees then
		color(11)
	end
	print("⁙"..pad..p.rupees, 112, 1)
end

function draw_bomb_ui()	
	spr(224, 84, 0)
	color(7)
	if p.bombs == p.max_bombs then
		color(11)
	end
	print("⁙"..p.bombs, 93, 1)
end

function draw_key_ui()
	spr(243, 64, 0)
	color(7)
	if p.keys == p.max_keys then
		color(11)
	end
	print("⁙"..p.keys, 73, 1)
end

function draw_sp_mask(sp, dx, dy, f, mask_color)
	local sx = (sp%16)*8
	local sy = flr(sp/16)*8
	
	for x = 0, 7 do
		local xf = x
		if f then
			xf = 7-x
		end
		
		for y = 0,7 do
			local c = sget(sx + xf, sy + y)
			if c ~= 0 then
				pset(dx+x, dy+y, mask_color)
			end
		end
	end
end --draw_sp_mask()

function draw_items()
	for i in all(items) do
		spr(i.sp, i.x, i.y)
	end
end

function draw_active_bomb()
	if bomb_active then
		if bomb_timer <= bomb_timer_start/5 then
			spr(233 + global_timer%2, bomb_coord.x, bomb_coord.y)
		elseif bomb_timer <= (bomb_timer_start/5)*2 then
			spr(231 + global_timer%2, bomb_coord.x, bomb_coord.y)
		elseif bomb_timer <= (bomb_timer_start/5)*3 then
			spr(229 + global_timer%2, bomb_coord.x, bomb_coord.y)
		elseif bomb_timer <= (bomb_timer_start/5)*4 then
			spr(227 + global_timer%2, bomb_coord.x,	bomb_coord.y)
		else
			spr(225 + global_timer%2, bomb_coord.x, bomb_coord.y)
		end
	end --if bomb_active
end --draw_active_bomb()

function update_active_bomb()
	if bomb_active then
		bomb_timer -= 1
		if bomb_timer == 0 then
			bomb_active = false
			bomb_explode_time = bomb_explode_time_start
			bomb_explode = true
		end
	end
	if bomb_explode then
		bomb_explode_time -= 1
		if bomb_explode_time == 0 then
			bomb_explode = false
			bomb_coord = {}
			for e in all(enemies) do
				e.bomb_dmg_taken = false
			end
		end
	end
end

function draw_bomb_explode()
	if bomb_explode then
		circfill(bomb_coord.x + 3, bomb_coord.y + 4, bomb_explode_r, 9 + global_timer%2)
	end
end

function is_in_circle(x, y, cx, cy, r)
	local dx = x - cx
	local dy = y - cy
	
	return dx*dx + dy*dy <= r*r
end

function hitbox_in_bomb_r(hb_cur)	
	for i = hb_cur.x1, hb_cur.x2 do
		for j = hb_cur.y1, hb_cur.y2 do
			if  is_in_circle(i, j, bomb_coord.x+3, bomb_coord.y+4, bomb_explode_r) then
				return true
			end
		end
	end
end

function get_circle_bounds_at_y(y, cx, cy, r)
	local x1 = -1
	local x2 = -1

	if (y - cy)*(y - cy) <= r*r then
		local dx = sqrt(r*r - (y - cy)*(y - cy))
		x1 = cx - dx
		x2 = cx + dx
	else
		x1 = nil
		x2 = nil
	end

	return {x1 = flr(x1), x2 = flr(x2)}
end

function get_hitbox_at(hb_dims, x, y)
	return {
		x1 = x + hb_dims.x1,
		y1 = y + hb_dims.y1,
		x2 = x + hb_dims.x2,
		y2 = y + hb_dims.y2
	}
end

function draw_ui()
	--top ui
	rectfill(0,0,127,7,0)
	draw_player_hp()
	draw_rupee_ui()
	draw_bomb_ui()
	draw_key_ui()
	
	--bottom ui
	if game_state == "game_start" and game_mode ~= "endless_demo" then
		rectfill(0, 120, 127, 127, 0)
	end
end

--start a*
function is_walkable(tx,ty)
	--return false if out of bounds of the screen
	if tx < 0 or tx > 15 or ty < 0 or ty > 15 then
		return false
	end
	
	return not fget(mget(tx + m_offset_active[1], ty + m_offset_active[2]), 0) -- check flag 0 of tile sprite
end

function heuristic(a,b) --manhattan distance
	return abs(a.x - b.x) + abs (a.y - b.y)
end

function get_neighbors(node)
	--get walkable neighbor tiles for a given node
	local dirs = { {-1, 0}, {1, 0}, {0, -1}, {0, 1} }
	local result = {}

	for d in all(dirs) do
		local nx = node.x + d[1]
		local ny = node.y + d[2]

		if is_walkable(nx, ny) then
			add(result, { x = nx, y = ny })
		end
	end
	
	return result
end

function get_tile_key(x,y)
	return x .. "," .. y
end

function a_star()
	local open, closed = {}, {}
	local start_key = get_tile_key(start.x, start.y)
	
	open[start_key] = {
		x=start.x, y=start.y, g=0, h=heuristic(start, goal), f=0,
		parent=nil
	}
	open[start_key].f = open[start_key].g + open[start_key].h

	while true do
		local current_key, current = nil, nil

		-- find node in open with lowest f
		for k, node in pairs(open) do
			if not current or node.f < current.f then
				current_key, current = k, node
			end
		end

		if not current then return nil end -- no path
		if current.x == goal.x and current.y == goal.y then
			-- reconstruct path
			local path = {}
			while current do
				add(path, 1, {x=current.x, y=current.y})
				current = current.parent
			end
			return path
		end

		open[current_key] = nil
		closed[current_key] = true

		for neighbor_pos in all(get_neighbors(current)) do
			local key = get_tile_key(neighbor_pos.x, neighbor_pos.y)
			if closed[key] then goto continue end

			local g = current.g + 1
			local h = heuristic(neighbor_pos, goal)
			local f = g + h

			local existing = open[key]
			if not existing or g < existing.g then
				open[key] = {
					x=neighbor_pos.x, y=neighbor_pos.y,
					g=g, h=h, f=f,
					parent=current
				}
			end
			::continue::
		end
	end
end
--end of a* pathing functions

function set_active_room_from_template(offset, room_def)
	for i = 0, 15 do
		for j = 0, 15 do
			local t = mget(i + m_offset_template[1], j + m_offset_template[2])
			mset(i + m_offset_active[1], j + m_offset_active[2], t)
		end
	end
end

function set_door_tiles(room_id)
	--room_id is a string coordinate, i.e., "0,0"
	--dungeon grid coord from proc gen, not map or sprite coord
	local room = room_defs[room_id]
	local offset_x = m_offset_active[1]
	local offset_y = m_offset_active[2]

	for dir, state in pairs(room.doors) do
		local tile_pos = door_tile_loc[dir]
		local sp = door_sp[dir][state]

		--top row
		mset(offset_x + tile_pos.t1[1], offset_y + tile_pos.t1[2], sp.t1)
		mset(offset_x + tile_pos.t2[1], offset_y + tile_pos.t2[2], sp.t2)
		
		--bottom row
		mset(offset_x + tile_pos.b1[1], offset_y + tile_pos.b1[2], sp.b1)
		mset(offset_x + tile_pos.b2[1], offset_y + tile_pos.b2[2], sp.b2)
	end
end