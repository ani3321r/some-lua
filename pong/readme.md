# Pong Game

A simple Pong game implemented using the LÖVE framework. This game supports both single-player and two-player modes.

## Features

- **Single-player Mode**: Play against a basic AI opponent.
- **Two-player Mode**: Compete with a friend using the same keyboard.
- **Smooth Gameplay**: Dynamic ball speed and paddle collision detection.
- **Score Tracking**: Keep track of each player's score.

## Controls

### Player 1
- **Move Up**: `W`
- **Move Down**: `S`

### Player 2 (Two-player Mode)
- **Move Up**: `Up Arrow`
- **Move Down**: `Down Arrow`

### General
- **Start Single-player Mode**: Press `1` on the menu screen.
- **Start Two-player Mode**: Press `2` on the menu screen.
- **Quit Game**: Press `Escape` at any time.

## How to Run

1. Ensure you have the [LÖVE framework](https://love2d.org/) installed on your system.
2. Save the game code into a file named `main.lua`.
3. Place the `main.lua` file inside a folder (e.g., `PongGame`).
4. Run the game using the following command:

   ```bash
   love PongGame
   ```

## Gameplay Instructions

1. Choose a game mode from the menu:
   - Press `1` for single-player mode.
   - Press `2` for two-player mode.
2. Control your paddle to hit the ball and score points when your opponent misses.
3. The game ends when you decide to quit by pressing `Escape`.

## Dependencies

- [LÖVE](https://love2d.org/) version 11.0 or higher.

## License

This game is released under the MIT License. Feel free to modify and distribute it as you like.

## Acknowledgments

Inspired by the classic Pong game, this implementation demonstrates basic game mechanics and physics using Lua and the LÖVE framework.
