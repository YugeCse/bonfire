extends CharacterBody2D
class_name EnemyAttackNode

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision: # 如果发生碰撞
		var collider = collision.get_collider()
		if collider is TileMapLayer:
			set_deferred(&'disabled', true)
			queue_free() # 发生碰撞，注销这个对象
		elif collider is PlayerNode:
			print('与玩家发生碰撞')
			(collider as PlayerNode)\
				.take_damage(randi_range(5, 12))
			set_deferred(&'disabled', true)
			queue_free() # 发生碰撞，注销这个对象

## 更新精灵动画
func _update_sprite_animation(direction: Vector2):
	if direction == Vector2.LEFT:
		$AnimatedSprite2D.play(&'attack_left')
	elif direction == Vector2.RIGHT:
		$AnimatedSprite2D.play(&'attack_right')
	$AnimatedSprite2D.animation_finished.connect(func(): queue_free())

## 创建新的对象
static func create(prefab: PackedScene, owner_obj: EnemyNode):
	var instance = prefab.instantiate() as EnemyAttackNode
	var direction = owner_obj.current_direction
	if direction == Vector2.LEFT or \
		owner_obj.get_current_animation() == &'goblin_idle_left' or \
		owner_obj.get_current_animation() == &'goblin_run_left':
		instance._update_sprite_animation(Vector2.LEFT)
		instance.global_position = owner_obj.position + Vector2(-16, 0)
	elif direction == Vector2.RIGHT or \
		owner_obj.get_current_animation() == &'goblin_idle' or \
		owner_obj.get_current_animation() == &'goblin_run':
		instance._update_sprite_animation(Vector2.RIGHT)
		instance.global_position = owner_obj.position + Vector2(16, 0)
	return instance
