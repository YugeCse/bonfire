extends CharacterBody2D
class_name PlayerNode

## 移动速度
var speed: float = 50.0

## 当前的方向
var current_direction: String = 'forward'

## 当前方向对应的Vector2
var current_dir_vec2: Vector2 = Vector2.RIGHT

## 当前的运动状态-['run', 'idle', 'run_left', 'idle_left']
var current_run_state: String = 'idle'

## 玩家攻击统计时间
var _player_attack_time: float = 0.0

## 玩家攻击的剑气对象实例
var _player_attack_prefab = preload('res://components/player_attack.tscn')

## 玩家攻击的火球对象实例
var _player_fireball_prefab = preload('res://components/fireball.tscn')

func _ready() -> void:
	$PlayerAsprite.play(&'knight_idle')
	self._update_run_state(current_run_state)

func _physics_process(delta: float) -> void:
	_handle_move(delta) # 处理移动逻辑
	_handle_attack(delta) # 处理攻击逻辑

## 处理移动逻辑
func _handle_move(delta: float):
	if Input.is_key_pressed(KEY_A) or \
		Input.is_key_pressed(KEY_LEFT):
		if current_direction != 'backward':
			current_direction = 'backward'
			self.velocity = Vector2.ZERO
		else:
			current_run_state = 'run_left'
			self.velocity = Vector2.LEFT
		current_dir_vec2 = Vector2.LEFT
	elif Input.is_key_pressed(KEY_D) or \
		Input.is_key_pressed(KEY_RIGHT):
		if current_direction != 'forward':
			current_direction = 'forward'
			self.velocity = Vector2.ZERO
		else:
			current_run_state = 'run'
			self.velocity = Vector2.RIGHT
		current_dir_vec2 = Vector2.RIGHT
	elif Input.is_key_pressed(KEY_W) or \
		Input.is_key_pressed(KEY_UP):
		if current_direction == 'backward':
			current_run_state = 'run_left'
		elif current_direction == 'forward':
			current_run_state = 'run'
		self.velocity = Vector2.UP
		current_dir_vec2 = Vector2.UP
	elif Input.is_key_pressed(KEY_S) or \
		Input.is_key_pressed(KEY_DOWN):
		if current_direction == 'backward':
			current_run_state = 'run_left'
		elif current_direction == 'forward':
			current_run_state = 'run'
		self.velocity = Vector2.DOWN
		current_dir_vec2 = Vector2.DOWN
	else:
		if current_direction == 'backward':
			current_run_state = 'idle_left'
		else:
			current_run_state = 'idle'
		self.velocity = Vector2.ZERO
	self._update_run_state(current_run_state)
	var collider = move_and_collide(self.velocity * speed * delta) # 处理移动和碰撞逻辑
	if collider: # 如果发生碰撞
		self._handle_collide(collider.get_collider()) ## 处理碰撞事件

## 处理攻击事件
func _handle_attack(delta: float):
	_player_attack_time += delta
	if _player_attack_time != 0 and \
		_player_attack_time < 0.35:
		return
	_player_attack_time = 0.0
	if Input.is_key_pressed(KEY_J): # 处理按键J发射武器
		var attack_instance = PlayerAttackNode\
			.create(_player_attack_prefab, self)
		get_tree().current_scene.add_child(attack_instance) # 添加这个攻击特效
	elif Input.is_key_pressed(KEY_K): # 处理按键K发射火球
		var fireball = FireballNode\
			.create(_player_fireball_prefab, self)
		get_tree().current_scene.add_child(fireball) # 添加这个攻击特效
	pass

## 处理碰撞事件
func _handle_collide(collider: Object):
	if collider is StaticBody2D:
		var parent = collider.get_parent()
		print('碰撞的名称是：%s' % parent)

## 玩家受到攻击伤害
func take_damage(damage: float):
	$LifeMagicController.current_blood_value -= damage
	if $LifeMagicController.current_blood_value > 0.0:
		print('玩家受到伤害')
		return
	print('玩家已经玩完了')
	$LifeMagicController.current_blood_value = 0.0


## 更新运动状态
func _update_run_state(state: String):
	if state == 'idle':
		if $PlayerAsprite.animation == &'knight_idle':
			return
		if $PlayerAsprite.is_playing():
			$PlayerAsprite.stop()
		$PlayerAsprite.play(&'knight_idle')
	elif state == 'run':
		if $PlayerAsprite.animation == &'knight_run':
			return
		if $PlayerAsprite.is_playing():
			$PlayerAsprite.stop()
		$PlayerAsprite.play(&'knight_run')
	elif state == 'idle_left':
		if $PlayerAsprite.animation == &'knight_idle_left':
			return
		if $PlayerAsprite.is_playing():
			$PlayerAsprite.stop()
		$PlayerAsprite.play(&'knight_idle_left')
	else:
		if $PlayerAsprite.animation == &'knight_run_left':
			return
		if $PlayerAsprite.is_playing():
			$PlayerAsprite.stop()
		$PlayerAsprite.play(&'knight_run_left')
