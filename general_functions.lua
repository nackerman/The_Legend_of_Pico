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
	--check if a specific x,y
	--coord is a wall (sp flag 0)
	local tile_x = flr(x/8)
	local tile_y = flr(y/8)
	local tile = mget(tile_x,tile_y)
	
	return fget(tile,0)
end

--interpret the directional btns
function update_dir_input()
    for input, id in pairs(dir.btns) do
		--update currently held btns
		if btn(id) then
			dir.held[input] = true
			--check if just pressed
			if not dir.prev_held[input] then
				dir.priority[input] = time()
			end
		else
			dir.held[input] = false
			--clear time stamp if button 
			--is no longer pressed
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
	--inclusive collision
	--h1,h2={x1,y1,x2,y2}
	--note: player collision with
	--walls is handled elsewhere

	return not (
		h1.x2<h2.x1 or
		h1.x1>h2.x2 or
		h1.y2<h2.y1 or
		h1.y1>h2.y2
	)
end --collision()

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
	--dx,dy	= draw position of sp
	local sx = (sp%16)*8
	local sy = flr(sp/16)*8
	
	for x = 0, 7 do
		--is sp flipped?
		local xf = x
		if f then
			xf = 7-x
		end
		
		for y = 0,7 do
			--c = color
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
		end
	end
end

function draw_bomb_explode()
	if bomb_explode then
		circfill(bomb_coord.x + 3, bomb_coord.y + 4, bomb_explode_r, 9 + global_timer%2)
	end
end

function is_in_circle(x, y, cx, cy, r)
	--x,y=point to be tested
	--cx,cy=center of circ
	--r=rad of circ
	local dx = x - cx
	local dy = y - cy
	
	return dx*dx + dy*dy <= r*r
end

function hitbox_in_bomb_r(hb_cur)
	if bomb_explode_time == bomb_explode_time_start - 5 then	
		for i = hb_cur.x1, hb_cur.x2 do
			for j = hb_cur.y1, hb_cur.y2 do
				if  is_in_circle(i, j, bomb_coord.x+3, bomb_coord.y+4, bomb_explode_r) then
					return true
				end
			end
		end
	end
end

function get_circle_bounds_at_y(y, cx, cy, r)
	local x1 = -1
	local x2 = -1
	
	-- Only check if the row falls within the circle to begin with
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