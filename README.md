# Project notes

## Godot version

Godot 3.3.2 stable 

## Project structure

```
│   .gitignore
│   default_env.tres
│   icon.png
│   icon.png.import
│   project.godot
│   README.md
├───.import
├───assets
│   ├───sounds
│   └───sprites
└───scenes
    ├───actors
    ├───levels
    └───misc

```

## Naming conventions
- Use ```snake_case``` for file names 
- Use ```snake_case``` for variable and function names
- Use ```PascalCase``` for scene names (NOT THE FILES)
- Use ```PascalCase``` for class names

## Where should go where?
- ```assets``` folder should be straightforward 
- ```actors``` folder should contain characters (players + NPC) scenes and their scripts
- ```levels``` folder should contain screens and levels scenes and their script
- Other scenes and scripts go to ```misc```