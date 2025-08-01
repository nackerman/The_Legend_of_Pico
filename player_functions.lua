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
    local dist_left = p.x%8
    local dist_right = 7 - ((p.x + 7)%8)
	
	--if not attacking,
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
		for e in all(enemies) do
			e.sword_dmg_taken = false
		end
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
	tile_sp_1 = mget(tile_x1 + m_offset_active[1], tile_y1 + m_offset_active[2])
	tile_sp_2 = mget(tile_x1 + m_offset_active[1], tile_y2 + m_offset_active[2])
	
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) and p.x < 120 then
 	    result.right = true
    else
 	    result.right = false
	end
	
	--check tile to the left
	tile_x1 = flr((p.x - 1)/8)
	tile_sp_1 = mget(tile_x1 + m_offset_active[1], tile_y1 + m_offset_active[2])
	tile_sp_2 = mget(tile_x1 + m_offset_active[1], tile_y2 + m_offset_active[2])
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) and p.x > 0 then
 	    result.left=true
    else
 	    result.left=false
	end
	
	--check tile up
	tile_x1 = flr(p.x/8)
	tile_x2 = flr((p.x + 7)/8)
	tile_y1 = flr((p.y - 1)/8)
	tile_sp_1 = mget(tile_x1 + m_offset_active[1], tile_y1 + m_offset_active[2])
	tile_sp_2 = mget(tile_x2 + m_offset_active[1], tile_y1 + m_offset_active[2])
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) and p.y > 8 then
 	    result.up = true
    else
 	    result.up = false
	end
	
	--check tile down
	tile_y1 = flr((p.y + 8)/8)
	tile_sp_1 = mget(tile_x1 + m_offset_active[1], tile_y1 + m_offset_active[2])
	tile_sp_2 = mget(tile_x2 + m_offset_active[1], tile_y1 + m_offset_active[2])
	if not fget(tile_sp_1, 0) and not fget(tile_sp_2, 0) and p.y < 120 then
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

function calc_hp_sprites() --calc hearts to display in the UI
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

function draw_player_hp() --draw hearts in the UI
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
				if collision(p.att_hb, e.hb_cur) and not e.sword_dmg_taken then
					e.hp -= 1
					e.sword_dmg_taken = true
					if e.hp <= 0 then
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

function player_take_bomb_dmg()
	if bomb_explode then
		if hitbox_in_bomb_r(p.hb) then
			p.hp -= 1
			sfx(5)
		end
	end
end

function is_player_dead()
	if p.hp <= 0 then 
        if p.is_dead == false then
            p.time_of_death = time()
            p.is_dead = true
			i_frame_count = 0
        end
        return true
    else 
        return false 
    end
end

function calculate_player_death_vignettes()
	if radius_outer_death_vignette >= radius_outer_death_vignette_min then
		radius_outer_death_vignette -= 5
	end
	
	if radius_inner_death_vignette >= radius_inner_death_vignette_min then
		radius_inner_death_vignette -= 5
	end
end