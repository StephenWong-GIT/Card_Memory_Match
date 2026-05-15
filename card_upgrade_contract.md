# Memory Match — Polish & Aesthetic Upgrade Contract

> Governing specification for autonomous polish work on 
> the existing memory match game. Agents must read this 
> file in full before acting. Re-read on context refresh.
> This contract assumes the base game (Phases 1-4) is 
> complete, working, and tested.

---

## 1. Mission

Transform the functionally-complete memory match game 
into a visually polished, satisfying-to-play experience 
through theming, animation, transitions, and micro-
interactions. Execute autonomously with a strict 
red-green-refactor TDD loop. Human intervention only 
when escalation triggers fire.

---

## 2. Definition of Done

The polish pass is complete when ALL of these are true:

- [ ] All pre-existing tests still pass (no regression)
- [ ] Game still completes a full round without errors
- [ ] Cards have a flip animation (not instant color change)
- [ ] Card hover state with visual lift/glow feedback
- [ ] Match success has a celebratory visual effect
- [ ] Mismatch has a "wrong" visual feedback (shake/flash)
- [ ] Win screen has entrance animation
- [ ] Restart button has hover and press states
- [ ] Background is not flat default gray — has intentional 
      color/gradient/pattern
- [ ] Move counter has subtle animation on increment
- [ ] Cohesive color palette applied via Theme resource
- [ ] Typography improved (custom font OR styled default)
- [ ] No new console errors or warnings introduced

---

## 3. Scope — IN

You may modify or add:

- `theme.tres` (new Godot Theme resource)
- StyleBox resources for buttons, panels, labels
- Tween-based animations in existing scripts
- New animation methods on Card and Game scripts
- Background ColorRect, gradient, or TextureRect in 
  Game.tscn
- New Label fonts (use Godot's default fonts or 
  free fonts from Godot Asset Library only)
- AnimationPlayer nodes for complex sequences
- Particle effects (CPUParticles2D only — no shaders 
  in this pass)
- Modulate, scale, rotation, position tweens
- Visual properties of existing nodes
- Z-index ordering for layering effects

## 4. Scope — OUT

You may NOT:

- Change game logic (matching, scoring, win condition)
- Change the 4×4 grid structure or card count
- Add new gameplay features (timers, difficulty, etc.)
- Modify test files for existing behavior
- Add external dependencies beyond what's already 
  installed
- Use GLSL shaders (defer to later phase)
- Use proprietary fonts or paid assets
- Change the file structure or move existing files
- Refactor game.gd or card.gd logic — only ADD 
  animation/visual methods
- Modify .cursorrules or this contract

If a task seems to require an OUT-OF-SCOPE change, 
escalate. Do not work around it.

---

## 5. The Red-Green-Refactor Loop

This is the core autonomous cycle. Follow it strictly.

### For each polish task:

**1. RED — Establish baseline**
- Run full test suite headlessly
- Confirm all tests pass (this is the green baseline)
- If any test fails BEFORE making changes, STOP and 
  escalate — the project is in a bad state
- Document baseline: "X tests passing"

**2. GREEN — Make the change**
- Implement the smallest possible change for the task
- Re-run full test suite headlessly
- Confirm same X tests still pass
- If tests fail: revert the change, analyze, retry 
  (max 3 attempts per task)
- If passes: confirm scene still opens by running 
  `godot --headless --check-only res://scenes/Game.tscn`

**3. REFACTOR — Clean up**
- Review the change for clarity
- Add comments explaining WHY (not what)
- Verify no dead code introduced
- Run tests one final time
- Commit with descriptive message

**4. SANITY — Cascading effect check**
After every 3 tasks, do a fuller verification:
- Run all tests
- Open Game.tscn headlessly to confirm no parse errors
- Open Card.tscn headlessly to confirm no parse errors
- Check git status — no unexpected file changes
- Read the last 3 commit diffs to confirm changes 
  match descriptions

If sanity check fails: stop, escalate, do not continue.

---

## 6. Headless Verification Commands

Use these exact commands:

```bash
# Run full test suite
godot --headless -s res://addons/gut/gut_cmdln.gd --path .

# Verify a scene loads without errors  
godot --headless --check-only --path . res://scenes/Game.tscn
godot --headless --check-only --path . res://scenes/Card.tscn

# Quick syntax check on a script
godot --headless --check-only --path . res://scripts/game.gd
godot --headless --check-only --path . res://scripts/card.gd
```

If `godot` is not on PATH, fall back to the absolute 
path the human configured. Try in this order:
1. `godot` (PATH)
2. `D:/Dev/Tools/Godot/Godot_v4.6.2-stable_win64.exe`
3. Escalate if neither works

---

## 7. Task Priority Order

Work through tasks in this order. Do not skip ahead. 
Each task is its own red-green-refactor cycle.

### Tier 1: Foundation (do first)
1. Create `theme.tres` resource with a cohesive color 
   palette (4-6 colors total: bg, primary, secondary, 
   accent, text, success/error)
