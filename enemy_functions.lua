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
		key = abs(ceil(rnd(1))) --just bats, for now

		add(enemies, 
				{	
					id = enemy_type_def[key].id,
					sp = 64, x = rnd(127),
					y = rnd(127),
					hp = enemy_type_def[key].hp_start,
					hb_dims = enemy_type_def[key].hb_dims,
					hb_cur = {},
					sword_dmg_taken = false
				}
			)
	end
end