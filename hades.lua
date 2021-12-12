
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

-- stairs for tall_grass
minetest.override_item("hades_aquaz:stars_anemons", {
		groups = {snappy = 3},
	})
minetest.override_item("hades_aquaz:stars_anemons_2", {
		groups = {snappy = 3},
	i})

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

