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
	var collision = move_and_collide(movement)
	if not collision: return # 如果没有发生碰撞，直接返回
	var collider = collision.get_collider()
	if collider is CharacterBody2D:
		if collider is EnemyNode: # 如果是敌人节点
			(collider as EnemyNode)\
				.take_damage(randi_range(5, 10))
			self.explosion() # 火球爆炸
	elif collider is TileMapLayer: # 如果与地图上的物理节点碰撞
		self.explosion() # 火球爆炸
		#var tile_map = collider as TileMapLayer
		#var collision_point = collision.get_position()
		#var cell_position = tile_map.local_to_map(collision_point)
		#var tile_data = tile_map.get_cell_tile_data(cell_position)
		#if not tile_data: return # 无数据，直接返回
		# print(tile_data.get_custom_data('object_type'))

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
