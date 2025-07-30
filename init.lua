--**********************************
--note regarding sprite flags:
--f0: inhibits player move
--f1: damage player on contact
--f2: player can collect item
--**********************************
	
function _init()
    --debug
    display_hitbox = false
    
    --initialize game state and global timer
    game_mode = "endless_demo"
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
		bombs = 3,
		max_bombs = 3,
		keys = 0,
		max_keys = 3,
		is_dead = false,
		time_of_death
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
		},
		--directional vectors - currently used in move_enemies()
		vec = {
			left = 	{ -1, 0 },
			right = { 1, 0 },
			up = 	{ 0, -1 },
			down =	{ 0, 1 },
			none =	{ 0, 0 } 
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
	enemies = {} 
		--{
			--id,  				--id, i.e., "bat"
			--sp, 				--sprite number
			--x, 				--sprite x positon
			--y, 				--sprite y position
			--hp, 				--health
			--hb_dims, 			--hitbox dimensions
			--hb_cur, 			--current hitbox dimensions (relative to location)
			--sword_dmg_taken	--has enemy taken sword damage from current sword attack?
			--bomb_dmg_taken	--has enemy taken bomb damage for this bomb cycle?
		--}
	npc_anim_timer = 0
	npc_anim_delay = 6
	
	--useful for spawning in a random enemy type
	enemy_type_def = {
		{	--bat
			key = 1, 
			id = "bat",
			sp = 64,
			hp_start = 1,
			hb_dims = {
				x1 = 1,
				y1 = 1,
				x2 = 5,
				y2 = 3
			}
		},
		
		{	--slime
			key = 3,
			id = "slime",
			sp = 80,
			hp_start = 2,	
			hb_dims = {
				x1 = 0,
				y1 = 0,
				x2 = 7,
				y2 = 7
			}
		},
		{	--skeleton
			key = 2,
			id = "skeleton",
			sp = 96,
			hp_start = 3,
			hb_dims = {
				x1 = 0,
				y1 = 0,
				x2 = 7,
				y2 = 7
			}
		},
	}

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


	--death screen vignette
	radius_outer_death_vignette = 110
	radius_inner_death_vignette = 90
	radius_outer_death_vignette_min = 30
	radius_inner_death_vignette_min = 12
	
	--add(enemies, {id = "bat", sp = 64, x = 38, y = 38, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )	
	--spawn some bats for testing
	--add(enemies, {id = "bat", sp = 64, x = 38, y = 38, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )	
	--add(enemies, {id = "bat", sp = 65, x = 32, y = 32, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )
	--add(enemies, {id = "bat", sp = 64, x = 20, y = 40, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )
	--add(enemies, {id = "bat", sp = 64, x = 80, y = 50, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )	
	--add(enemies, {id = "bat", sp = 65, x = 90, y = 60, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )
	--add(enemies, {id = "bat", sp = 64, x = 80, y = 60, hp = 1, hb_dims = enemy_type_def[1].hb_dims, hb_cur = {} } )

	--spawn some rupees for testing
	--add(items, {id = "rp_g", sp = 240, x = 20, y = 30} )
	--add(items, {id = "rp_g", sp = 240, x = 35, y = 50} )
	--add(items, {id = "rp_b", sp = 241, x = 37, y = 60} )
	--add(items, {id = "rp_r", sp = 242, x = 40, y = 70} )
	
	--spawn bombs for testing
	--add(items, {id = "bomb", sp = 224, x = 5, y = 10} )
	--add(items, {id = "bomb", sp = 224, x = 80, y = 80} )
	--add(items, {id = "bomb", sp = 224, x = 5, y = 20} )
	--add(items, {id = "bomb", sp = 224, x = 80, y = 90} )
	--add(items, {id = "bomb", sp = 224, x = 16, y = 10} )
	--add(items, {id = "bomb", sp = 224, x = 70, y = 80} )
	--spawn bombs for testing
	--add(items, {id = "key", sp = 243, x = 30, y = 15} )
	--add(items, {id = "key", sp = 243, x = 75, y = 90} )
	--add(items, {id = "key", sp = 243, x = 40, y = 15} )
	--add(items, {id = "key", sp = 243, x = 85, y = 90} )
end --end init