extends CharacterBody2D
class_name FireballNode

## 运动速度
var speed: float = 120.0

## 当前的方向
var current_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	_update_fireball(current_direction)

func _physics_process(delta: float) -> void:
	var movement = velocity * speed * delta
	var collider = move_and_collide(movement)
	if collider: # 如果发生了碰撞
		var collider_obj = collider.get_collider()
		if collider_obj is CharacterBody2D:
			if collider_obj is EnemyNode: # 如果是敌人节点
				explosion() # 火球爆炸
				(collider_obj as EnemyNode).take_damage(10)

## 火球爆炸
func explosion():
	$FireballShape.set_deferred(&'disabled', true)
	$ASprite\
		.disconnect(&'animation_finished', _destroy)
	velocity = Vector2.ZERO
	$ASprite.play(&'explosion')
	$ASprite.animation_finished.connect(_destroy)

## 更新fireball
func _update_fireball(direction: Vector2):
	velocity = direction
	if direction == Vector2.UP:
		$ASprite.play(&'up')
	elif direction == Vector2.DOWN:
		$ASprite.play(&'down')
	elif direction == Vector2.LEFT:
		$ASprite.play(&'left')
	elif direction == Vector2.RIGHT:
		$ASprite.play(&'right')
	else:
		queue_free()
		return
	$ASprite.animation_finished.connect(_destroy)

## 注销这个节点
func _destroy(): queue_free()

## 创建火球对象
static func create(prefab: Resource, owner_obj: PlayerNode) -> FireballNode:
	var instance = prefab.instantiate() as FireballNode
	var direction = owner_obj.current_dir_vec2
	instance.current_direction = direction
	match direction:
		Vector2.UP:
			instance.global_position = owner_obj.global_position + Vector2(0, -12)
		Vector2.DOWN:
			instance.global_position = owner_obj.global_position + Vector2(0, 12)
		Vector2.LEFT:
			instance.global_position = owner_obj.global_position + Vector2(-12, 0)
		Vector2.RIGHT:
			instance.global_position = owner_obj.global_position + Vector2(12, 0)
	return instance
