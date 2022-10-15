
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

-- bucket of algae feed

aquaz.algae_feed_fishes = {
  ["hades_xocean:fish"] = true,
  ["hades_xocean:fish2"] = true,
  ["hades_xocean:fish3"] = true,
  ["hades_xocean:fish4"] = true,
}

local algae_feed_fishes = aquaz.algae_feed_fishes

function aquaz.add_algae_feed_fishes(entity_name)
  aquaz.algae_feed_fishes[entity_name] = true
end
		
local function use_bucket_algae_feed (itemstack, user, pointed_thing)
  local feed_pos = user:get_pos()
  if (pointed_thing.type=="node") then
    feed_pod = pointed_thing.under
  elseif (pointed_thing.type=="object") then
    feed_pos = pointed_thing.ref:get_pos()
  end
  
  local objects = minetest.get_objects_inside_radius(feed_pos, 4)
  
  local feed_fish = 0
  for _,object in pairs(objects) do
    local luaentity = object:get_luaentity()
    if luaentity and (algae_feed_fishes[luaentity.name]) then
      user:set_wielded_item(ItemStack("hades_aquaz:algae_feed"))
      luaentity:on_rightclick(user)
      feed_fish = feed_fish + 1
    end
    if feed_fish>=8 then
      break
    end
  end
  
  if (feed_fish>0) then
    itemstack:take_item(1)
    local inv = user:get_inventory()
    local bucket = inv:add_item("main", ItemStack("hades_bucket:bucket_empty"))
    if (bucket:get_count()>0) then
      minetest.add_item(user:get_pos(), bucket)
    end
  end
  
  return itemstack
end

minetest.register_craftitem("hades_aquaz:bucket_algae_feed", {
    description = "Bucket Of Algae Feed",
    _tt_help = "Use it to feed up to 8 fishes nearby (up to 4 nodes) poitned entity or node.",
    inventory_image = "aquaz_bucket_algae_feed.png",
		groups = {
			algae = 1,
		},
    on_use = use_bucket_algae_feed,
    on_place = use_bucket_algae_feed,
    on_secondary_use = use_bucket_algae_feed,
  })
minetest.register_craft({
    output = "hades_aquaz:bucket_algae_feed",
    recipe = {
      {"hades_aquaz:algae_feed","hades_aquaz:algae_feed","hades_aquaz:algae_feed"},
      {"hades_aquaz:algae_feed","hades_aquaz:algae_feed","hades_aquaz:algae_feed"},
      {"hades_aquaz:algae_feed","hades_bucket:bucket_empty","hades_aquaz:algae_feed"},
    },
  })

