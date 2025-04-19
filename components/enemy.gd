extends CharacterBody2D
class_name EnemyNode

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

func _ready() -> void:
	current_blood_value = max_blood_value
	_update_sprite_animation(current_action)

func _physics_process(delta: float) -> void:
	if $EnemyShape.disabled:
		_take_damage_limit_time += delta
		if _take_damage_limit_time > 0.5:
			$EnemyShape.set_deferred(&'disabled', false)
			_take_damage_limit_time = 0.0 # 设置此时可以再次被攻击

## 受到伤害
func take_damage(damage: float):
	$EnemyShape.set_deferred(&'disabled', true)
	current_blood_value -= damage
	if current_blood_value == 0.0:
		queue_free()
		return
	queue_redraw() # 强制重新绘制血条

## 更新精灵的动画
func _update_sprite_animation(action: String):
	match action:
		'idle':
			$ASprite.play(&'goblin_idle')
			velocity = Vector2.ZERO
		'idle_left':
			$ASprite.play(&'goblin_idle_left')
			velocity = Vector2.ZERO
		'run':
			$ASprite.play(&'goblin_run')
			velocity = Vector2.RIGHT
		'run_left':
			$ASprite.play(&'goblin_run_left')
			velocity = Vector2.LEFT

func _draw() -> void:
	var percent = current_blood_value / max_blood_value \
		if max_blood_value != 0.0 else 0.0
	draw_rect(Rect2(Vector2(-8, -10), Vector2(20 * percent, 3)), Color.RED)
	draw_rect(Rect2(Vector2(-8, -10), Vector2(20, 3)), Color.BLACK, false)
