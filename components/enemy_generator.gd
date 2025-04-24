extends Node
class_name EnemyGenerator

@onready
var prefab: PackedScene = preload('res://components/enemy.tscn')

## 生成敌人
func generate(position: Vector2) -> EnemyNode:
	return EnemyNode.create(prefab, position)
