# Developer Guide

Setup
- Install Godot 4.x (matching the project's config version). Open the project folder in the Godot editor.
- The main scene is configured in `project.godot` (`run/main_scene`). Press Play in the editor to run the game.

Dependencies and Tools
- Godot editor (no external libraries required). The project uses standard Godot resources (AudioStream, FontFile).

How to Run
- Open Godot, choose `Import` or `Open` the project folder, then run the main scene or click `Play`.

Debugging
- Use Godot remote debugger and the `print()` function inside GDScript for quick tracing.
- Input actions are defined in `project.godot` (paddle_up/down, reset, quit, debug toggles).

Extending the System
- To add a new sound or font, place it in `assets/` and update the relevant scene to reference it.
- To add new gameplay rules, modify `scripts/game.gd` and ensure scene nodes referenced by the script have the expected names.

Code Style
- Use descriptive names for nodes and signals. Follow GDScript idioms: `snake_case` for functions and variables, `PascalCase` for class names when using `class_name`.
- Keep logic that manipulates scene nodes inside the controller (`game.gd`) and entity-specific behavior inside their respective scripts (`ball.gd`, `paddle.gd`).

Contribution Guidelines
- Run the game locally and ensure changes do not break the main scene.
- Keep commits focused and document behavior changes in commit messages.

