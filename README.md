# Zelda De-make (PICO-8)

The current build of my Pico-8 game - for now, essentially a Zelda clone/demake. Still in early development.

---

## Gameplay Overview

Explore a retro-style world, solve puzzles, and defeat enemies — all within the cozy limitations of the PICO-8 fantasy console.

> Built using `zelda.p8` and external scripts: `init.lua`, `update.lua`, `draw.lua`, `general_functions.lua`, `player_functions.lua`, `enemy_functions.lua`, and `sfx_music.lua`.

---

## Screenshots

To be added as development progresses

## Getting Started

### Requirements

- [PICO-8](https://www.lexaloffle.com/pico-8.php) fantasy console (version 0.2.6b or later recommended)

### Running the Game

1. Launch PICO-8
2. From the PICO-8 command line:
   ```
   folder
   ```
   This opens the carts folder in your file explorer.
3. Place this repository folder inside the carts directory.
4. In PICO-8:
   ```
   cd zelda
   load zelda.p8
   run
   ```

---

## Controls

```
Arrow Keys - Move  
Z          - Use bomb item
X          - Sword attack
CTRL + R   - Restart game (re-run the game from initial state)
```

---

## Folder Structure

```
zelda/
├── zelda.p8                    # Main PICO-8 cart. Contains includes (as follows), art, music/sfx
├── init.lua                    # Gets included in .p8 at runtime - Contains Pico-8 _init() function 
├── update.lua                  # Gets included in .p8 at runtime - Contains Pico-8 _update() function
├── draw.lua                    # Gets included in .p8 at runtime - Contains Pico-8 _draw() function
├── general_functions.lua       # Gets included in .p8 at runtime - Utility functions
├── player_functions.lua        # Gets included in .p8 at runtime - Player specific functions
├── enemy_functions.lua         # Gets included in .p8 at runtime - Enemy specific functions
├── sfx_music.lua               # Gets included in .p8 at runtime - Sound effect and music functions
├── .gitignore
├── .gitattributes
└── README.md
```

---

## Features

- Core player functionality - move, attack, and drop bombs
- Walk over items on the ground to pick them up
- Contact with enemies or the player's own bomb explosion will result in damage to the player
- The player can deal damage to enemies by hitting them with the sword or a bomb explosion

- As noted at the top - this is a very early WIP 'alpha' build. Not yet feature complete.

---

## Built With

- PICO-8
- Git for version control
- Visual Studio Code (with Git Bash integration)

---

## Acknowledgements

- Inspired by *The Legend of Zelda*
- Thanks to the PICO-8 community and Lexaloffle