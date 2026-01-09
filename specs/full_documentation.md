# Full Documentation

This file will contain the file-by-file analysis and the assembled documentation.

(Populating...)

## File: scripts/ball.gd

### Purpose
The `ball.gd` script defines the behavior of the game ball: movement, collision responses, sound effects, and state reset. It belongs to the game logic / entity layer.

### Summary
Controls 2D physics movement of the ball, handles collisions (bouncing), adjusts speed on paddle hits, emits a `bounced` signal when a paddle bounce occurs, and provides helper methods for resetting and size queries.

### Technical Details
- Extends `CharacterBody2D` and registers `class_name Ball`.
- Signals: `bounced`.
- Exported properties: `speed_increase_per_bounce`.
- Onready references: `CollisionShape2D`, two `AudioStreamPlayer2D` nodes for beeps.
- Key functions: `_physics_process(delta)`, `bounce_from_paddle(paddle_y_pos, paddle_height)`, `reset(reset_pos)`, `get_size()`, `play_beep()`.

### Business Logic
- On each paddle bounce: invert horizontal direction, adjust vertical component based on impact point, increase ball speed by `speed_increase_per_bounce`, emit `bounced`, and play a beep.
- When inactive, the ball ignores physics processing until `active` is set.

### Dependencies
- Local scene children: `CollisionShape2D`, `Beep1`, `Beep2`.
- Relies on Godot physics (`move_and_slide()`), randomness (`randf()`, `pick_random()`).

---

## File: scripts/detector.gd

### Purpose
`detector.gd` is an Area2D helper that detects when the ball exits the play area. It belongs to the environment/utility layer.

### Summary
Exposes a boolean export `is_left` and emits `ball_out(is_left)` when a `Ball` enters the detector area.

### Technical Details
- Extends `Area2D`.
- Exported property: `is_left` (boolean).
- Signal: `ball_out(is_left)`.
- Callback: `_on_body_entered(body)` emits the signal when `body is Ball`.

### Business Logic
- Used by the `Game` node to detect scoring events and attribute points to left/right players.

### Dependencies
- Depends on the `Ball` class being present in the scene and on the Area2D collision shape defined in the scene file.

---

## File: scripts/game.gd

### Purpose
Core game controller: manages game lifecycle, scoring, round resets, simulation for visualization, and connects scene components. This is the main orchestration layer.

### Summary
Wires detectors and ball signals, maintains score, starts and stops rounds, resets the game, updates HUD, and simulates ball movement to update a `Line2D` for visualization. It enforces `final_score` to end/reset the game.

### Technical Details
- Extends `Node2D`.
- Onready references: ball, paddles, detectors, `StartDelay` timer, HUD, `BallMovimentLine2D`, and `BallOutSound`.
- State: `game_area_size`, integer `score` (Vector2i), exported `final_score`.
- Key methods: `_ready()`, `_process(delta)`, `_draw()`, `reset_game()`, `reset_round()`, `_on_detector_ball_out(is_left)`, `update_line_2d(points)`, `_on_ball_bounced()`, `simulate_ball_movement(seconds)`.
- Behavior: uses `simulate_ball_movement()` to perform a frame-by-frame predictive simulation of ball path (for up to `seconds`) and instructs AI paddles where to move.

### Business Logic
- Score increments when detectors signal ball out; plays `ball_out` sound and either resets the round or the entire game when `final_score` reached.
- Supports debug controls: quit, reset scene, toggle ball debug control, and toggle visual lines.

### Dependencies
- Relies on `Ball`, `Paddle` instances and `HUD` nodes, `StartDelay` timer, and audio resources. Uses Godot API: scene tree, input actions, drawing API.

### **Screen Shake**

- **Purpose:** fornece feedback visual rápido ao jogador. Dois casos são cobertos:
	- Shake leve: disparado em colisões/rebotes para dar sensação de impacto.
	- Shake de ponto: shake mais forte e curto quando um jogador marca ponto.
