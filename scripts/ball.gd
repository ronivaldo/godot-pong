extends CharacterBody2D
# nome da classe para validar se a bola colidiu com o paddle
class_name Ball

signal bounced
@onready var cshape = $CollisionShape2D
@onready var beep1 = $Beep1
@onready var beep2 = $Beep2
@export var speed_increase_per_bounce = 20
var debug_mode = false

const START_SPEED = 500
var speed = START_SPEED
var active = false

# x,y
# x=-1, esquerda
# x=1, direita
# y=0, y nao muda
# y=1, para baixo
# y=-1, para cima
var move_dir = Vector2(-1, 0)

func _physics_process(delta: float) -> void:
	if !active:
		return 

	if debug_mode:
		var vertical_dir = Input.get_axis("ball_up", "ball_down")
		var horizontal_dir = Input.get_axis("ball_left", "ball_right")
		move_dir = Vector2(horizontal_dir, vertical_dir)

		# se tiver teclas, movimenta a bolsa
		if move_dir.x != 0.0 || move_dir.y != 0.0:
			velocity = move_dir * speed
		else:
			velocity = Vector2.ZERO
	else:
		# Apenas para CharacterBody2D - Não multiplique velocity por delta
		# antes de chamar move_and_slide() — isso já é considerado internamente.
		velocity = move_dir * speed
	
	# apos processar, retorna se colidiu com alguma coisa
	var is_collided = move_and_slide()
	if is_collided:
		# multiplica a direção x por -1, y fica igual
		# move_dir *= Vector2(1, -1)
		# mesmo efeito abaixo
		# move_dir.y *= -1
		# tem tambem o mesmo efeito
		# esse eh melhor pq em paredes anguladas funciona bem
		move_dir = move_dir.bounce(get_last_slide_collision().get_normal())
		# play sound
		play_beep()

func bounce_from_paddle(paddle_y_pos, paddle_height):
	# se bater na parte de cima do paddle, rebate para cima, y=-1
	# se bater no meio do paddle, rebate reto, y=0
	# se bater na parte de baixo do paddle, rebate para baixo, y=1
	# se bater em qq parte, faz as contas
	# new y = (y_pos_ball - y_pos_paddle) / paddle_height / 2
	var new_move_dir_y = (global_position.y - paddle_y_pos) / (paddle_height / 2.0)
	move_dir.y = new_move_dir_y
	# o x simplesmente inverte o lado
	move_dir.x *= -1
	
	# aumenta a velocidade da bola
	speed += speed_increase_per_bounce
	
	# play sound
	play_beep()

	# emite um sinal quando tocar em algum paddle
	bounced.emit()
	
func reset(reset_pos):
	global_position = reset_pos
	speed = START_SPEED
	# random pode ser esquerda ou direita, -1 ou 1
	move_dir.x = [-1, 1].pick_random()
	# precisamos float entre -1 e 1
	move_dir.y = randf() * [-1, 1].pick_random()
	active = false
	
func get_size():
	return cshape.shape.get_rect().size

func play_beep():
	# pick a random beep sound
	var beep = [beep1, beep2].pick_random()
	# set some random pitch scale
	beep.pitch_scale = [0.8, 1.0, 1.2].pick_random()
	beep.play()
	
