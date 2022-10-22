
-- algae_feed
minetest.register_craftitem("hades_aquaz:algae_feed", {
    description = "Algae Feed",
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

