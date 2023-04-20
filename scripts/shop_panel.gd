extends Panel


onready var upgrades = {}
var prices = {}


func _ready():
	visible = false
	
	for node in $Upgrades.get_children():
		var button: Button = node.get_node("BuyButton")
		upgrades[node.name] = [node.get_node("GoldPrice"),
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
		var is_max_value: bool = Events.stats[upgrade_type] < Events.max_stats[upgrade_type]
		if is_max_value:
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


func _on_buy_button_press(node_name):
	print("SHOP pressed buy: ", node_name)
	if Events.stats.gold >= prices[node_name][0] and Events.stats.wood >= prices[node_name][1]:
		Events.emit_signal("stat_changed", node_name, Events.stats[node_name] + 1)
		Events.emit_signal("stat_changed", "gold", Events.stats.gold - prices[node_name][0])
		Events.emit_signal("stat_changed", "wood", Events.stats.wood - prices[node_name][1])
		_refresh()


func _on_ExitButton_button_down() -> void:
	get_tree().paused = false
	visible = false

