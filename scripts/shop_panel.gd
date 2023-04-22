extends Panel


onready var upgrades = {}
onready var weapons = {}
var prices = {}


func _ready():
	visible = false
	
	for category in [[$Upgrades, upgrades], [$Weapons, weapons]]:
		for node in category[0].get_children():
			var button: Button = node.get_node("BuyButton")
			category[1][node.name] = [node.get_node("GoldPrice"),
									node.get_node("WoodPrice"),
									button]
			prices[node.name] = [0, 0]
			# warning-ignore:return_value_discarded
			button.connect("button_down", self, "_on_buy_button_press", [node.name])


func reveal():
	get_tree().paused = true
	visible = true
	_refresh()


func _refresh():
	for upgrade_type in Events.upgrade_prices:
		var is_allowed_value: bool = Events.stats[upgrade_type] < Events.max_stats[upgrade_type]
		if is_allowed_value:
			for i in range(2):
				var start_price = Events.upgrade_prices[upgrade_type][i]
				var current_stat = Events.stats[upgrade_type]
				var calculated_price = start_price * int(current_stat / 5 - 1)
				prices[upgrade_type][i] = calculated_price
				upgrades[upgrade_type][i].text = str(calculated_price)
		else:
			upgrades[upgrade_type][0].text = "Maximum reached"
			upgrades[upgrade_type][1].visible = false
			upgrades[upgrade_type][2].visible = false
			
	for weapon_type in Events.weapon_prices:
		var is_allowed_value: bool = Events.stats[weapon_type] < Events.max_stats[weapon_type]
		if is_allowed_value:
			for i in range(2):
				var start_price = Events.weapon_prices[weapon_type][i]
				#var current_stat = Events.stats[weapon_type]
				#var calculated_price = start_price * int(current_stat / 5 - 1)
				#prices[weapon_type][i] = calculated_price
				prices[weapon_type][i] = start_price
				#weapons[weapon_type][i].text = str(calculated_price)
				weapons[weapon_type][i].text = str(start_price)
			
			if Events.stats[weapon_type] == 0:
				weapons[weapon_type][2].text = "UNLOCK"
			else:
				weapons[weapon_type][2].text = "ADD"
		else:
			weapons[weapon_type][0].text = "Maximum reached"
			weapons[weapon_type][1].visible = false
			weapons[weapon_type][2].visible = false


func _on_buy_button_press(node_name):
	print("SHOP pressed buy: %s" % [node_name])
	if Events.stats.gold >= prices[node_name][0] and Events.stats.wood >= prices[node_name][1]:
		Events.emit_signal("stat_changed", node_name, Events.stats[node_name] + 1)
		Events.emit_signal("stat_changed", "gold", Events.stats.gold - prices[node_name][0])
		Events.emit_signal("stat_changed", "wood", Events.stats.wood - prices[node_name][1])
		_refresh()


func _on_ExitButton_button_down() -> void:
	get_tree().paused = false
	visible = false

