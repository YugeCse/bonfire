extends CharacterBody2D
class_name PlayerAttackNode

#@export
#var speed: float = 50.0

@export
var max_distance: float = 30.0

var current_direction: Vector2 = Vector2.ZERO

#var _distance_traveled: float = 0.0

func _ready() -> void:
	_play_animation(current_direction)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(current_direction * delta)
	if not collision: return
	var collider = collision.get_collider()
	if not collider: return
	if collider is EnemyNode: # 如果是敌方节点
		$CollisionShape2D.set_deferred(&'disabled', true)
		queue_free()
		(collider as EnemyNode).take_damage(randi_range(8, 15))

#func _physics_process(delta: float) -> void:
	# 移动剑气
	#var movement = velocity * speed * delta
	#_distance_traveled += movement.length()
	# 超过最大距离则消失
	#if _distance_traveled >= max_distance:
		#queue_free()
		#return
	#var collider = move_and_collide(movement)
	#if collider: # 如果发生碰撞，则检测碰撞体
		#var collider_obj = collider.get_collider()

## 播放动画
func _play_animation(direction: Vector2):
	if current_direction == Vector2.ZERO:
		queue_free()
		return
	if direction == Vector2.UP:
		$AnimatedSprite2D.play(&'attack_top')
		velocity = Vector2.UP
	elif direction == Vector2.DOWN:
		$AnimatedSprite2D.play(&'attack_bottom')
		velocity = Vector2.DOWN
	elif direction == Vector2.RIGHT:
		$AnimatedSprite2D.play(&'attack')
		velocity = Vector2.RIGHT
	else:
		$AnimatedSprite2D.play(&'attack_left')
		velocity = Vector2.LEFT
	$AnimatedSprite2D.animation_finished.connect(func (): queue_free())

## 创建一个剑气对象
static func create(prefab: Resource, owner_obj: PlayerNode) -> PlayerAttackNode:
	var instance = prefab.instantiate() as PlayerAttackNode
	instance.current_direction = owner_obj.current_dir_vec2
	if owner_obj.current_dir_vec2 == Vector2.RIGHT:
		instance.global_position = owner_obj.global_position + Vector2(8, 0) * 1.5
	elif owner_obj.current_dir_vec2 == Vector2.LEFT:
		instance.global_position = owner_obj.global_position + Vector2(-8, 0) * 1.5
	elif owner_obj.current_dir_vec2 == Vector2.UP:
		instance.global_position = owner_obj.global_position + Vector2(0, -8) * 1.5
	else:
		instance.global_position = owner_obj.global_position + Vector2(0, 8) * 1.5
	return instance
