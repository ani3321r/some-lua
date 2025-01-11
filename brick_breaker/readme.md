# Brick Breaker

This is a modern, feature-rich **Breakout** game developed using [Love2D](https://love2d.org/), a 2D game development framework.

## Features

- **Dynamic Gameplay**: Break bricks using a paddle and ball.
- **Power-Ups**:
  - Expand paddle size.
  - Multi-ball power-up.
  - Lasers and more.
- **Levels**: 5 unique levels, each with distinct brick patterns and challenges.
- **Combo System**: Earn extra points by breaking bricks consecutively.
- **Particles**: Eye-catching particle effects for enhanced gameplay visuals.
- **High Scores**: Automatically saves your top 5 scores locally.

## Controls

- **Arrow Keys**: Move the paddle.
- **Spacebar**: 
  - Launch the ball.
  - Fire lasers (if equipped).
- **Mouse**: Also controls the paddle.(This is smoother)
- **Escape**: Exit the game.
- **R**: Restart the game after a game over.

## How to Play

1. Launch the game.
2. Use the paddle to bounce the ball and break bricks.
3. Collect falling power-ups for additional abilities.
4. Avoid letting the ball fall off the screen.
5. Clear all bricks to complete a level and move to the next.

## Installation and Setup

1. Ensure Love2D is installed on your system. [Download Love2D here](https://love2d.org/).
2. Clone or download this repository.
3. Run the game:
   ```bash
   love brick_breaker

## Development Notes

This game has been designed with the following features and enhancements:

- **Particle Effects**: 
  - Particle systems for ball trails and brick explosions.
  - Adds a visually appealing dynamic element during gameplay.
  
- **Dynamic Difficulty**: 
  - The ball speed gradually increases as the game progresses.
  - Brick layouts become more challenging with each level.

- **Power-Ups System**:
  - Implemented a variety of power-ups, including paddle expansion, multi-ball, laser shots, and more.
  - Power-ups fall randomly after breaking specific bricks.

- **Screen Shake**:
  - Adds an immersive experience by shaking the screen during collisions or explosions.

Feel free to extend or improve the game. Ideas for enhancements include adding new power-ups, more levels, or integrating sound effects and music.

## Contributing

Contributions to this project are welcome! Here's how you can help:

1. **Fork the Repository**:
   - Click the "Fork" button at the top of this repository.

2. **Clone Your Fork**:
   - Clone the repository to your local machine:
     ```bash
     git clone https://github.com/ani3321r/some-lua.git
     ```

3. **Create a New Branch**:
   - Create a branch for your feature or bug fix:
     ```bash
     git checkout -b feature-name
     ```

4. **Make Your Changes**:
   - Add new features, fix bugs, or improve existing code.

5. **Test Your Changes**:
   - Run the game to ensure your changes work as expected.

6. **Commit and Push**:
   - Commit your changes with a descriptive message:
     ```bash
     git commit -m "Added a new feature: feature-name"
     ```
   - Push your changes to your fork:
     ```bash
     git push origin feature-name
     ```

7. **Submit a Pull Request**:
   - Go to the original repository and submit a pull request explaining your changes.

Your contributions will be reviewed, and if approved, they’ll be merged into the main project. Thank you for helping improve the game!