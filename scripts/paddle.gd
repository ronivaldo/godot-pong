extends Area2D

@export var is_ai = false
@export var is_player_one = false

# referencia ao collision shape do paddle, para saber a altura dinamicamente
@onready var cshape:CollisionShape2D  = $CollisionShape2D

var active = true
var up_input = "paddle_up"
var down_input = "paddle_down"

const MAX_VELOCITY = 10.0
var velocity = 0.0
var acceleration = 50.0
var slow_down_delta = 2.0
var ai_target_y_pos = 360.0

func  _ready() -> void:
	if is_player_one == false:
		up_input += "_two"
		down_input += "_two"

func _physics_process(delta: float) -> void:
	# se o paddle nao estiver ativo, nao movimenta
	if !active:
		return
	
	var move_dir = 0.0
	
	if !is_ai:
		move_dir = Input.get_axis(up_input, down_input)
	else:
		move_dir = get_ai_moviment_dir()
	
	velocity += move_dir * acceleration * delta
	# se nao tiver teclas, a velocidade tente a zero
	# com decrescimo de slow_down_delta
	if move_dir == 0.0:
		velocity = move_toward(velocity, 0.0, slow_down_delta)
	
	# limita a velocidade
	velocity = clampf(velocity, -MAX_VELOCITY, MAX_VELOCITY)

	# seta a posicao y na tela
	# estamos usando Area2D, entao temos que adicionar manualmente
	# se fosse Caracter2D, seria com move_and_slide()
	global_position.y += velocity
	
	global_position.y = clampf(global_position.y, 0, get_window().size.y)

	# ai bot simples que sempre segue a bola
	# teoricamente nunca perde
	#if is_ai:
		#var ball = get_tree().get_first_node_in_group("balls")
		#ai_target_y_pos = ball.global_position.y

func _on_body_entered(body: Node2D) -> void:
	# se a bola colidiu com o paddle
	if body is Ball:
		# avisa a ball para rebater
		body.bounce_from_paddle(global_position.y, cshape.shape.get_rect().size.y)

		# Se este paddle for controlado por IA, após rebater
		# voltamos o alvo da IA para o centro da tela enquanto
		# a bola vai para o adversário.
		if is_ai:
			ai_target_y_pos = get_window().size.y / 2.0

# returns -1, 0, 1 as y direction
func get_ai_moviment_dir():
	# obtem a distancia do paddle para o objetivo
	var dist_to_target = abs(ai_target_y_pos - global_position.y)
	# how accurate the paddle want to be
	var accuracy_distance = 25
	
	# ai bot simples que sempre segue a bola
	#var ball = get_tree().get_first_node_in_group("balls")
	#ai_target_y_pos = ball.global_position.y

	if dist_to_target > accuracy_distance:
		if ai_target_y_pos > global_position.y:
			# must go down
			return 1
		else:
			# must go up
			return -1
	else:
		# ja chegamos na distancia perto suficiente
		return 0
