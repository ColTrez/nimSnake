import os, strutils, deques
import illwill

# 1. Initialise terminal in fullscreen mode and make sure we restore the state
# of the terminal state when exiting.
proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

type
  Position = object
    x: int
    y: int

type
  Direction = enum
    left, right, up, down


illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()

# 2. We will construct the next frame to be displayed in this buffer and then
# just instruct the library to display its contents to the actual terminal
# (double buffering is enabled by default; only the differences from the
# previous frame will be actually printed to the terminal).
var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

#get screen dimensions and board limits
let screenWidth = width(tb)
let screenHeight = height(tb)
let boardWidth = 50
let boardHeight = 25
let midX = screenWidth div 2
let midY = screenHeight div 2
let upperLeftX = midX - boardWidth
let upperLeftY = midY - boardHeight
let bottomRightX = midX + boardWidth
let bottomRightY = midY + boardHeight

# 3. Display some simple static UI that doesn't change from frame to frame.
tb.setForegroundColor(fgBlack, true)
tb.drawRect(upperLeftX, upperLeftY, bottomRightX, bottomRightY)


tb.write(2, 1, fgWhite, "Press any key to display its name")
tb.write(2, 2, "Press ", fgYellow, "ESC", fgWhite,
               " or ", fgYellow, "Q", fgWhite, " to quit")


#initialize snek
var snake = [Position(x: midX-1, y: midY),
    Position(x: midX, y: midY),
    Position(x: midX+1, y: midY)].toDeque

#draw snek
tb.write(snake[0].x, snake[0].y, fgWhite, "#")
tb.write(snake[1].x, snake[1].y, fgWhite, "#")
tb.write(snake[2].x, snake[2].y, fgWhite, ">")

var score = 0
var movement = Direction.right

# Main event loop
while true:
  # display score
  tb.write(upperLeftX, upperLeftY - 1, fgWhite, "Score: " & $score)
  #read key press and update movement
  var key = getKey()
  case key
  #of Key.None: discard
  of Key.Right: movement = Direction.right
  of Key.Left: movement = Direction.left
  of Key.Up: movement = Direction.up
  of Key.Down: movement = Direction.down
  of Key.Escape, Key.Q: exitProc()
  else:
    discard

  tb.display()
  sleep(20)

