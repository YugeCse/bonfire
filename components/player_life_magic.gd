extends CanvasLayer

## 最大血量值
@export
var _m_blood_value: float = 200.0

## 最大魔法值
@export
var _m_magic_value: float = 50.0

@onready
var _cr_life_blood: ColorRect = $BloodValue

@onready
var _cr_life_magic: ColorRect = $MagicValue

@onready
var _life_blood_value: float = float($BloodValue.size.x)

@onready
var _life_magic_value: float = float($MagicValue.size.x)

## 初始化方法
func _ready() -> void:
	max_blood_value = _m_blood_value # 设置初始化的最大血量值
	max_magic_value = _m_magic_value # 设置初始化的最大魔法值
	current_blood_value = _m_blood_value # 设置初始化的最大血量值
	current_magic_value = _m_magic_value # 设置初始化的最大魔法值

## 最大血量值
var max_blood_value: float :
	set(value):
		if current_blood_value and \
			value < current_blood_value:
			value = current_blood_value
		max_blood_value = value
		if _m_blood_value != max_blood_value:
			_m_blood_value = max_blood_value
	get:
		return max_blood_value

## 最大魔法值
var max_magic_value: float :
	set(value):
		if current_magic_value and \
			value < current_magic_value:
			value = current_magic_value
		max_magic_value = value
		if _m_magic_value != max_magic_value:
			_m_magic_value = max_magic_value
	get:
		return max_magic_value

## 当前血量值
var current_blood_value:
	set(value):
		if value < 0.0 || value > max_blood_value:
			return
		current_blood_value = value
		if not _cr_life_blood: return
		_cr_life_blood.size.x = _life_blood_value * (value / max_blood_value)
		print('设置生命值：%f' % _cr_life_blood.size.x)
	get:
		return current_blood_value

## 当前魔法值
var current_magic_value:
	set(value):
		if value < 0.0 || value > max_magic_value:
			return
		current_magic_value = value
		if not _cr_life_magic: return
		_cr_life_magic.size.x = _life_magic_value * (value / max_magic_value)
		print('设置魔法值：%f' % _cr_life_magic.size.x)
	get:
		return current_magic_value
