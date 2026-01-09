extends Node2D

# @onready atribui a variavel depois do ready
@onready var ball = $TheBall/Ball
@onready var paddle_one = $ThePaddles/PaddleOne
@onready var paddle_two = $ThePaddles/PaddleTwo

@onready var detector_left = $Environment/DetectorLeft
@onready var detector_right = $Environment/DetectorRight
@onready var start_delay = $StartDelay

@onready var hud = $CanvasLayer/HUD
@onready var l2d = $TheBall/BallMovimentLine2D
@onready var ball_out_sound = $TheBall/BallOutSound

var game_area_size = Vector2(1280, 720)

# vector2 apenas para inteiros, colocaremos a pontuacao aqui
var score = Vector2i.ZERO
# exporta para o inspector permitir alterar
@export var final_score = 10

func _ready() -> void:
	detector_left.ball_out.connect(_on_detector_ball_out)
	detector_right.ball_out.connect(_on_detector_ball_out)
	ball.bounced.connect(_on_ball_bounced)
		# seed the random numbers
	randomize()
	reset_game()


func _process(delta: float) -> void:
	# sai do jogo
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# reinicia a cena atual
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	# enter debug mode
	if Input.is_action_just_pressed("ball_control"):
		ball.debug_mode = !ball.debug_mode
		paddle_one.active = !ball.debug_mode
		if !ball.debug_mode:
			# ao voltar do debug mode, seta a bola para a esquerda reto
			ball.move_dir = Vector2(-1, 0)
	if Input.is_action_just_pressed("show_lines"):
		l2d.visible = !l2d.visible

func _draw() -> void:
	# show the middle dashed line
	var line_start = Vector2(game_area_size.x/2.0, 0)
	var line_end = Vector2(game_area_size.x/2.0, game_area_size.y)
	draw_dashed_line(line_start, line_end, Color.WHITE, 8.0, 12.0, true)

func reset_game():
	score = Vector2i.ZERO
	hud.reset_score()
	reset_round()

func reset_round():
	var reset_pos = game_area_size / 2.0
	ball.reset(reset_pos)
	start_delay.start()
	await start_delay.timeout
	ball.active = true
	simulate_ball_movement()

func _on_detector_ball_out(is_left):
	if is_left:
		# right scored
		score.y += 1
	else:
		# left scored
		score.x += 1

	hud.set_new_score(score)

	# play sound	
	ball_out_sound.play()
	
	
	# remove os pontos da linha
	# quando a bola sair da tela
	l2d.clear_points()
	# se o jogo terminar
	if score.y >= final_score || score.x >= final_score:
		reset_game()
	else:
		# se algum jogador fez ponto é reset round
		reset_round()
		# se um jogador conseguiu o score final, eh reset game
	
func update_line_2d(points):
	l2d.clear_points()
	l2d.global_position = ball.global_position
	# faz um loop em todos os pontos
	for point in points:
		# cada ponto deve ser em relacao ao l2d
		# como o ponto vem global, tem que transformar
		# transforma o ponto global em local ao l2d
		var localized_point = l2d.to_local(point)
		# adiciona o ponto
		l2d.add_point(localized_point)
	

func _on_ball_bounced():
	simulate_ball_movement()

func simulate_ball_movement(seconds: float = 3.0):
	# get the current ball position
	var ball_pos = ball.global_position
	# copy the move direction of the ball
	# it will be used to calculate the final y
	var move_dir_copy = ball.move_dir
	# size of the ball
	var bs = ball.get_size()
	
	var top_limit = bs.y/2.0
	var bottom_limit = game_area_size.y - bs.y/2.0
	# position of the left paddle + ball size
	var left_limit = paddle_one.global_position.x + bs.x/2.0
	# position of the right paddle + ball size
	var right_limit = paddle_two.global_position.x - bs.x/2.0
	
	# a linha inicia na posicao que esta a bola
	var points = [ball_pos]
	# obtem o delta time do physics
	var dt = get_physics_process_delta_time()
	
	# 60 is the fps
	# go ahead 3 seconds, frame by frame
	for i in range(0, 60*seconds):
		# simulate a movement of the ball in a tick
		ball_pos += move_dir_copy * ball.speed * dt
		# now lets check the limits
		
		# did the ball hit any paddle limits
		if ball_pos.x <= left_limit || ball_pos.x >= right_limit:
			# check if the ball hit the left limit, but actually is moving to the right
			if ball_pos.x <= left_limit && move_dir_copy.x > 0:
				pass
			# check if the ball hit the right limit, but actually is moving to the left
			elif ball_pos.x >= right_limit && move_dir_copy.x < 0:
				pass
			else:
				# the ball is actually outside the limits
				break

		# if hit the top and bottom limits, bounce the ball
		if ball_pos.y <= top_limit || ball_pos.y >= bottom_limit:
			# bounce the y direction
			move_dir_copy.y *= -1
			# add as a point
			points.append(ball_pos)

	points.append(ball_pos)
	
	# se o paddle one is ai and the ball is moving to the left
	if paddle_one.is_ai and ball.move_dir.x == -1:
		paddle_one.ai_target_y_pos = ball_pos.y

	# se o paddle two is ai and the ball is moving to the right
	if paddle_two.is_ai and ball.move_dir.x == 1:
		paddle_two.ai_target_y_pos = ball_pos.y

	update_line_2d(points)
		
		
		
