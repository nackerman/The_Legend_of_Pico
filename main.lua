--init
    --**********************************
        --note regarding sprite flags:
        --f0: inhibits player move
        --f1: damage player on contact
        --f2: player can collect item
    --**********************************
	
function _init()
    --debug
    --display_hitbox = true
    
    --initialize game state and global timer
    game_state = "game_start"
	global_timer = 0

	--player variables
	p = {
		sp = 1,
		f = false,
		anim_delay = 4,
		anim_timer = 0,
		x = 60,
		y = 60,
		att_sp = 48,
		att_x,
		att_y,
		att_f,                      --attack sprite flip
		spd = 1,
		dir = "right",
		att = false,
		att_time = 10,
		att_count = 0,
		att_delay = 5,
		att_delay_count = 0,
		att_held_prev = false,
		att_hb,                     --sword hitbox
		hp = 3,	                    --current hp
		hp_max = 3,	                --current max hp
		hp_true_max = 10,             --total max with upgrades (hp can never surpass this)
		hp_sp_full = 192,             --full heart
		hp_sp_half = 193,	            --half heart
		hp_sp_empty = 194,            --empty heart
		hp_sp_array = {},	            --sp,x,y
		hb = {},                      --hitbox={x1,y1,x2,y2}
		i_frame_max = 15,             --total invincibility frames when hit
		i_frame_count = 0,            --current i_frames remaining
		rupees = 185,
		max_rupees = 200,
		bombs = 0,
		max_bombs = 3,
		keys = 0,
		max_keys = 3
	}
	
	--directional buttons
	dir = {
	    --definitions
		btns = {
			["left"]    = 0,
			["right"]   = 1,
			["up"]      = 2,
			["down"]    = 3
		},
		
        --used for picking direction if multiple dir btns held
		priority = {
			["left"]    = -1,
			["right"]   = -1,
			["up"]      = -1,
			["down"]    = -1
		},
		
        --dir buttons currently held
		held = {
			["left"]    = false,
			["right"]   = false,
			["up"]      = false,
			["down"]    = false
		},
		--dir buttons previously held
		prev_held = {
			["left"]    = false,
			["right"]   = false,
			["up"]      = false,
			["down"]    = false
		}
	}--dir{}
	
	--btn(4) input - bombs
	b_held = false
	b_prev_held = false
	
	--bomb vars
	bomb_active = false
	bomb_timer_start = 60
	bomb_timer = 0
	bomb_explode = false
	bomb_explode_r = 10   --radius
	bomb_explode_time = 0
	bomb_explode_time_start = 30
	
	--item variables
	items = {} --{id,sp,x,y}

	rupee_val = {
		rp_g = 1,
		rp_b = 5,
		rp_r = 20
	}
	
	bomb_coord = {} --x,y

	--enemy variables
	enemies = {} --{id, sp, x, y, hp, hb_dim, hb_cur}
	npc_anim_timer = 0
	npc_anim_delay = 6
	
	--hitbox dimension definitions
	--{x1,y1,x2,y2}
	--coords relative to sp x,y
	hb_dims = {
		bat = {
			x1 = 1,
			y1 = 1,
			x2 = 5,
			y2 = 3
		},
		
		rupee = {
			x1 = 1,
			y1 = 1,
			x2 = 6,
			y2 = 6
		},
		
		--this is for picking up the
		--item, not for the explosion
		bomb = {
			x1 = 0,
			y1 = 2,
			x2 = 4,
			y2 = 6
		},
		
		key = {
			x1 = 0,
			y1 = 0,
			x2 = 7,
			y2 = 7
		}
	}

	--music
	--song of healing
	soh_pos = 1 --time tracking
	soh = {
		track1 = {32, 32, 33, 34, 35, 36, 35, 37},
		track2 = {38, 38, 39, 39, 40, 41, 40, 42},
	}

	--spawn some bats for testing
	add(enemies, {id = "bat", sp = 64, x = 38, y = 38, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )	
	add(enemies, {id = "bat", sp = 65, x = 32, y = 32, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )
	add(enemies, {id = "bat", sp = 64, x = 20, y = 40, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )
	add(enemies, {id = "bat", sp = 64, x = 80, y = 50, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )	
	add(enemies, {id = "bat", sp = 65, x = 90, y = 60, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )
	add(enemies, {id = "bat", sp = 64, x = 80, y = 60, hp = 1, hb_dim = hb_dims.bat, hb_cur = {} } )

	--spawn some rupees for testing
	add(items, {id = "rp_g", sp = 240, x = 20, y = 30} )
	add(items, {id = "rp_g", sp = 240, x = 35, y = 50} )
	add(items, {id = "rp_b", sp = 241, x = 37, y = 60} )
	add(items, {id = "rp_r", sp = 242, x = 40, y = 70} )
	
	--spawn bombs for testing
	add(items, {id = "bomb", sp = 224, x = 5, y = 10} )
	add(items, {id = "bomb", sp = 224, x = 80, y = 80} )
	add(items, {id = "bomb", sp = 224, x = 5, y = 20} )
	add(items, {id = "bomb", sp = 224, x = 80, y = 90} )
	add(items, {id = "bomb", sp = 224, x = 16, y = 10} )
	add(items, {id = "bomb", sp = 224, x = 70, y = 80} )
	--spawn bombs for testing
	add(items, {id = "key", sp = 243, x = 30, y = 15} )
	add(items, {id = "key", sp = 243, x = 75, y = 90} )
	add(items, {id = "key", sp = 243, x = 40, y = 15} )
	add(items, {id = "key", sp = 243, x = 85, y = 90} )
end --end init

--update
function _update()
	timers()
	
	if game_state == "intro" then
		intro_screen_update()
				
		--music
		if time() > 0.2 then
			play_song_of_healing()
		end
	end
	
	if game_state == "title_screen" then
	end
	
	if game_state == "game_start" then
		update_dir_input()
		update_b_input()
		enemy_take_bomb_dmg()
		update_active_bomb()
		deploy_bomb()
		player_move()
		get_player_hitbox()
		update_enemies()
		player_collision()
		player_attack()
		get_player_att_hitbox()
		calc_hp_sprites()
		collect_item()
		
		--sfx
		bomb_sfx()
		
		--music
		if time() > 0.2 then
			--play_song_of_healing()
		end
	end
end

--draw
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

function collision(r1, r2)
	--inclusive collision
	--r1,r2={x1,y1,x2,y2}
	--note: player collision with
	--walls is handled elsewhere

	return not (
		r1.x2<r2.x1 or
		r1.x1>r2.x2 or
		r1.y2<r2.y1 or
		r1.y1>r2.y2
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
		circfill(bomb_coord.x + 3, bomb_coord.y + 4, bomb_explode_r, 7 + global_timer%2)
	end
end

function in_circle(x, y, cx, cy, r)
	--x,y=point to be tested
	--cx,cy=center of circ
	--r=rad of circ
	local dx = x - cx
	local dy = y - cy
	
	return dx*dx + dy*dy <= r*r
end

--player functions
function player_move()
	--input handling
	local d = get_priority_dir()
	
    --basic movement vars
	local cm = can_move()
	local left_ok = cm.left
	local right_ok = cm.right
	local up_ok = cm.up
	local down_ok = cm.down
	
    --soft edge variables
	local soft_edge_px = 6      --can't be > 6
	local soft_edge_spd = 1
	
	--calculate distance to nearest edge. 
    --if sprite is perfectly within a tile, all of these should equal 0.
	local dist_top = p.y%8
    local dist_bot = 7 - ((p.y + 7)%8)
    local dist_left=p.x%8
    local dist_right=7 - ((p.x + 7)%8)
	
	--if not attackig,
	--process move inputs
	if not p.att then
		--move left
		if d == "left" then
			p.dir = "left"
			p.f = true
			p.sp = (p.anim_timer%4) + 1
			
            if left_ok then
				p.x -= p.spd
			else
				--soft corner detect & move
				--clear top edge
				if dist_top <= soft_edge_px and dist_top > 0 and not is_blocked_at(p.x - 1, p.y) then
					--nudge up to clear edge
					p.y-=1
				end
				--clear bottom edge
				if dist_bot <= soft_edge_px and dist_bot > 0 and not is_blocked_at(p.x - 1, p.y + 7) then
					--nudge down to clear edge
					p.y += 1
				end
			end
		
        elseif d == "right" then
			p.dir = "right"
			p.f = false
			p.sp = (p.anim_timer%4) + 1
			
            if right_ok then
				p.x += p.spd
			else
				--soft edge detect & move
				--clear top edge
				if dist_top <= soft_edge_px and dist_top > 0 and not is_blocked_at(p.x + 8, p.y) then
					--nudge up to clear edge
					p.y -= 1
				end
				--clear bottom edge
				if dist_bot <= soft_edge_px and dist_bot > 0 and not is_blocked_at(p.x + 8, p.y + 7) then
					--nudge down to clear edge
					p.y += 1
				end
			end
		
        elseif d == "up" then
			p.dir = "up"
			p.f = false
			p.sp = (p.anim_timer%4) + 32
			
            if up_ok then
				p.y-=p.spd
			else
			 --soft edge detect & move
				--clear right edge
				if dist_right <= soft_edge_px and dist_right > 0 and not is_blocked_at(p.x + 8, p.y - 1) then
					--nudge rigjt
					p.x += 1
				end
				--clear left edge
				if dist_left <= soft_edge_px and dist_left > 0 and not is_blocked_at(p.x, p.y - 1) then
					--nudge left
					p.x -= 1
				end
			end
		
        elseif d == "down" then
		    p.dir = "down"
		    p.f = false
		    p.sp = (p.anim_timer%4) + 16
		    
            if down_ok then
			    p.y += p.spd
			else
			 --soft edge detect & move
				--clear right edge
				if dist_right <= soft_edge_px and dist_right > 0 and not is_blocked_at(p.x + 8, p.y + 8) then
					--nudge rigjt
					p.x += 1
				end
				--clear left edge
				if dist_left <= soft_edge_px and dist_left > 0 and not is_blocked_at(p.x, p.y + 8) then
					--nudge left
					p.x -= 1
				end
			end
		end
		
		--if not moving
		if btn() == 0 then
			if p.dir == "left" then 
				p.sp = 1
				p.f = true
			end
			if p.dir == "right" then
				p.sp = 1
				p.f = false
			end
			if p.dir == "up" then
				p.sp = 32
			end
			if p.dir == "down" then
				p.sp = 16
			end
		end
	end
end

function player_attack()
	if p.att_count > 0 then
	--attack in progress
		p.att_count -= 1
		if p.att_count == 0 then
			--attack finished - 
			--start cooldown
			p.att_delay_count = p.att_delay
		end
	else
		p.att = false
	end
	
	--check cooldown
	if p.att_delay_count > 0 then
		p.att_delay_count -= 1	
	end
	
	if check_att_input() and p.att_count == 0 and p.att_delay_count == 0 then
        sfx(0, 3)
        p.att = true
        p.att_count = p.att_time
        if p.dir == "right" then
            p.sp = 4
            p.att_sp = 48
            p.att_x = p.x + 6
            p.att_y = p.y + 2
            p.att_f = false
        elseif p.dir == "left" then
            p.sp = 4
            p.att_sp = 48
            p.att_x = p.x - 6
            p.att_y = p.y + 2
            p.att_f = true
        elseif p.dir == "up" then
            p.sp = 35
            p.att_sp = 49
            p.att_x = p.x
            p.att_y = p.y - 6
            p.att_f = false
        elseif p.dir == "down" then
            p.sp = 17
            p.att_sp = 50
            p.att_x = p.x
            p.att_y = p.y + 6
            p.att_f = false
        end
	end
end

function can_move()
	--if token space becomes an
	--issue, optimize this
	local tile_x1
	local tile_x2
	local tile_y1
	local tile_y2
	local tile_sp_1
	local tile_sp_2
	local result = {left = true, right = true, up = true, down = true}
	
	--check tile to the right
	tile_x1 = flr((p.x + 8)/8)
	tile_y1 = flr(p.y/8)
	tile_y2 = flr((p.y + 7)/8)
	tile_sp_1 = mget(tile_x1, tile_y1)
	tile_sp_2 = mget(tile_x1, tile_y2)
	
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) then
 	    result.right = true
    else
 	    result.right = false
	end
	
	--check tile to the left
	tile_x1 = flr((p.x - 1)/8)
	tile_sp_1 = mget(tile_x1, tile_y1)
	tile_sp_2 = mget(tile_x1, tile_y2)
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) then
 	    result.left=true
    else
 	    result.left=false
	end
	
	--check tile up
	tile_x1 = flr(p.x/8)
	tile_x2 = flr((p.x + 7)/8)
	tile_y1 = flr((p.y - 1)/8)
	tile_sp_1 = mget(tile_x1, tile_y1)
	tile_sp_2 = mget(tile_x2, tile_y1)
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) then
 	    result.up = true
    else
 	    result.up = false
	end
	
	--check tile down
	tile_y1 = flr((p.y + 8)/8)
	tile_sp_1 = mget(tile_x1, tile_y1)
	tile_sp_2 = mget(tile_x2, tile_y1)
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) then
     	result.down = true
    else
 	    result.down = false
	end
	
	return result
end --can_move()

function draw_player()
	--draw player
	spr(p.sp, p.x, p.y, 1, 1, p.f)

	--player hitbox	
	if display_hitbox == true then
		--take damage hitbox
		color(14)
		if p.dir == "right" then
			rect(p.x + 3, p.y + 1, p.x + 5, p.y + 6)
		elseif p.dir == "left" then
			rect(p.x + 2, p.y + 1, p.x + 4, p.y + 6)
		else
			rect(p.x + 2, p.y + 1, p.x + 5, p.y + 6)
		end--end take damage hitbox
		--movement hitbox
		color(12)
		rect(p.x, p.y, p.x + 7, p.y + 7)
	end--end player hitbox

	--draw sword attack
	if p.att == true then
		spr(p.att_sp, p.att_x, p.att_y, 1, 1, p.att_f)
		
		--display att hitbox
		if display_hitbox == true then
			color(8)
			if p.dir == "right" then
				rect(p.att_x + 2, p.att_y + 2, p.att_x + 7, p.att_y + 4)
			end
			if p.dir == "left" then
				rect(p.att_x, p.att_y + 2, p.att_x + 5, p.att_y + 4)
			end
			if p.dir == "up" then
				rect(p.att_x + 4, p.att_y, p.att_x + 6, p.att_y + 5)
			end
			if p.dir=="down" then
				rect(p.att_x + 1, p.att_y + 2, p.att_x + 3, p.att_y + 7)
			end
		end--end display att hitbox
	end--end player attack update
end--end draw_player()

function calc_hp_sprites()
	local sp_num = ceil(p.hp_max)
	local xs = 1 --x start
	local ys = 1 --y start
	local hp_sp --sprite to draw
	
	--clear current table data
	p.hp_sp_coords = {}
	
	--add new table data
	for i = 1, sp_num, 1 do
		if p.hp < i and p.hp > i - 1 then
			hp_sp = p.hp_sp_half
		elseif p.hp >= i then
			hp_sp = p.hp_sp_full
		else
			hp_sp = p.hp_sp_empty
		end
		
		add(p.hp_sp_coords, {sp = hp_sp, x = (i - 1)*6 + xs, y = ys} )
	end
end --calc_hp_sprites()

function draw_player_hp()
	for s in all(p.hp_sp_coords) do
		spr(s.sp, s.x, s.y)
	end
end

function get_player_hitbox()
	if p.dir == "left" then
		p.hb = {x1 = 2, y1 = 1, x2 = 4, y2 = 6}
	elseif p.dir == "right" then
		p.hb = {x1 = 3, y1 = 1, x2 = 5, y2 = 6}
	else
		p.hb = {x1 = 2, y1 = 1, x2 = 5, y2 = 6}
	end

	p.hb.x1 += p.x
	p.hb.x2 += p.x
	p.hb.y1 += p.y
	p.hb.y2 += p.y
end

function get_player_att_hitbox()
	if p.att then
		if p.dir == "right" then
			p.att_hb = {x1 = 2, y1 = 2, x2 = 7, y2 = 4}
		end
		if p.dir == "left" then
			p.att_hb = {x1 = 0, y1 = 2, x2 = 5, y2 = 4}
		end
		if p.dir == "up" then
			p.att_hb = {x1 = 4, y1 = 0, x2 = 6, y2 = 5}
		end
		if p.dir == "down" then
			p.att_hb = {x1 = 1, y1 = 2, x2 = 3, y2 = 7}
		end

		p.att_hb.x1 += p.att_x
		p.att_hb.x2 += p.att_x
		p.att_hb.y1 += p.att_y
		p.att_hb.y2 += p.att_y
	else --if not p.att 
		p.att_hb = nil
	end --end of if p.att
end

function player_collision()
	--player takes damage if
	--collision with enemy detected
	for e in all(enemies) do
		if e.hb_cur ~= nil then
			
			--player collision with enemy
			if collision(p.hb, e.hb_cur) then
				if p.i_frame_count == 0 then
					sfx(5)
					p.hp -= 0.5
					p.i_frame_count = p.i_frame_max				
				end --i frame check
			end --p collision w/ enemy
			
			--sword collison with enemy
			if p.att_hb ~= nil and p.att_count == p.att_time then
				--att_hb exists, and on first frame of attack
				if collision(p.att_hb, e.hb_cur) then
					e.hp -= 1
					if e.hp == 0 then
						--death sfx
						if e.id == "bat" then
							sfx(3)
						end
						del(enemies, e)
					end
				end
			end
		end --enemy hb~=nil		
	end --loop through enemies[]
end --player_collision()

function collect_item()
	local box
	
	for i in all(items) do
		--if rupee
		if i.id == "rp_g" or i.id=="rp_b" or i.id=="rp_r" then
			--replace this with an extra variable in items[]?
            box = {
				x1 = i.x + hb_dims.rupee.x1,
				y1 = i.y + hb_dims.rupee.y1,
				x2 = i.x + hb_dims.rupee.x2,
				y2 = i.y + hb_dims.rupee.y2
			}

			if collision(p.hb, box) then
				if p.rupees + rupee_val[i.id] <= p.max_rupees then
					sfx(2)
					p.rupees += rupee_val[i.id]
					del(items, i)
				elseif p.rupees ~= p.max_rupees and p.rupees + rupee_val[i.id] >= p.max_rupees then
					sfx(2)
					p.rupees = p.max_rupees
					del(items, i)
				end
			end
		end--rupees
		--bombs

		if i.id == "bomb" then
			box = {
				x1 = i.x + hb_dims.bomb.x1,
				y1 = i.y + hb_dims.bomb.y1,
				x2 = i.x + hb_dims.bomb.x2,
				y2 = i.y + hb_dims.bomb.y2
			}

			if collision(p.hb, box) then
				if p.bombs < p.max_bombs then
					sfx(4)
					p.bombs += 1
					del(items, i)
				end
			end
		end --bombs
		
        --keys
		if i.id == "key" then
			box = {
				x1 = i.x + hb_dims.key.x1,
				y1 = i.y + hb_dims.key.y1,
				x2 = i.x + hb_dims.key.x2,
				y2 = i.y + hb_dims.key.y2
			}

			if collision(p.hb, box) then
				if p.keys < p.max_keys then
					sfx(6)
					p.keys += 1
					del(items, i)
				end
			end
		end --keys
	end--loop items
end

function update_b_input()
	b_prev_held = b_held
	b_held = btn(4)
end --update_b_input()

function deploy_bomb()
	if not b_prev_held and b_held and not bomb_active and not bomb_explode and p.bombs > 0 then
		p.bombs -= 1
		bomb_active = true
		bomb_timer = bomb_timer_start
		
        if p.dir == "left" then
			bomb_coord = {x = p.x - 4, y = p.y + 1}
		elseif p.dir == "right" then
			bomb_coord = {x = p.x + 6, y = p.y + 1}
		elseif p.dir == "up" then
			bomb_coord = {x = p.x + 1, y = p.y - 6}
		elseif p.dir == "down" then
			bomb_coord = {x = p.x + 1, y = p.y + 6}
		end
	end
end

function player_in_bomb_dmg()
end

--enemy functions
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

--***************
--sfx and music
--***************

--sfx functions
function bomb_sfx()
	if bomb_explode_time == bomb_explode_time_start - 1 then
		sfx(8)
	end
end

--music
function play_song_of_healing()
	--track 1
		--also includes timing update
	if stat(16) == -1 and stat(17) == -1 then
		if soh_pos <= #soh.track1 then
			sfx(soh.track1[soh_pos], 0)
		end
	end --track 1

	--track 2
	if stat(17) == -1 then
		if soh_pos <= #soh.track1 then
			sfx(soh.track2[soh_pos], 1)
			soh_pos += 1
		else
			soh_pos = 1
		end
	end	--track 2
end --song of healing