import os, deques, random
import illwill

# initialize the TUI
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

proc moveSnake(snakeRef: ptr Deque[Position], direction: Direction) =
  let snakeHead = snakeRef[].peekLast
  var newHead: Position
  case direction:
    of Direction.up:
      newHead = Position(x: snakeHead.x, y: snakeHead.y-1)
    of Direction.down:
      newHead = Position(x: snakeHead.x, y: snakeHead.y+1)
    of Direction.right:
      newHead = Position(x: snakeHead.x+1, y: snakeHead.y)
    of Direction.left:
      newHead = Position(x: snakeHead.x-1, y: snakeHead.y)
  discard snakeRef[].popFirst
  snakeRef[].addLast(newHead)

randomize()

illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()

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

tb.setForegroundColor(fgBlack, true)
tb.drawRect(upperLeftX, upperLeftY, bottomRightX, bottomRightY)
tb.setForegroundColor(fgWhite, true)
tb.write(2, 1, "Press ", fgYellow, "ESC", fgWhite,
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
  #add food
  let foodX = rand(upperLeftX+1 .. bottomRightX-1)
  let foodY = rand(upperLeftY+1 .. bottomRightY-1)
  tb.write(foodX, foodY, fgYellow, "*")
  #move snek
  let oldHead = snake.peekLast
  let oldButt = snake.peekFirst
  tb.write(oldHead.x, oldHead.y, fgWhite, "#")
  moveSnake(addr snake, movement)
  let newHead = snake.peekLast
  tb.write(newHead.x, newHead.y, fgGreen, "@")
  tb.write(oldButt.x, oldButt.y, fgBlack, " ")
  #read key press and update movement
  var key = getKey()
  case key
  of Key.Right, Key.D, Key.L:
    if movement != Direction.left:
      movement = Direction.right
  of Key.Left, Key.A, Key.H:
    if movement != Direction.right:
      movement = Direction.left
  of Key.Up, Key.W, Key.K:
    if movement != Direction.down:
      movement = Direction.up
  of Key.Down, Key.S, Key.J:
    if movement != Direction.up:
      movement = Direction.down
  of Key.Escape, Key.Q: exitProc()
  else:
    discard

  tb.display()
  sleep(55)

