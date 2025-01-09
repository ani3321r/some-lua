# Tetris

A feature-rich Tetris implementation using the LÖVE 2D game framework.

## Features

- Ghost piece preview
- Hold piece functionality 
- Next piece preview
- Combo system
- Particle effects and screen shake
- High score tracking
- Level progression
- Pause functionality

## Controls

- **Left/Right Arrow**: Move piece
- **Down Arrow**: Soft drop
- **Space**: Hard drop
- **Up Arrow/X**: Rotate clockwise
- **Z**: Rotate counter-clockwise
- **C/Left Shift**: Hold piece
- **G**: Toggle ghost piece
- **R**: Reset game
- **Escape**: Pause/Unpause

## Game Mechanics

- Level increases every 10 lines cleared
- Score system based on lines cleared, level, and combo multiplier
- Piece generation uses the "bag" system for fair distribution
- Wall kick system for rotation near boundaries

## Technical Details

- Grid size: 10x20
- Written in Lua using LÖVE framework
- Modern Tetris features:
  - Super Rotation System (SRS)
  - Hold piece
  - Ghost piece
  - Hard/soft drop
  - Combo system

## Installation

1. Install LÖVE framework from [love2d.org](https://love2d.org)
2. Clone this repository
3. Run the game using `love simple_tetris` in the project directory

## Credits

Developed using LÖVE 2D game framework. Color scheme based on standard Tetris guidelines.