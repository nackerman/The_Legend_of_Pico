# The Legend of Pico - A Procedurally Generated Roguelike Dungeon Game

The current build of my Pico-8 game, which is still in development.

---

## Design Manifesto

The core ethos of this project is to create a multi-floored dungeon experience inspired by the original Legend of Zelda, while drawing from other entries in the series for added flavor. The intention is to include combat rooms, puzzle rooms, shops where health potions and items can be purchased, as well as boss-fights at the end of each floor. Ideally, there will be three floors to clear in total, in any given run.

Whether all of that can be squeezed into Pico-8’s token and character limits remains to be seen.

## Current Progress

First, the player control mechanics (i.e., movement, attacking, dropping bombs, collecting items, taking and dealing damage) were sorted out in the 'development room', which has since been renamed to the 'endless_demo' room. Near the top of the init.lua file, there is a variable assignment:

```Lua
game_mode = "normal"
```

If this game_mode variable is instead set to "endless_demo", the player will face an onslaught of enemies. As each enemy is defeated, a new one will spawn in at the edge of the screen. Note that pathing for 'ground' enemies (i.e., slimes and skeletons, not bats) still needs work. The player can't walk through 'wall' tiles, as is intended - but the ground enemies can.

In normal mode, the player spawns into a dungeon room, complete with outer walls and doors. Currently, this dungeon state is preconfigured, and void of enemies or puzzles. The code to transition between rooms and bomb open "secret room" entrances is now functional, along with a room transition effect when the player walks through a door. The framework for dungeon traversal is in place - the next step is to procedurally generate floor layouts for the player to explore.

---

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
**Keyboard Controls**
- Arrow Keys : Move  
- X          : Sword attack
- Z          : Use bomb item
- CTRL + R   : Restart game (re-run the game from initial state)
```

---

## Files and Folder Structure

The only code that the main pico-8 file (i.e., 'zelda.p8') contains consists of #include statements that pull in the relevant code from the other lua files in the folder into the .p8 file at runtime. The art and audio are also included in the pico-8 file, and were constructed within the Pico-8 application itself.

> Built using `zelda.p8` and external scripts: `init.lua`, `update.lua`, `draw.lua`, `general_functions.lua`, `player_functions.lua`, `enemy_functions.lua`, and `sfx_music.lua`.

```
Legend_of_Pico/
├── Legend_of_Pico.p8           # Main PICO-8 cart. Contains includes (as follows), art, music/sfx
├── init.lua                    # Included at runtime - Contains Pico-8 _init() function 
├── update.lua                  # Included at runtime - Contains Pico-8 _update() function
├── draw.lua                    # Included at runtime - Contains Pico-8 _draw() function
├── general_functions.lua       # Included at runtime - Utility functions
├── player_functions.lua        # Included at runtime - Player specific functions
├── enemy_functions.lua         # Included at runtime - Enemy specific functions
├── sfx_music.lua               # Included at runtime - Sound effect and music functions
├── .gitignore
├── .gitattributes
└── README.md
```

---

## Built With

- PICO-8 Fantasy Console
- Git Desktop (and GitHub) for version control
- Visual Studio Code (with Git Bash integration)
- FL Studio, for playing with melodies outside of the constraints of the Pico-8 audio tracker.
- Aesprite, for test sprite work outside of the constraints of the Pico-8 sprite and map editors.

---

## License

The code in this project is licensed under the [MIT License](LICENSE).

Note: This project contains derivative works inspired by Nintendo's *Legend of Zelda* series, including character designs and musical melodies. These elements are not licensed under the MIT license and remain the property of their respective copyright holders.

This project is intended for educational and non-commercial purposes only.

## Acknowledgements

- Inspired by *The Legend of Zelda* series
- Thanks to the PICO-8 community and Lexaloffle
- Thanks to my friends and family, who have provided encouragement and support