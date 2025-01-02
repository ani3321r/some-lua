# Basic Space Shooter Game

## Description
This is a basic Space Shooter game developed using the LÖVE 2D framework. The player controls a spaceship, dodges enemies, and shoots bullets to destroy enemies. The game ends when the player runs out of lives.

## Features
- Player-controlled spaceship with smooth left and right movement.
- Enemies spawn at increasing rates as the game progresses.
- Player can shoot bullets in three directions simultaneously.
- Scoring system with a record of the highest score achieved.
- Heart icons representing player lives.
- "Game Over" screen with a "Play Again" button.

## Controls
- **Left Arrow**: Move left
- **Right Arrow**: Move right
- **Spacebar**: Shoot bullets
- **Escape**: Quit the game

## Requirements
- [LÖVE 2D](https://love2d.org/) (Version 11.0 or higher)

## Installation
1. Install LÖVE 2D from the official website.
2. Download or clone this repository.
3. Place the assets (`player.png`, `bullet.png`, `enemy.png`, `heart.png`) in the `assets/` directory.

## Running the Game
1. Navigate to the project directory.
2. Run the following command:
   ```sh
   love basic_space_shooter
   ```

## Game Logic
1. **Player Movement**:
   - The spaceship moves left or right within the window boundaries.

2. **Shooting Bullets**:
   - Press the spacebar to fire three bullets at once in a vertical direction.

3. **Enemy Behavior**:
   - Enemies spawn at random positions at the top of the screen and move downward.
   - The enemy spawn rate and speed increase as the score rises.

4. **Collision Detection**:
   - Bullets that collide with enemies destroy the enemy and increase the player's score.
   - Enemies that reach the bottom of the screen reduce the player's lives.

5. **Game Over**:
   - The game ends when the player runs out of lives.
   - A "Game Over" screen displays the player's score and highest score, along with a "Play Again" button to restart the game.

## Assets
- **Player Ship**: `assets/player.png`
- **Bullet**: `assets/bullet.png`
- **Enemy Ship**: `assets/enemy.png`
- **Heart (Lives)**: `assets/heart.png`

## Scaling and Responsiveness
- All assets are automatically scaled to fit the defined sizes in the game logic.
- The game runs in a fixed window size of 1200x800 pixels.

## License
This project is for educational and personal use. Feel free to modify and expand the game as you like!