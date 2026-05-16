# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

This is a Godot 4.6 GDScript memory-match card game. There is no package manager, no build step, and no external services. The only system dependency is the **Godot Engine 4.6.x** binary.

### Running the game

```bash
# Headless (no display needed):
godot --headless --path /workspace

# With virtual display (Xvfb must be running on :99):
export DISPLAY=:99
godot --path /workspace --rendering-driver opengl3 --display-driver x11
```

ALSA audio errors are expected in the VM (no sound card); Godot falls back to a dummy audio driver automatically.

### Running tests

Tests use the bundled GUT 9.6.0 addon (`addons/gut/`). Run all 28 tests headlessly:

```bash
godot --headless -s addons/gut/gut_cmdln.gd --path /workspace
```

GUT config is in `.gutconfig.json` (test dir: `res://tests`, prefix: `test_`).

### Linting / validation

There is no standalone GDScript linter configured. Scene and script validation can be done via the Godot import step:

```bash
godot --headless --import --quit --path /workspace
```

This will report any parse errors in `.gd` scripts or broken references in `.tscn` scenes.

### Gotchas

- The `ObjectDB instances leaked at exit` warning is normal when Godot exits in headless/import/quit modes. It is not a real leak.
- The project configures `d3d12` and Jolt Physics in `project.godot` but these are Windows/3D defaults and irrelevant to this 2D game. On Linux, use `--rendering-driver opengl3`.
- If you need a virtual display for GUI testing, start Xvfb first: `Xvfb :99 -screen 0 1024x768x24 &`