- **Onde está implementado:** em `scripts/game.gd` — funções `shake_camera(amount, duration)`, `shake_light()` e `shake_point()`.
- **Como funciona (técnico):** a `Camera2D.offset` é atualizada por passos curtos com valores aleatórios dentro de um intervalo definido por `amount`. Ao final do tempo (`duration`) a câmera retorna suavemente ao offset zero usando um `SceneTreeTween` via `create_tween()`.
- **Parâmetros ajustáveis (no Inspector do nó `Game`):** `shake_amount_light`, `shake_time_light`, `shake_amount_point`, `shake_time_point`.
- **Gatilhos:** `shake_light()` é chamado em `_on_ball_bounced()`; `shake_point()` é chamado em `_on_detector_ball_out()` quando um ponto é marcado.
- **Notas:** a implementação interrompe qualquer tween de retorno em andamento antes de aplicar um novo shake para evitar conflitos.

---

## File: scripts/hud.gd

### Purpose
Simple HUD controller that updates on-screen score labels. It belongs to the presentation/UI layer.

### Summary
Provides `set_new_score(score)` and `reset_score()` to update left and right score labels.

### Technical Details
- Extends `Control` and references two `Label` nodes via `@onready`.
- No exported properties. Simple text formatting via `str()`.

### Business Logic
- Receives score vector (x = left, y = right) and updates visible labels accordingly.

### Dependencies
- Depends on the scene labels named `LeftScore` and `RightScore` and a font resource assigned in the scene.

---

## File: scripts/paddle.gd

### Purpose
Defines paddle behavior for player and AI-controlled paddles; handles input, movement, and collision with the ball. This is part of the game entity/controls layer.

### Summary
Supports both player-controlled and simple AI paddles. Reads input or AI target, applies acceleration, clamps velocity, updates global position, and calls `bounce_from_paddle()` on ball collision.

### Technical Details
- Extends `Area2D`.
- Exported properties: `is_ai`, `is_player_one`.
- Onready: collision shape reference to compute paddle height.
- Movement variables: `MAX_VELOCITY`, `acceleration`, `slow_down_delta`, `velocity`, `ai_target_y_pos`.
- Key methods: `_ready()`, `_physics_process(delta)`, `_on_body_entered(body)`, `get_ai_moviment_dir()`.

### Business Logic
- Player input mapping supports two-player controls via `_two` suffix when `is_player_one` is false.
- AI uses a simple target-follow algorithm with `accuracy_distance` threshold.
- On collision with `Ball`, calls `body.bounce_from_paddle(global_position.y, paddle_height)` to update ball direction and speed.

### Dependencies
- Requires `CollisionShape2D` size to compute paddle height, input actions configured in `project.godot`, and the `Ball` implementation.

---

## File: scenes/game.tscn

### Purpose
Scene composition for the main `Game` Node2D. This file instantiates paddles, ball, detectors, HUD, environment, audio, and timers and binds them to the `game.gd` script.

### Summary
Defines the node tree for the playable game, including resource links to scripts, packed scenes, and audio streams used by the runtime.

### Technical Details
- Scene format: Godot `.tscn` format (text). Contains `ExtResource` references to `scripts/game.gd`, `scenes/paddle.tscn`, `scenes/ball.tscn`, `scenes/wall.tscn`, `scenes/detector.tscn`, `scenes/hud.tscn`, and an audio asset.
- Nodes: Game (root Node2D), CanvasLayer -> HUD, StartDelay Timer, Environment node with walls and detectors, TheBall node with Ball instance and line renderer, ThePaddles with player instances.

### Business Logic
- This is the root scene that wires all components together and provides the structure the `game.gd` script expects.

### Dependencies
- References internal scenes and assets as ext_resources. Must be loaded by Godot engine as the main scene in `project.godot`.

---

## File: scenes/ball.tscn

