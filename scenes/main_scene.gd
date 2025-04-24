extends Node

var _enemy_generate_timer: Timer

func _ready() -> void:
	var _born_coords = []
	for coordinate in $WallFloorLayer.get_used_cells():
		var data = $WallFloorLayer.get_cell_tile_data(coordinate)
		if data and data.has_custom_data('object_type'):
			var obj_type = data.get_custom_data('object_type')
			print('----> ' + obj_type)
			if obj_type == 'floor':
				_born_coords.push_back(coordinate)
				print('----> 长度：' + str(_born_coords.size()))
	for coordinate in $ObjectsLayer.get_used_cells():
		var idx = _born_coords.find_custom(\
			func(v): v.x == coordinate.x and v.y == coordinate.y)
		if idx != -1: _born_coords.remove_at(idx)
	## 添加一个定时器逻辑
	_enemy_generate_timer = Timer.new()
	_enemy_generate_timer.connect('timeout', \
		func(): _generate_enemy(_born_coords))
	_enemy_generate_timer.wait_time = 1.0
	_enemy_generate_timer.one_shot = false
	_enemy_generate_timer.autostart = true
	add_child(_enemy_generate_timer)

## 生成敌人
func _generate_enemy(coordinates: Array):
	if coordinates.size() <= 0 or \
		$EnemyLayer.get_child_count() >= 5:
		return
	var rand = randi_range(0,coordinates.size()-1)
	var data = coordinates[rand]
	var node = $EnemyGenerator.generate(\
		Vector2(data.x, data.y) * Vector2(24, 24))
	$EnemyLayer.add_child(node)
