# API Reference (Engine/Script APIs and Signals)

This project is a local game and does not expose network endpoints. This reference documents the public methods and signals exposed by the main scripts.

Ball (scripts/ball.gd)
- Signals: `bounced` — emitted when the ball bounces on a paddle.
- Methods:
	- `bounce_from_paddle(paddle_y_pos, paddle_height)` — adjust `move_dir` based on impact and increases `speed`.
	- `reset(reset_pos)` — set `global_position` to `reset_pos`, reset `speed`, and randomize direction.
	- `get_size()` — returns the ball collision shape size.

Paddle (scripts/paddle.gd)
- Methods:
	- `get_ai_moviment_dir()` — returns -1/0/1 indicating AI vertical movement direction.
	- `_on_body_entered(body)` — callback triggered by collision; invokes ball bounce logic.

Game (scripts/game.gd)
- Methods:
	- `reset_game()` — resets score and starts a new round.
	- `reset_round()` — resets ball position, waits `StartDelay`, and activates the ball.
	- `simulate_ball_movement(seconds=3.0)` — predictive simulation to compute visual points for `Line2D`.
- Listened Signals:
	- `bounced` from `Ball` — triggers simulation updates.
	- `ball_out(is_left)` from `Detector` — increments score and resets rounds.

HUD (scripts/hud.gd)
- Methods:
	- `set_new_score(score)` — updates left/right labels with values from a `Vector2`.
	- `reset_score()` — sets both labels to "0".

Detector (scripts/detector.gd)
- Signals: `ball_out(is_left)` — emitted when a `Ball` enters the detector area.

Notes
- All GDScript public methods are instance methods bound to scene nodes; call them via node references found in the scene tree (for example: `get_node("/root/Game/TheBall/Ball")`).

