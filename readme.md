# Love Loader

Custom menu for selecting game from multiple for Love2D.

# How it works?

If simple: just place games in `games` folder with structure like `games/yourgame/main.lua`

If technically: creates local variables functions and variables.
Creates the loop until game wasn't selected with manual event handling and redrawing.

# Things left or API

We are not keep environment super clear (except local variables ;))
so there are some variables can be used in game:

`W` and `H` variables: width and height of the screen, controlled by love.resize function.

`love.resize` and optional `resize` payload: functions called when screen size when changed and at boot.

`love.handlers.quit`: function on exit which can be called until game was selected to keep responsive or for custom love.run function.

# Fill game information

To fill game information in game folder need to create `info.ll` file.

Syntax is `k = v` with `# comments`

```
# are there needed any comments?
name = New awesome game using Love Loader
desc = Some descripion about the game.
# main = optional main file instead of `main.lua`
```
