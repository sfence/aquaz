--
-- Aquaz
--

aquaz = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

-- internationalization boilerplate
local S = minetest.get_translator("aquaz")

local function plant_on_place(itemstack, placer, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" and placer and not placer:get_player_control().sneak then
		local node_ptu = minetest.get_node(pointed_thing.under)
		local def_ptu = minetest.registered_nodes[node_ptu.name]
		if def_ptu and def_ptu.on_rightclick then
			return def_ptu.on_rightclick(pointed_thing.under, node_ptu, placer,
				itemstack, pointed_thing)
		end
	end

	local pos = pointed_thing.under
	if minetest.get_node(pos).name ~= "hades_default:sand" then
		return itemstack
	end
	local pos_top = {x = pos.x, y = pos.y + 0.99, z = pos.z}
	local node_top = minetest.get_node(pos_top)
	local def_top = minetest.registered_nodes[node_top.name]
	local player_name = placer:get_player_name()

	if def_top and def_top.liquidtype == "source" and
			minetest.get_item_group(node_top.name, "water") > 0 then
		if not minetest.is_protected(pos, player_name) and
				not minetest.is_protected(pos_top, player_name) then
			minetest.set_node(pos, {name = itemstack:get_name()})
			if not (creative and creative.is_enabled_for
					and creative.is_enabled_for(player_name)) then
				itemstack:take_item()
			end
		else
			minetest.chat_send_player(player_name, S("Node is protected"))
			minetest.record_protection_violation(pos, player_name)
		end
	end
	return itemstack
end

local function kelp_on_place(itemstack, placer, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" and placer and not placer:get_player_control().sneak then
		local node_ptu = minetest.get_node(pointed_thing.under)
		local def_ptu = minetest.registered_nodes[node_ptu.name]
		if def_ptu and def_ptu.on_rightclick then
			return def_ptu.on_rightclick(pointed_thing.under, node_ptu, placer,
				itemstack, pointed_thing)
		end
	end

	local pos = pointed_thing.under
	if minetest.get_node(pos).name ~= "hades_default:sand" then
		return itemstack
	end

	local height = 1--math.random(4, 6)
	local pos_top = {x = pos.x, y = pos.y + math.ceil(height/16), z = pos.z}
	local node_top = minetest.get_node(pos_top)
	local def_top = minetest.registered_nodes[node_top.name]
	local player_name = placer:get_player_name()

	if def_top and def_top.liquidtype == "source" and
			minetest.get_item_group(node_top.name, "water") > 0 then
		if not minetest.is_protected(pos, player_name) and
				not minetest.is_protected(pos_top, player_name) then
			minetest.set_node(pos, {name = itemstack:get_name(),
				param2 = height})
			if not (creative and creative.is_enabled_for
					and creative.is_enabled_for(player_name)) then
				itemstack:take_item()
			end
		else
			minetest.chat_send_player(player_name, S("Node is protected"))
			minetest.record_protection_violation(pos, player_name)
		end
	else
		 minetest.chat_send_player(player_name, "Missing water source above sand.")
	end
	return itemstack
end
local function kelp_after_dig_node(pos, oldnode, oldmetadata, digger)
	local height = math.ceil(oldnode.param2/16)
	if height>1 then
		local itemstack = ItemStack(oldnode.name)
		itemstack:set_count(height-1)
		local inv = digger:get_inventory()
		itemstack = inv:add_item("main", itemstack)
		if itemstack:get_count()>0 then
			minetest.add_item(pos, itemstack)
		end
	end
end

local function coral_on_place(itemstack, placer, pointed_thing, coral_name, coral_base)
	if pointed_thing.type ~= "node" or not placer then
		return itemstack
	end

	local player_name = placer:get_player_name()
	local pos_under = pointed_thing.under
	local pos_above = pointed_thing.above

	if minetest.get_node(pos_under).name ~= coral_base or
			minetest.get_node(pos_above).name ~= "hades_core:water_source" then
		return itemstack
	end

	if minetest.is_protected(pos_under, player_name) or
			minetest.is_protected(pos_above, player_name) then
		minetest.chat_send_player(player_name, "Node is protected")
		minetest.record_protection_violation(pos_under, player_name)
		return itemstack
	end

	local param2 = minetest.dir_to_wallmounted(vector.subtract(pos_under, pos_above), true)
	minetest.set_node(pos_under, {name = coral_name, param2 = param2})
	if not (minetest.is_creative_enabled(player_name)) then
		itemstack:take_item()
	end

	return itemstack
end

local function algae_on_place(itemstack, placer, pointed_thing)
	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" and placer and not placer:get_player_control().sneak then
		local node_ptu = minetest.get_node(pointed_thing.under)
		local def_ptu = minetest.registered_nodes[node_ptu.name]
		if def_ptu and def_ptu.on_rightclick then
			return def_ptu.on_rightclick(pointed_thing.under, node_ptu, placer,
				itemstack, pointed_thing)
		end
	end

	local pos = pointed_thing.under
	if minetest.get_node(pos).name ~= "hades_core:water_source" then
		return itemstack
	end

	local pos_top = {x = pos.x, y = pos.y + 1, z = pos.z}
	local node_top = minetest.get_node(pos_top)
	local def_top = minetest.registered_nodes[node_top.name]
	local player_name = placer:get_player_name()

	if def_top and def_top.buildable_to and def_top.liquidtype == "none" then
		if not minetest.is_protected(pos, player_name) and
				not minetest.is_protected(pos_top, player_name) then
			minetest.set_node(pos_top, {name = itemstack:get_name(), param2 = minetest.dir_to_facedir(vector.subtract(pos, pointed_thing.above))})
			if not (creative and creative.is_enabled_for
					and creative.is_enabled_for(player_name)) then
				itemstack:take_item()
			end
		else
			minetest.chat_send_player(player_name, S("Node is protected"))
			minetest.record_protection_violation(pos, player_name)
		end
	else
		 minetest.chat_send_player(player_name, "Missing buildable_to node above water source.")
	end
	return itemstack
end

--
-- Nodes
--

aquaz.corals_base = {
	{
			name = "hades_aquaz:rhodophyta_base",
			description= "Rhodophyta Coral",
			tiles = "aquaz_rhodophyta_base",
	},
	{
		name = "hades_aquaz:psammocora_base",
		description= "Psammocora Coral",
		tiles = "aquaz_psammocora_base",
	},
	{
		name = "hades_aquaz:sarcophyton_base",
		description= "Sarcophyton Coral",
		tiles = "aquaz_sarcophyton_base",
	},
	{
		name = "hades_aquaz:carnation_base",
		description= "Carnation Coral",
		tiles = "aquaz_carnation_base",
	},
	{
		name = "hades_aquaz:fiery_red_base",
		description= "Fiery Red Coral",
		tiles = "aquaz_fiery_red_base",
	},
	{
		name = "hades_aquaz:acropora_base",
		description= "Acropora Coral",
		tiles = "aquaz_acropora_base",
	},
}

for _, base in pairs(aquaz.corals_base) do
	minetest.register_node(base.name, {
		description = S(base.description).." "..S("Block"),
		short_description = S(base.description).." "..S("Block"),
		tiles = {base.tiles..".png"},
		walkable = true,
		groups = {cracky = 3, coral_live = 1, coral_block_growing = 1},
		drop = base.name.."_skeleton",
		sounds = hades_sounds.node_sound_leaves_defaults(),
	})
	minetest.register_node(base.name.."_skeleton", {
		description = S(base.description).." "..S("Skeleton"),
		short_description = S(base.description).." "..S("Skeleton"),
		tiles = {base.tiles.."_skeleton.png"},
		walkable = true,
		groups = {cracky = 3, coral_block_skeleton = 1},
		sounds = hades_sounds.node_sound_leaves_defaults(),
	})
end

aquaz.corals = {
	{
	name = "hades_aquaz:rhodophyta",
	base = "hades_aquaz:rhodophyta_base",
	base_skeleton = "hades_aquaz:rhodophyta_base_skeleton",
	description = "Rhodophyta Coral",
	special_tiles = "aquaz_rhodophyta_top",
	},
	{
	name = "hades_aquaz:psammocora",
	base = "hades_aquaz:psammocora_base",
	base_skeleton = "hades_aquaz:psammocora_base_skeleton",
	description = "Psammocora Coral",
	special_tiles = "aquaz_psammocora_top",
	},
	{
	name = "hades_aquaz:sarcophyton",
	base = "hades_aquaz:sarcophyton_base",
	base_skeleton = "hades_aquaz:sarcophyton_base_skeleton",
	description = "Sarcophyton Coral",
	special_tiles = "aquaz_sarcophyton_top",
	},
	{
	name = "hades_aquaz:carnation",
	base = "hades_aquaz:carnation_base",
	base_skeleton = "hades_aquaz:carnation_base_skeleton",
	description = "Carnation Coral",
	special_tiles = "aquaz_carnation_top",
	},
	{
	name = "hades_aquaz:fiery_red",
	base = "hades_aquaz:fiery_red_base",
	base_skeleton = "hades_aquaz:fiery_red_base_skeleton",
	description = "Fiery Red Coral",
	special_tiles = "aquaz_fiery_red_top",
	},
	{
	name = "hades_aquaz:acropora",
	base = "hades_aquaz:acropora_base",
	base_skeleton = "hades_aquaz:acropora_base_skeleton",
	description = "Acropora Coral",
	special_tiles = "aquaz_acropora_top",
	},
	{
	name = "hades_aquaz:aquamarine_coral",
	base = "hades_aquaz:psammocora_base",
	base_skeleton = "hades_aquaz:psammocora_base_skeleton",
	description = "Aquamarine Coral Branch",
	special_tiles = "aquaz_aquamarine_coral_branch",
	},
	{
	name = "hades_aquaz:pink_birdnest_coral",
	base = "hades_xocean:brain_block",
	base_skeleton = "hades_xocean:brain_skeleton",
	description = "Pink Birdnest Coral",
	special_tiles = "aquaz_pink_birdnest_coral",
	},
	{
	name = "hades_aquaz:sea_blade_coral",
	base = "hades_xocean:bubble_block",
	base_skeleton = "hades_xocean:bubble_skeleton",
	description = "Sea Blade Coral",
	special_tiles = "aquaz_sea_blade_coral"
	},
}

for i = 1, #aquaz.corals do
	local def = minetest.registered_nodes[aquaz.corals[i].base]
	minetest.register_node(aquaz.corals[i].name, {
		description = S(aquaz.corals[i].description),
		_tt_help = S("Need Underwater @1 to grow.", def.short_description),
		drawtype = "plantlike_rooted",
		visual_scale = 1.0,
		tiles = def.tiles,
		special_tiles = {
		nil,
		nil,
		aquaz.corals[i].special_tiles..".png",
		aquaz.corals[i].special_tiles..".png",
		aquaz.corals[i].special_tiles..".png",
		aquaz.corals[i].special_tiles..".png"
		},
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = true,
		groups = {snappy = 3, coral_live = 1, coral_growing = 1},
		sounds = hades_sounds.node_sound_leaves_defaults(),
		node_dig_prediction = aquaz.corals[i].base,
		node_placement_prediction = "",
		drop = aquaz.corals[i].name.."_skeleton",
		on_place = function(itemstack, placer, pointed_thing) 
			coral_on_place(itemstack, placer, pointed_thing, aquaz.corals[i].name, aquaz.corals[i].base)
		end,
		after_destruct = function(pos, oldnode)
			minetest.set_node(pos, {name = aquaz.corals[i].base})
		end,
	})
	local def = minetest.registered_nodes[aquaz.corals[i].base_skeleton]
	minetest.register_node(aquaz.corals[i].name.."_skeleton", {
		description = S(aquaz.corals[i].description).." "..S("Skeleton"),
		drawtype = "plantlike_rooted",
		visual_scale = 1.0,
		tiles = def.tiles,
		special_tiles = {
		nil,
		nil,
		aquaz.corals[i].special_tiles.."_skeleton.png",
		aquaz.corals[i].special_tiles.."_skeleton.png",
		aquaz.corals[i].special_tiles.."_skeleton.png",
		aquaz.corals[i].special_tiles.."_skeleton.png"
		},
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = true,
		groups = {snappy = 3, coral_skeleton = 1},
		sounds = hades_sounds.node_sound_leaves_defaults(),
		node_dig_prediction = aquaz.corals[i].base.."_skeleton",
		node_placement_prediction = "",
		drop = aquaz.corals[i].name.."_skeleton",
		on_place = function(itemstack, placer, pointed_thing) 
			coral_on_place(itemstack, placer, pointed_thing, aquaz.corals[i].name.."_skeleton", aquaz.corals[i].base.."_skeleton")
		end,
		after_destruct	= function(pos, oldnode)
			minetest.set_node(pos, {name = aquaz.corals[i].base.."_skeleton"})
		end,
	})
end

aquaz.kelps = {
	{
		name = "hades_aquaz:calliarthon_kelp",
		description="Calliarthron Kelp",
		texture = "aquaz_calliarthron_kelp.png"
	},
}

for i = 1, #aquaz.kelps do
	minetest.register_node(aquaz.kelps[i].name, {
		description = S(aquaz.kelps[i].description),
		_tt_help = S("Need underwater sand (no volcanic, fertilize, silver or desert) to grow"),
		drawtype = "plantlike_rooted",
		waving = 1,
		tiles = {"default_sand.png"},
		special_tiles = {{name = aquaz.kelps[i].texture, tileable_vertical = true}},
		inventory_image = aquaz.kelps[i].texture,
		wield_image = aquaz.kelps[i].texture,
		paramtype = "light",
		paramtype2 = "leveled",
		groups = {snappy = 3, kelp = 1, kelp_growing = 1},
		selection_box = {
			type = "fixed",
			fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
					{-2/16, 0.5, -2/16, 2/16, 3.5, 2/16},
			},
		},
		node_dig_prediction = "hades_default:sand",
		node_placement_prediction = "",
		sounds = hades_sounds.node_sound_sand_defaults({
			dig = {name = "default_dig_snappy", gain = 0.2},
			dug = {name = "default_grass_footstep", gain = 0.25},
		}),

		on_place = kelp_on_place,
		after_dig_node = kelp_after_dig_node,

		after_destruct	= function(pos, oldnode)
			minetest.set_node(pos, {name = "hades_default:sand"})
		end
	})
end

--
-- Decoration
--

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "hades_aquaz:corals",
		decoration = {
			"hades_aquaz:psammocora",
			"hades_aquaz:rhodophyta",
			"hades_aquaz:sarcophyton",
			"hades_aquaz:carnation",
			"hades_aquaz:fiery_red",
			"hades_aquaz:acropora",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.04,
			scale = 0.05,
			spread = {x = 200, y = 200, z = 200},
			seed = 25345,
			octaves = 3,
			persist = 0.7
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -2,
		y_min = -10,
		flags = "force_placement",
	})
