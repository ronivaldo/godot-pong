# Architecture Overview

Project Type
- 2D arcade-style game (Pong clone) built with Godot Engine (Godot 4+).

Technologies Used
- Godot Engine (project config indicates 4.x features), GDScript for game logic, standard Godot scene (`.tscn`) format, Audio (WAV) and font assets.

Architectural Pattern
- Scene-based, component-oriented architecture typical of Godot projects. The structure follows a small MVC-like separation:
	- Model/Entities: `Ball`, `Paddle` (stateful game objects)
	- Controller/Orchestration: `Game` script (game lifecycle and rules)
	- View/UI: `HUD` (labels and fonts)

Logical Module Boundaries
- `scenes/` contains packed scenes for visual and collision definitions.
- `scripts/` contains behavior attached to nodes.
- `assets/` contains binary media resources.
- `specs/` contains generated documentation and diagrams.

Infrastructure Components
- No external infrastructure files (no Docker, CI, or cloud infra present in repository).

Service Relationships
- The `Game` node composes the scene and orchestrates interactions: it listens to signals from `Ball` and `Detector`, updates `HUD`, and manages `Paddle` behavior.

High-level Behavior
- The `Game` scene loads on start, the `Game` script controls rounds and scoring, `Ball` implements physics and bounce logic, `Paddle` responds to player input or simple AI, and `Detector` determines when a point is scored.

