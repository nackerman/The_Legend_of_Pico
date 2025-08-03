--**********************************
--note regarding sprite flags:
--f0: inhibits player move
--f1: damage player on contact
--f2: player can collect item
--**********************************
	
function _init()
    display_hitbox = false
    display_cpu_usage = true

    game_mode = "normal" --"normal" or "endless demo"
	--game_mode = "endless_demo"
	game_state = "game_start"
	global_timer = 0

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
		att_f,
		spd = 1,
		dir = "right",
		att = false,
		att_time = 10,
		att_count = 0,
		att_delay = 5,
		att_delay_count = 0,
		att_held_prev = false,
		att_hb,
		hp = 0.5,
		hp_max = 3,
		hp_true_max = 10,
		hp_sp_full = 192,
		hp_sp_half = 193,
		hp_sp_empty = 194,
		hp_sp_array = {},
		hb = {},                    --hitbox={x1,y1,x2,y2}
		i_frame_max = 15,
		i_frame_count = 0,
		rupees = 0,
		max_rupees = 200,
		bombs = 9,
		max_bombs = 9,
		bomb_dmg_taken = false,
		keys = 0,
		max_keys = 3,
		is_aligned_with_door = "none",
		is_dead = false,
		time_of_death
	}

	--directional buttons
	dir = {
		btns = {
			["left"]    = 0,
			["right"]   = 1,
			["up"]      = 2,
			["down"]    = 3
		},
		priority = {
			["left"]    = -1,
			["right"]   = -1,
			["up"]      = -1,
			["down"]    = -1
		},
		held = {
			["left"]    = false,
			["right"]   = false,
			["up"]      = false,
			["down"]    = false
		},
		prev_held = {
			["left"]    = false,
			["right"]   = false,
			["up"]      = false,
			["down"]    = false
		},
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
	bomb_explode_r = 10
	bomb_explode_time = 0
	bomb_explode_time_start = 30
	door_bombed = false
	
	items = {} --{id,sp,x,y}

	rupee_val = {
		rp_g = 1,
		rp_b = 5,
		rp_r = 20
	}
	
	bomb_coord_sp = { x, y }
	bomb_coord_center = { x, y }

	--enemy variables
	enemies = {} 
		--{
			--{
			--id,  				--id, i.e., "bat"
			--sp, 				--sprite number
			--x, 				--sprite x positon
			--y, 				--sprite y position
			--x_next,			--desired next x pos
			--y_next,			--desired next y pos
			--hp, 				--health
			--hb_dims, 			--hitbox dimensions
			--hb_cur, 			--current hitbox dimensions (relative to location)
			--sword_dmg_taken	--has enemy taken sword damage from current sword attack?
			--bomb_dmg_taken	--has enemy taken bomb damage for this bomb cycle?
			--}
		--}
	npc_anim_timer = 0
	npc_anim_delay = 6
	
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

		bomb = { --item, not active bomb or explosion
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

	m_offset_template = {16,0}
	m_offset_active = {32,0}
	m_offset_next = {48,0}
	if game_mode == "endless_demo" then m_offset_active = {0,0} end

	door_tile_loc = {
		left = {
			t1 = {0, 7},
			t2 = {1, 7},
			b1 = {0, 8},
			b2 = {1, 8}
		},
		right = {
			t1 = {14, 7},
			t2 = {15, 7},
			b1 = {14, 8},
			b2 = {15, 8}
		},
		up = {
			t1 = {7, 2},
			t2 = {8, 2},
			b1 = {7, 3},
			b2 = {8, 3}
		},
		down = {
			t1 = {7, 12},
			t2 = {8, 12},
			b1 = {7, 13},
			b2 = {8, 13}
		}
	}

	door_hb = {
		left = {x1 = 15, y1 = 56, x2 = 16, y2 = 71},
		right = {x1 = 111, y1 = 56, x2 = 112, y2 = 71},
		up = {x1 = 56, y1 = 31, x2 = 71, y2 = 32},
		down = {x1 = 56, y1 = 95, x2 = 71, y2 = 96}
	}

	door_scroll_hb = {
		left = {x1 = 15, y1 = 60, x2 = 16, y2 = 67},
		right = {x1 = 111, y1 = 60, x2 = 112, y2 = 67},
		up = {x1 = 60, y1 = 31, x2 = 67, y2 = 32},
		down = {x1 = 60, y1 = 95, x2 = 67, y2 = 96}
	}

	if game_mode == "endless_demo" then
		door_hb, door_scroll_hb = {}
	end

	door_align = {
		left  = {axis = "y", sign = 1},
		right = {axis = "y", sign = 1},
		up    = {axis = "x", sign = 1},
		down  = {axis = "x", sign = 1}
	}

	door_sp = {
		left = {
			locked = {
				t1 = 68,
				t2 = 69,
				b1 = 84,
				b2 = 85
			},
			open = {
				t1 = 72,
				t2 = 73,
				b1 = 88,
				b2 = 89
			},
			secret_closed = {
				t1 = 76,
				t2 = 77,
				b1 = 92,
				b2 = 93
			},
			secret_open = {
				t1 = 204,
				t2 = 205,
				b1 = 220,
				b2 = 221
			},
			wall = {
				t1 = 160,
				t2 = 162,
				b1 = 160,
				b2 = 162
			}
		},
		right = {
			locked = {
				t1 = 70,
				t2 = 71,
				b1 = 86,
				b2 = 87
			},
			open = {
				t1 = 74,
				t2 = 75,
				b1 = 90,
				b2 = 91
			},
			secret_closed = {
				t1 = 78,
				t2 = 79,
				b1 = 94,
				b2 = 95
			},
			secret_open = {
				t1 = 206,
				t2 = 207,
				b1 = 222,
				b2 = 223
			},
			wall = {
				t1 = 163,
				t2 = 165,
				b1 = 163,
				b2 = 165
			}
		},
		up = {
			locked = {
				t1 = 100,
				t2 = 101,
				b1 = 116,
				b2 = 117
			},
			open = {
				t1 = 104,
				t2 = 105,
				b1 = 120,
				b2 = 121
			},
			secret_closed = {
				t1 = 108,
				t2 = 109,
				b1 = 124,
				b2 = 125
			},
			secret_open = {
				t1 = 236,
				t2 = 237,
				b1 = 252,
				b2 = 253
			},
			wall = {
				t1 = 188,
				t2 = 188,
				b1 = 190,
				b2 = 190
			}
		},
		down = {
			locked = {
				t1 = 102,
				t2 = 103,
				b1 = 118,
				b2 = 119
			},
			open = {
				t1 = 106,
				t2 = 107,
				b1 = 122,
				b2 = 123
			},
			secret_closed = {
				t1 = 110,
				t2 = 111,
				b1 = 126,
				b2 = 127
			},
			secret_open = {
				t1 = 238,
				t2 = 239,
				b1 = 254,
				b2 = 255
			},
			wall = {
				t1 = 190,
				t2 = 190,
				b1 = 172,
				b2 = 172
			}
		},
	}
	
	room_current = "0,0"
	room_next = nil
	room_transition = false
	active_room_configured = false
	room_vignette_close_complete = false
	room_vignette_open_complete = false

	room_defs = {
		["0,0"] = {
			type = "floor_start",
			active = true,
			next = false,
			explored = true,
			num_keys = 1,
			doors = {
				left = "open",
				right = "wall",
				up = "secret_closed",
				down = "wall"
			},
			terrain_config = {},
			enemies = {}
		},
		["-1,0"] = {
			type = "combat",
			active = true,
			next = false,
			explored = true,
			num_keys = 1,
			doors = {
				left = "wall",
				right = "open",
				up = "wall",
				down = "wall"
			},
			terrain_config = {},
			enemies = {}
		},
		["0,-1"] = {
			type = "combat",
			active = true,
			next = false,
			explored = true,
			num_keys = 1,
			doors = {
				left = "wall",
				right = "wall",
				up = "wall",
				down = "secret_open"
			},
			terrain_config = {},
			enemies = {}
		}
	}

	--music
	--song of healing
	soh_pos = 1 --time tracking
	soh = {
		track1 = {32, 32, 33, 34, 35, 36, 35, 37},
		track2 = {38, 38, 39, 39, 40, 41, 40, 42},
	}

	radius_outer_death_vignette = 150
	radius_inner_death_vignette = 120
	radius_outer_death_vignette_min = 30
	radius_inner_death_vignette_min = 12

	radius_room_trans_vignette = 120

	--testing
	--test = "false"
	--end test

end --end init