end

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "hades_aquaz:kelps",
		decoration = {
			"hades_aquaz:calliarthon_kelp",
			"hades_aquaz:sea_blade_coral"
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.005,
			scale = 0.004,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
end

aquaz.grass= {
	{
	name = "hades_aquaz:grass",
	description= "Aquatic Grass",
	special_tiles = "aquaz_grass.png",
	},
	{
	name = "hades_aquaz:tall_grass",
	description= "Aquatic Tall Grass",
	special_tiles = "aquaz_tall_grass.png",
	},
	{
	name = "hades_aquaz:stars_anemons",
	description= "Grass with Stars and Anemons",
	special_tiles = "aquaz_stars_anemons.png",
	drop = "hades_aquaz:tall_grass"
	},
	{
	name = "hades_aquaz:stars_anemons_2",
	description= "Grass with Stars and Anemons",
	special_tiles = "aquaz_stars_anemons_2.png",
	drop = "hades_aquaz:tall_grass"
	},
	{
	name = "hades_aquaz:sea_cucumbers",
	description= "Sea Cucumbers",
	special_tiles = "aquaz_sea_cucumbers.png",
	},
	{
	name = "hades_aquaz:sword_plant",
	description= "Aquatic Sword Plant",
	special_tiles = "aquaz_sword_plant.png",
	},
}

for i = 1, #aquaz.grass do
	local drop
	if aquaz.grass[i].drop then
		drop = aquaz.grass[i].drop
	else
		drop = aquaz.grass[i].name
	end
	minetest.register_node(aquaz.grass[i].name, {
		description = S(aquaz.grass[i].description),
		_tt_help = S("Need underwater sand (no volcanic, fertilize, silver or desert) to grow"),
		drawtype = "plantlike_rooted",
		waving = 1,
		paramtype = "light",
		tiles = {"default_sand.png"},
		special_tiles = {{name = aquaz.grass[i].special_tiles, tileable_vertical = true}},
		inventory_image = aquaz.grass[i].special_tiles,
		wield_image = aquaz.grass[i].special_tiles,
		drop = drop,
		groups = {snappy = 3, seaplant = 1, seagrass_growing = 1},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				{-4/16, 0.5, -4/16, 4/16, 1.5, 4/16},
			},
		},
		node_dig_prediction = "hades_default:sand",
		node_placement_prediction = "",
		sounds = hades_sounds.node_sound_stone_defaults({
			dig = {name = "default_dig_snappy", gain = 0.2},
			dug = {name = "default_grass_footstep", gain = 0.25},
		}),

		on_place = plant_on_place,

		after_destruct	= function(pos, oldnode)
			minetest.set_node(pos, {name = "hades_default:sand"})
		end,
	})
