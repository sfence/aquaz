
-- craft corale blocks
for _, coral in pairs(aquaz.corals) do
	minetest.register_craft({
		output = coral.base,
		recipe = {
			{coral.name, coral.name, coral.name},
			{coral.name, 'hades_xocean:ocean_cobble', coral.name},
			{coral.name, coral.name, coral.name},
			},
	})
end

-- algae_feed
minetest.register_craftitem("hades_aquaz:algae_feed", {
    description = "Algae feed",
    inventory_image = "aquaz_algae_feed.png",
		groups = {
			algae = 1, food = 2, eatable = 1,
		},
		on_use = minetest.item_eat(1),
  })
minetest.register_craft({
    type = "shapeless",
    output = "hades_aquaz:algae_feed 3",
    recipe = {
      "hades_aquaz:purple_alga",
      "hades_aquaz:orange_alga",
      "hades_aquaz:red_alga",
    },
  })

-- stairs for tall_grass
minetest.override_item("hades_aquaz:stars_anemons", {
		groups = {snappy = 3},
	})
minetest.override_item("hades_aquaz:stars_anemons_2", {
		groups = {snappy = 3},
	})

minetest.register_abm({
	label = "Upgrade tall grass",
	nodenames = {"hades_aquaz:tall_grass"},
	interval = 269,
	chance = 197,
	action = function(pos, node)
		node.param2 = node.param2 + 1
		if node.param2>15 then
			node.param2 = 0
			if math.random(2)==1 then
				node.name = "hades_aquaz:stars_anemons"	
			else
				node.name = "hades_aquaz:stars_anemons_2"	
			end
		end
		minetest.swap_node(pos, node)
	end,
})

-- grow on water algae
local algae_light_limit = 13
minetest.register_abm({
	label = "Grow algaes",
	nodenames = {"group:algae_growing"},
	interval = 37,
	chance = 39,
	action = function(pos, node)
		pos.y = pos.y - 1
		local node_under = minetest.get_node(pos)
		pos.y = pos.y + 1
		if node_under.name~="hades_core:water_source" then
			minetest.remove_node(pos)
			return
		end
		local day_light = node.param1%16
		if (day_light>=algae_light_limit) then
			--spreed
			local pos0 = {x=pos.x-6,y=pos.y-8,z=pos.z-6}
			local pos1 = {x=pos.x+6,y=pos.y+2,z=pos.z+6}
			
			local found_pos = minetest.find_nodes_in_area(pos0, pos1, "group:algae")
			if #found_pos > (((day_light-algae_light_limit+1)/(15-algae_light_limit))*72) then
				return
			end
			
			found_pos = minetest.find_nodes_in_area_under_air(pos0, pos1, "hades_core:water_source")
			if #found_pos > 0 then
				found_pos = found_pos[math.random(#found_pos)]
				found_pos.y = found_pos.y + 1
				local found_node = minetest.get_node(found_pos)
				if found_node.name=="air" then
					minetest.set_node(found_pos, {name=node.name, param2=node.param2})
				end
			end
			minetest.swap_node(pos, node)
		end
	end,
})

