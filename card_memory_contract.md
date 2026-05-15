# Card Memory Contract: Memory Match Card Game

## Mission
Build a complete, working memory match card game in Godot 
4.6 using GDScript. The agent system handles all code, 
tests, and scene file writing. Human intervention is only 
required at defined checkpoints.

## Success Criteria (Definition of Done)
- [x] 4x4 grid of 16 cards (8 pairs) renders correctly
- [x] Cards flip face-up on click
- [x] Two flipped non-matching cards flip back after 1 second
- [x] Matching pairs stay face-up
- [x] Move counter displays and increments
- [x] Win state triggers at 8 matches with "You Win!" + 
      Restart button
- [x] All unit tests pass (run headlessly with GUT; see Testing Strategy)
- [x] Game runs without errors when F5 is pressed in Godot (verify locally in editor)

## Architecture
- /scenes — .tscn files (Card.tscn, Game.tscn)
- /scripts — .gd files (card.gd, game.gd)
- /tests — GUT test files (test_card.gd, test_game.gd)
- /addons — GUT testing framework

## Tech Stack
- Godot 4.6 stable
- GDScript (no C#)
- GUT (Godot Unit Test) framework for testing
- Git for version control

## Testing Strategy
Every piece of game logic must have a corresponding unit 
test. Tests must be runnable headlessly via:
`godot --headless --script res://addons/gut/gut_cmdln.gd`

Test coverage requirements:
- Card state transitions (face-down, face-up, matched)
- Deck generation (16 cards, 8 unique pairs, shuffled)
- Match detection logic
- Win condition detection
- Move counter increment

## Phase Plan
Agents may work on phases in parallel where dependencies 
allow. Each phase must pass its tests before being marked 
complete.

### Phase 1: Card Foundation
- Card.tscn scene file
- card.gd with state machine (face_down, face_up, matched)
- test_card.gd validating all state transitions
- HUMAN CHECKPOINT: Open Card.tscn in Godot, verify it 
  renders. Run scene with Ctrl+Shift+F5, click to flip.

### Phase 2: Game Board
- Game.tscn scene file with grid layout
- game.gd: spawn 16 cards, shuffle, arrange in 4x4
- test_game.gd validating board generation
- HUMAN CHECKPOINT: Open Game.tscn in Godot, verify grid 
  renders correctly, set as main scene.

### Phase 3: Match Logic
- Signal-based card_clicked → game.gd handler
- Match checking, mismatch flip-back with 1s timer
- test_game.gd: match detection tests
- HUMAN CHECKPOINT: Run full game, play a round, verify 
  matching and mismatching both work.

### Phase 4: Game State
- Move counter UI
- Win detection and "You Win!" screen
- Restart button functionality  
- test_game.gd: move counter and win condition tests
- HUMAN CHECKPOINT: Complete a full game, verify win 
  screen and restart.

## Agent Workflow Rules

### Feedback Loop
For each task within a phase:
1. Write code
2. Write test
3. Run test headlessly
4. If fail → fix → retry (max 3 attempts before escalating)
5. If pass → commit with descriptive message
6. Move to next task in phase

### When to Stop and Ask the Human
- 3 consecutive test failures on the same logic
- Need to modify a .tscn file (prefer asking human to do 
  scene work in editor)
- Architectural decision not covered in this contract
- Scope creep request (decline and note for review)
- Any destructive operation (deleting files, rewriting 
  > 50% of a file)

### When to Proceed Without Asking
- All test failures within the 3-attempt budget
- Adding new test cases for existing logic
- Refactoring code that has test coverage
- Writing comments and documentation
- Git commits after passing tests

## Git Discipline
- Commit after every passing test suite
- Format: "Phase N: <what was completed>"
- Push after each phase checkpoint

## Out of Scope (Do Not Build)
- Sound effects
- Animations beyond basic color changes
- Difficulty modes
- Themes or skins
- Save/load functionality
- Multiplayer
- Mobile export

## Human-Only Tasks (Do Not Attempt)
The following are CAPABILITY LIMITS for agents — not 
permission gates. Agents cannot perform these regardless 
of contract permissions:

- Clicking buttons in the Godot editor application
- Setting node properties via the Inspector panel UI
- Running the game with F5 to verify visual or feel
- Visually inspecting rendered output
- Enabling plugins via Project Settings → Plugins UI

Agents CAN write .tscn scene files directly (they're 
plain text) but should:
- Use minimal property sets — only what's needed
- Reference existing UIDs only after reading the file 
  to confirm they exist
- Report when a .tscn write feels risky and request 
  human verification before proceeding
- Never modify a .tscn that wasn't created in the 
  current session without explicit human request

## Communication Protocol
At human checkpoints, agent reports:
- ✅ What was completed (linked to success criteria)
- ⚠️ Any deviations from the contract  
- 🔍 What to verify manually
- ▶️ Suggested next phase to begin