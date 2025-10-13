extends CharacterBody3D
class_name Enemy
var hp

func damage(amount, knockback):
	hp -= amount
	velocity = knockback