2. Apply theme to Game.tscn root node
3. Replace flat gray background with a styled background 
   (gradient ColorRect or panel with StyleBox)

### Tier 2: Card polish
4. Card hover state — slight scale up (1.05), modulate 
   brighter, smooth tween
5. Card press state — slight scale down (0.97) for tactile feel
6. Card flip animation — replace instant color change 
   with a tween (scale X 1.0 → 0.0 → 1.0 with color 
   change at the midpoint, ~0.3s total)
7. Matched cards subtle pulse or glow (modulate animation)

### Tier 3: Feedback effects  
8. Mismatch shake — when two cards don't match, brief 
   shake on both before flipping back
9. Match success effect — brief celebration (scale punch, 
   color flash, or CPUParticles2D burst)

### Tier 4: UI polish
10. Move counter increment animation (scale punch on change)
11. Win screen entrance animation (fade in, slide up, 
    scale from 0)
12. Restart button hover/press states with smooth tweens
13. Typography pass — adjust label fonts, sizes, spacing 
    for visual hierarchy

### Tier 5: Final pass
14. Ensure consistent animation timing/easing across game
15. Add subtle ambient motion (e.g., gentle background 
    color shift, or breathing effect on idle UI)

If time/iterations remain after Tier 5, STOP. Do not 
invent new tasks. Polish has diminishing returns.

---

## 8. Hard Limits (Autonomous Termination)

Stop and escalate when ANY of these trigger:

- **Iteration cap:** 40 total commits across all tasks
- **Failure cap:** Any single task fails 3 times in a row
- **Cascading failure:** A sanity check fails after a 
  previously-passing baseline
- **Time cap:** If using a timer mechanism, 6 hours of 
  wall-clock work
- **Cost cap:** If you have visibility into request 
  consumption, halt at any apparent runaway pattern
- **Scope creep:** Any task that requires touching 
  game logic, tests, or out-of-scope files
- **Unknown errors:** Any error message you cannot 
  diagnose after 1 attempt

Halt = commit current state, write a final report, stop.

---

## 9. Escalation Report Format

When halting (success or failure), produce this report 
as a markdown file at `POLISH_REPORT.md`:

```markdown
# Polish Pass Report

## Status
[COMPLETE | HALTED_SCOPE | HALTED_FAILURE | HALTED_LIMIT]

## Tasks Completed
- [x] Task 1:  — commit 
- [x] Task 2:  — commit 
...

## Tasks Skipped or Failed
- [ ] Task N:  — reason: 

## Test Status
- Tests at start: X passing, 0 failing
- Tests at end: X passing, Y failing
- Regressions: 

## Files Modified


## Recommendations for Human Review
- Visual aspects to verify: 
- Anything subjective the human should judge
- Suggested next polish areas not covered

## Git Summary
- Branch: 
- Total commits: N
- First commit:  
- Last commit:  
```

---

## 10. Git Discipline

- Work on branch `polish-pass-1` (create if not exists)
- Commit after each successful red-green-refactor cycle
- Commit message format: `Polish: <Tier N.task> <brief description>`
- Push every 5 commits (in case of crash)
- Do NOT merge to main — that's a human decision
- Do NOT delete or rebase any existing commits

---

## 11. Anti-Patterns (Explicitly Forbidden)

- Faking success on a task you couldn't complete
- Skipping the test run between tasks
- Making large multi-task commits
- "While I'm here, I also fixed..." type scope creep
- Modifying tests to make them pass
- Disabling tests to bypass failures
- Using `@warning_ignore` to silence warnings without 
  addressing them
- Hardcoding values that should be theme constants
- Copy-pasting animation code instead of extracting 
  reusable methods after the 2nd duplication

---

## 12. Honesty Clause

If you cannot verify a task worked (e.g., headless 
Godot not available, test runner broken), say so 
explicitly. Do not assume success. Mark the task as 
"completed pending human verification" in the report.

Honest failure > apparent success.

---

## 13. Subagent Usage

You MAY spawn subagents for:
- Parallel work on independent tasks within a tier 
  (e.g., one agent does theme.tres while another does 
  card hover)

You may NOT:
- Spawn subagents that operate without reading this 
  contract first
- Have subagents commit independently — main agent 
  reviews and commits
- Spawn subagents recursively (no subagent spawning 
  its own subagents)

---

## 14. Final Note on Aesthetic Judgment

You cannot see the result. Trust the contract's task 
list. Do not invent "improvements" based on what you 
think looks good. Implement the specified animations 
with sensible default parameters (durations 0.2-0.4s 
for most tweens, easing CUBIC_OUT for entrances, 
CUBIC_IN for exits). The human will judge aesthetics 
on wake-up.

If a tween parameter feels arbitrary, pick a reasonable 
value and move on. Do not iterate on aesthetics — 
iterate on whether things work.