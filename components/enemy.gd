extends CharacterBody2D
class_name EnemyNode

## 移动速度
var speed: float = 50

## 最大血量
@export
var max_blood_value: float = 30.0

## 当前血量
@export
var current_blood_value: float = 0.0

## 受到伤害的限制记录时间
var _take_damage_limit_time: float = 0.0

## 行为方向
@export_enum("idle", "idle_left", "run", "run_left")
var current_action: String = "idle"

## 当前方向
@export
var current_direction: Vector2 = Vector2.ZERO

## 智能移动的定时器对象
var _smart_move_timer: Timer

## 攻击限制记录时间
var _attack_limit_time: float = 0.0

## 被检测到的玩家
var _detected_player: PlayerNode = null

## 检测到玩家的移动记录时间
var _detected_player_move_time: float = 0.0

## 敌方攻击的技能预制体
@onready
var _enemy_attack_prefab: PackedScene = preload('res://components/enemy_attack.tscn')

func _ready() -> void:
	current_blood_value = max_blood_value
	_update_sprite_animation(current_action)
	# 添加定时器对象
	_smart_move_timer = Timer.new()
	_smart_move_timer.wait_time = 1.0
	_smart_move_timer.timeout\
		.connect(_change_direction)
	_smart_move_timer.one_shot = false
	_smart_move_timer.autostart = true
	add_child(_smart_move_timer)
	$DetectionArea2D.area_entered\
		.connect(_detect_player_area_entered)
	$DetectionArea2D.area_exited\
		.connect(_detect_player_area_exited)

func _physics_process(delta: float) -> void:
	_handle_attack(delta) # 处理发动攻击的逻辑
	_handle_take_damage(delta) # 处理玩家被攻击的逻辑
	_handle_move(delta) # 处理玩家移动的逻辑

## 处理攻击逻辑
func _handle_attack(delta: float):
	if not _detected_player: return # 未发现玩家，直接返回
	if _attack_limit_time < randf_range(0.8, 2.0):
		_attack_limit_time += delta
	else:
		_attack_limit_time = 0.0
		var instance = EnemyAttackNode\
			.create(_enemy_attack_prefab, self)
		get_tree().current_scene.add_child(instance)

## 处理受到伤害的逻辑
func _handle_take_damage(delta: float):
	if not $EnemyShape.disabled: return
	if _take_damage_limit_time > 0.5:
		$EnemyShape.set_deferred(&'disabled', false)
		_take_damage_limit_time = 0.0 # 设置此时可以再次被攻击
	else: _take_damage_limit_time += delta

#region 处理移动逻辑
## 处理移动逻辑
func _handle_move(delta: float):
	if not _detected_player:
		var collision = move_and_collide(velocity * speed * delta) # 移动并发生碰撞处理
		if collision: # 如果发生了碰撞
			var collider = collision.get_collider()
			if collider is TileMapLayer:
				velocity = Vector2.ZERO
	else: # AI自动寻址
		# print('进入AI自动寻址模式...')
		# 定时更新路径（避免每帧计算）
		const limit_distance: float = 8.0
		var diff = _detected_player.global_position - global_position
		var diff_x = diff.x
		var diff_y = diff.y
		if abs(diff_x) < limit_distance and \
			abs(diff_y) < limit_distance and \
			_detected_player.global_position.dot(global_position) > 0.0 and \
			$NavigationAgent2D.is_navigation_finished():
			print('距离: %s' % (global_position - _detected_player.global_position))
			return
		_detected_player_move_time += delta
		if _detected_player_move_time > 1.0:
			$NavigationAgent2D.target_position = \
				_detected_player.global_position + \
				Vector2(limit_distance if diff_x < 0 else -limit_distance, 0)
			_detected_player_move_time = 0.0
		# 沿路径移动
		var next_path_pos = $NavigationAgent2D.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		if roundi(direction.x) != 0:
			current_direction = Vector2(roundi(direction.x), 0)
		move_and_collide(direction * speed * delta) # 执行移动敌方
#endregion

## 修改方向
func _change_direction():
	var directions = [Vector2.DOWN, Vector2.UP, \
		Vector2.LEFT, Vector2.RIGHT, Vector2.ZERO]
	current_direction = directions[randi_range(0, directions.size()-1)]
	var new_action = current_action
	if current_direction == Vector2.LEFT:
		new_action = 'run_left'
		velocity = Vector2.LEFT
	elif current_direction == Vector2.RIGHT:
		new_action = 'run'
		velocity = Vector2.RIGHT
	elif current_direction == Vector2.UP or \
		current_direction == Vector2.DOWN:
		if new_action == 'idle' or \
			new_action == 'run':
			new_action = 'run'
		elif new_action == 'idle_left' or \
			new_action == 'run_left':
			new_action = 'run_left'
		velocity = [Vector2.UP, Vector2.DOWN][randi_range(0, 1)]
	elif current_direction == Vector2.ZERO:
		if new_action == 'idle' or \
			new_action == 'run':
			new_action = 'idle'
		elif new_action == 'idle_left' or \
			new_action == 'run_left':
			new_action = 'idle_left'
		velocity = Vector2.ZERO
	_update_sprite_animation(new_action)

## 受到伤害
func take_damage(damage: float):
	$EnemyShape.set_deferred(&'disabled', true)
	current_blood_value -= damage
	if current_blood_value <= 0.0:
		current_blood_value = 0.0
		_smart_move_timer.timeout\
			.disconnect(_change_direction)
		queue_free()
		return
	queue_redraw() # 强制重新绘制血条

## 更新精灵的动画
func _update_sprite_animation(action: String):
	match action:
		'idle':
			$ASprite.play(&'goblin_idle')
		'idle_left':
			$ASprite.play(&'goblin_idle_left')
		'run':
			$ASprite.play(&'goblin_run')
		'run_left':
			$ASprite.play(&'goblin_run_left')

## 获取当前动画的名称
func get_current_animation(): $ASprite.animation

## 绘制血条等操作
func _draw() -> void:
	var percent = current_blood_value / max_blood_value \
		if max_blood_value != 0.0 else 0.0
	draw_rect(Rect2(Vector2(-8, -10), Vector2(20 * percent, 2)), Color.RED, -1.0, true)
	draw_rect(Rect2(Vector2(-8, -10), Vector2(20, 2.0)), Color.BLACK, false, -1.0, true)

## 检测玩家进入检测范围
func _detect_player_area_entered(area: Area2D):
	var obj = area.get_parent()
	if obj is PlayerNode: # print('发现玩家节点')
		print('发现玩家节点')
		_smart_move_timer.stop() # 停止智能移动的定时器运行
		_detected_player = obj # 赋值检测的玩家节点

## 检测玩家离开检测范围
func _detect_player_area_exited(area: Area2D):
	var obj = area.get_parent()
	if obj is PlayerNode: # print('离开玩家节点')
		print('离开玩家节点')
		_detected_player = null
		_smart_move_timer.start() # 再次启动智能移动的定时器

## 创建一个实例
static func create(prefab: PackedScene, position: Vector2) -> EnemyNode:
	var instance = prefab.instantiate() as EnemyNode
	instance.position = position
	instance.current_direction = Vector2.RIGHT
	return instance
