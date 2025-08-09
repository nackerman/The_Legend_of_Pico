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
	print("⁙"..p.bombs, 94, 1)
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
			spr(233 + global_timer%2, bomb_coord_sp.x, bomb_coord_sp.y)
		elseif bomb_timer <= (bomb_timer_start/5)*2 then
			spr(231 + global_timer%2, bomb_coord_sp.x, bomb_coord_sp.y)
		elseif bomb_timer <= (bomb_timer_start/5)*3 then
			spr(229 + global_timer%2, bomb_coord_sp.x, bomb_coord_sp.y)
		elseif bomb_timer <= (bomb_timer_start/5)*4 then
			spr(227 + global_timer%2, bomb_coord_sp.x,	bomb_coord_sp.y)
		else
			spr(225 + global_timer%2, bomb_coord_sp.x, bomb_coord_sp.y)
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
			bomb_coord_center = {}
			bomb_coord_sp = {}
			
			p.bomb_dmg_taken = false
			for e in all(enemies) do
				e.bomb_dmg_taken = false
			end
			door_bombed = false
		end
	end
end

function draw_bomb_explode()
	if bomb_explode then
		if not is_player_dead() then
			circfill(bomb_coord_center.x, bomb_coord_center.y, bomb_explode_r, 9 + global_timer%2)
		else
			circfill(bomb_coord_center.x, bomb_coord_center.y, bomb_explode_r, 9)
		end
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
			if  is_in_circle(i, j, bomb_coord_center.x, bomb_coord_center.y, bomb_explode_r) then
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
	if game_mode == "normal" then
		rectfill(0, 120, 127, 127, 0)
	end
end

function draw_vignette(cx, cy, r_outer, r_inner, fill_pattern)
    -- corners and top/bottom bars
    local circ_bounds = get_circle_bounds_at_y(cy, cx, cy, r_outer)

    rectfill(-1, 0, circ_bounds.x1, 127, 0)
    rectfill(circ_bounds.x2, 0, 128, 127, 0)
    rectfill(0, 0, 127, cy - r_outer, 0)
    rectfill(0, 127, 127, cy + r_outer, 0)

    for row = (cy - r_outer), (cy + r_outer) do
        local inner_bounds = get_circle_bounds_at_y(row, cx, cy, r_inner)
        local outer_bounds = get_circle_bounds_at_y(row, cx, cy, r_outer)

        rectfill(cx - r_outer, row, outer_bounds.x1, row, 0)
        rectfill(outer_bounds.x2, row, cx + r_outer, row, 0)

		fillp(fill_pattern)
		rectfill(cx - r_outer, row, inner_bounds.x1, row, 0)
		rectfill(inner_bounds.x2, row, cx + r_outer, row, 0)
		fillp()
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

function find_comma(s)
	for i = 1, #s do
		if sub(s, i, i) == "," then
			return i
		end
	end
	return nil
end

function get_coords_from_tile_key(key)
    local i = find_comma(key)
	return tonum(sub(key, 1, i - 1)), tonum(sub(key, i + 1))
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

function copy_room_tiles(offset_tx, offset_rx)
	for i = 0, 15 do
		for j = 0, 15 do
			local t = mget(i + offset_tx[1], j + offset_tx[2])
			mset(i + offset_rx[1], j + offset_rx[2], t)
		end
	end
end

function set_door_tiles(room_id, m_offset)
	--room_id is a string coordinate, i.e., "0,0"
	--dungeon grid coord from proc gen, not map or sprite coord
	local room = room_defs[room_id]
	local offset_x = m_offset[1]
	local offset_y = m_offset[2]

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

function bomb_secret_door(dir)
	if is_player_dead() or game_mode == "endless_demo" then
		return
	end

	if bomb_explode and not door_bombed then
		if room_defs[room_current].doors[dir] == "secret_closed" then
			for i = door_hb[dir].x1, door_hb[dir].x2 do
				for j = door_hb[dir].y1, door_hb[dir].y2 do
					if is_in_circle(i, j, bomb_coord_center.x, bomb_coord_center.y, bomb_explode_r) then
						room_defs[room_current].doors[dir] = "secret_open"
						sfx(9)
						door_bombed = true
						active_room_configured = false
					end
				end
			end
		end
	end
end

function get_next_room_id(d) --d is a direction
	local x, y = get_coords_from_tile_key(room_current)
	local dx, dy = dir.vec[d][1], dir.vec[d][2]
	
	return get_tile_key(x + dx, y + dy)
end

function check_player_in_door()
	local hb = door_scroll_hb[p.dir]
	local align = door_align[p.dir]
	local pa = p[align.axis]		--player alignment info
	local da = hb[align.axis.."1"]  --door alignment coord (i.e., "x1", "y1", "x2", or "y2")

	if collision({x1=p.x, y1=p.y, x2=p.x+7, y2=p.y+7}, hb) 
	and btn(dir.btns[p.dir]) and (room_defs[room_current].doors[p.dir] == "open" or 
	room_defs[room_current].doors[p.dir] == "secret_open") then

		if pa == da then
			room_transition = true
			p.is_aligned_with_door = p.dir

			--load template into next room
			copy_room_tiles(m_offset_template, m_offset_next)
			--populate doors for next room
			
			room_next = get_next_room_id(p.dir)
			set_door_tiles(room_next, m_offset_next)

			--snap camera to next room
			map(m_offset_next[1], m_offset_next[2])
		else
			p.is_aligned_with_door = "none"
			if pa < da then
				p[align.axis] += 1
			elseif pa > da then
				p[align.axis] -= 1
			end
		end

	else
		room_transition = false
	end
end

function reset_room_objects()
	bomb_active = false
	bomb_timer = 0
	bomb_explode = false
	door_bombed = false
	bomb_coord_sp = {0, 0}
	bomb_cord_center = {0, 0}
end