### Purpose
Defines the Ball node visual, collision, audio children, and script attachment.

### Summary
Packed scene for `Ball`, linking `ball.gd`, `Beep` audio players, a rectangle collision shape, and a mesh representation for rendering.

### Technical Details
- Contains `CharacterBody2D` node with a `CollisionShape2D`, `MeshInstance2D`, and two `AudioStreamPlayer2D` nodes wired to `assets/beep1.wav` and `assets/beep2.wav`.

### Dependencies
- Depends on `scripts/ball.gd` and the audio assets.

---

## File: scenes/paddle.tscn

### Purpose
Packed scene for paddle nodes used by player and AI.

### Summary
Defines an `Area2D` with collision shape and visual mesh and connects the `body_entered` signal to `_on_body_entered` (paddle.gd).

### Dependencies
- `scripts/paddle.gd` and the rectangle collision shape (height is set in the scene).

---

## File: scenes/hud.tscn

### Purpose
HUD layout including left and right score labels.

### Summary
Defines `Control` with two `Label` nodes and assigns a custom font resource `assets/pong-score-extended.ttf`.

---

## File: scenes/detector.tscn

### Purpose
Packed `Area2D` scene used as an out-of-bounds detector at left and right sides.

### Summary
Contains a tall rectangle CollisionShape2D and wires `body_entered` to `_on_body_entered` in `detector.gd`.

---

## File: scenes/wall.tscn

### Purpose
Packed `StaticBody2D` used as top and bottom walls to bounce the ball.

### Summary
Contains `StaticBody2D` and a RectangleShape2D sized to act as horizontal barriers.

---

## File: project.godot

### Purpose
Godot project configuration file. Defines main scene, window size, input mappings, and resources.

### Summary
Specifies `run/main_scene` (the Game scene), display configuration (1280x720), and input action mappings used by scripts (paddle_up, paddle_down, quit, reset, ball control keys, etc.).

### Technical Details
- Input actions map keys for player controls and debug toggles. Engine `config_version=5` indicates Godot 4+ format.

---

## File: .gitignore

### Purpose
Repository ignores for Godot-specific files.

### Summary
Prevents engine-generated files and build artifacts from being committed.

---

## File: .editorconfig

### Purpose
Editor configuration for encoding and consistent formatting.

---

## File: .gitattributes

### Purpose
Git attributes to normalize EOL behavior.

---

## File: icon.svg

### Purpose
Project icon used by `project.godot`.

### Summary
Scalable vector graphic asset used as the application icon.

---

## Assets (audio and font)

### Purpose
Binary assets used by scenes: `beep1.wav`, `beep2.wav`, `explosion.wav`, and `pong-score-extended.ttf`.

### Summary
These are media resources referenced by scenes for sound effects and HUD font. They are binary files; the documentation will list their usage rather than content.

---

## File: scripts/*.gd.uid (meta files)

### Purpose
Small metadata UID files automatically created by Godot to track resource identifiers in the editor.

### Summary
These files are not human-authored source code; they store editor metadata and unique identifiers. They do not affect runtime behavior beyond editor bookkeeping.

---

## File: scenes/game.tscn*.tmp (temporary files)

### Purpose
Temporary scene files created by the editor (likely backups or autosave snapshots).

### Summary
They are transient and can be ignored for runtime; included in the repo possibly by accident. Do not rely on these for canonical scene configuration.

---

## File: specs/* (generated documentation files)

### Purpose
Files under `specs/` contain the generated documentation, diagrams, runtime state, and indexes created by this Autonomous Documentation Agent.

### Summary
The `specs/` directory is the authoritative documentation output and should be committed alongside source if desired. Files include `runtime.md`, `full_documentation.md`, `architecture_overview.md`, `developer_guide.md`, `api_reference.md`, `catalog.txt`, `relationships.txt`, `data_models.txt`, and `diagrams/`.