end

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "hades_aquaz:grass",
		decoration = {
			"hades_aquaz:grass",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0025,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 23232,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:tall_grass",
		decoration = {
			"hades_aquaz:tall_grass",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.00125,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 2323,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:stars_anemons",
		decoration = {
			"hades_aquaz:stars_anemons",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 343,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:stars_anemons_2",
		decoration = {
			"hades_aquaz:stars_anemons_2",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 733,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:aquamarine_coral_branch",
		decoration = {
			"hades_aquaz:aquamarine_coral_branch",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 82,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:pink_birdnest_coral",
		decoration = {
			"hades_aquaz:pink_birdnest_coral",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 1729,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:sea_cucumbers",
		decoration = {
			"hades_aquaz:sea_cucumbers",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 568,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
	minetest.register_decoration({
		name = "hades_aquaz:sword_plant",
		decoration = {
			"hades_aquaz:sword_plant",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		place_offset_y = -1,
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 568,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = -5,
		y_min = -10,
		flags = "force_placement",
		param2 = 48,
		param2_max = 96,
	})
end

--Wrecked Pillar

aquaz.wrecked_pillar = {
	{
	name = "hades_aquaz:wrecked_pillar_base",
	description= "Wrecked Pillar Base",
	tile = "aquaz_base_pillar.png"
	},
	{
	name = "hades_aquaz:wrecked_pillar_shaft",
	description= "Wrecked Pillar Shaft",
	tile = "aquaz_shaft_pillar.png"
	},
	{
	name = "hades_aquaz:wrecked_pillar_capital",
	description= "Wrecked Pillar Capital",
	tile = "aquaz_capital_pillar.png"
	},
}

for i = 1, #aquaz.wrecked_pillar do
	minetest.register_node(aquaz.wrecked_pillar[i].name, {
		description = S(aquaz.wrecked_pillar[i].description),
		tiles = {
			"aquaz_up_down_pillar.png",
			"aquaz_up_down_pillar.png",
			aquaz.wrecked_pillar[i].tile,
		},
		is_ground_content = false,
		groups = {cracky = 2, stone = 1},
		sounds = hades_sounds.node_sound_stone_defaults(),
	})
end

aquaz.coral_deco = {
	{
	name = "hades_aquaz:purple_alga",
	description= "Purple Alga Remains",
	tile = "aquaz_purple_alga.png"
	},
	{
	name = "hades_aquaz:orange_alga",
	description= "Orange Alga Remains",
	tile = "aquaz_orange_alga.png"
	},
	{
	name = "hades_aquaz:red_alga",
	description= "Red Alga Remains",
	tile = "aquaz_red_alga.png"
	},
}

for i = 1, #aquaz.coral_deco do
	minetest.register_node(aquaz.coral_deco[i].name, {
		description = S(aquaz.coral_deco[i].description),
		_tt_help = S("Need water source surface to grow"),
		drawtype = "nodebox",
		walkable = true,
		paramtype = "light",
		paramtype2 = "facedir",
    floodable = true,
		liquids_pointable = true,
		walkable = false,
		tiles = {aquaz.coral_deco[i].tile},
		use_texture_alpha = true,
		inventory_image = aquaz.coral_deco[i].tile,
		wield_image = aquaz.coral_deco[i].tile,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.499, 0.5}
		},
		groups = {
			snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, algae = 1, algae_growing = 1, food = 2, eatable = 1
		},
		sounds = hades_sounds.node_sound_leaves_defaults(),
		
		on_place = algae_on_place,
		on_use = minetest.item_eat(1),
	})
end

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	minetest.register_decoration({
		name = "hades_aquaz:algaes",
		decoration = {
			"hades_aquaz:purple_alga",
			"hades_aquaz:orange_alga",
			"hades_aquaz:red_alga",
		},
		deco_type = "simple",
		place_on = {"hades_default:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0.0005,
			scale = 0.0004,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {
			"grassland_ocean",
			"coniferous_forest_ocean",
			"deciduous_forest_ocean"
		},
		y_max = 2,
		y_min = 1,
		flags = "force_placement",
	})
end

--[[
minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"hades_default:sand"},
		place_offset_y = 1,
		sidelen = 16,
		fill_ratio = 0.0001,
	biomes = {
		"grassland_ocean",
		"coniferous_forest_ocean",
		"deciduous_forest_ocean"
	},
		y_max = -6,
		y_min = -10,
		schematic = modpath .. "/schematics/wrecked_pillar.mts",
		rotation = "random",
		flags = "force_placement, place_center_x, place_center_z",
})
--]]

dofile(modpath.."/hades.lua")
dofile(modpath.."/hades_feed.lua")

