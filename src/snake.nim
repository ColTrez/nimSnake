import os, hashes, deques, sets, random
import illwill

# initialize the TUI
proc exitProc() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

type
  ScreenInfo = object
    screenWidth: int
    screenHeight: int
    midX: int
    midY: int

type
  BoardInfo = object
    boardWidth: int
    boardHeight: int
    upperLeftX: int
    upperLeftY: int
    bottomRightX: int
    bottomRightY: int

type
  GameInfo = object
    screenInfo: ScreenInfo
    boardInfo: BoardInfo

type
  Position = object
    x: int
    y: int

type
  Direction = enum
    left, right, up, down

proc hash(pos: Position): Hash =
  var h: Hash = 0
  h = h !& hash(pos.x)
  h = h !& hash(pos.y)
  result = !$h

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

#returns true if you died
proc eatOrDieMaybe(snakeRef: ptr Deque[Position], foodRef: ptr HashSet[Position],
    boardInfo: BoardInfo): bool =
  let snakeHead = snakeRef[].peekLast
  #check to see if you DIED
  if snakeHead.x == boardInfo.upperLeftX or snakeHead.x == boardInfo.bottomRightX:
    return true
  if snakeHead.y == boardInfo.upperLeftY or snakeHead.y == boardInfo.bottomRightY:
    return true
  #check to see if you ate food
  #if foodRef[].contains(snakeHead):
    #todo: add to queue
  return false


const BOARD_WIDTH = 50
const BOARD_HEIGHT = 25
randomize()

illwillInit(fullscreen=true)
setControlCHook(exitProc)
hideCursor()

var tb = newTerminalBuffer(terminalWidth(), terminalHeight())

#get screen dimensions and board limits
let screenInfo = ScreenInfo(screenWidth: width(tb), screenHeight: height(tb),
    midX: width(tb) div 2, midY: height(tb) div 2)

let boardInfo = BoardInfo(boardWidth: BOARD_WIDTH, boardHeight: BOARD_HEIGHT,
    upperLeftX: screenInfo.midX - BOARD_WIDTH, upperLeftY: screenInfo.midY - BOARD_HEIGHT,
    bottomRightX: screenInfo.midX + BOARD_WIDTH, bottomRightY: screenInfo.midY + BOARD_HEIGHT)

let gameInfo = GameInfo(screenInfo: screenInfo, boardInfo: boardInfo)

tb.setForegroundColor(fgBlack, true)
tb.drawRect(boardInfo.upperLeftX, boardInfo.upperLeftY,
    boardInfo.bottomRightX, boardInfo.bottomRightY)
tb.setForegroundColor(fgWhite, true)
tb.write(2, 1, "Press ", fgYellow, "ESC", fgWhite,
               " or ", fgYellow, "Q", fgWhite, " to quit")

#initialize food set
var foodSet: HashSet[Position]

#initialize snek
var snake = [Position(x: screenInfo.midX-1, y: screenInfo.midY),
    Position(x: screenInfo.midX, y: screenInfo.midY),
    Position(x: screenInfo.midX+1, y: screenInfo.midY)].toDeque

#draw snek
tb.write(snake[0].x, snake[0].y, fgWhite, "#")
tb.write(snake[1].x, snake[1].y, fgWhite, "#")
tb.write(snake[2].x, snake[2].y, fgWhite, ">")

var score = 0
var movement = Direction.right

# Main event loop
while true:
  # display score
  tb.write(boardInfo.upperLeftX, boardInfo.upperLeftY - 1, fgWhite, "Score: " & $score)
  #check for death
  if eatOrDieMaybe(addr snake, addr foodSet, boardInfo):
    let offset = 4
    tb.write(screenInfo.midX-offset, screenInfo.midY, fgRed, "YOU DIED")
    tb.display()
    sleep(100)
    break
  #add food
  let foodX = rand(boardInfo.upperLeftX+1 .. boardInfo.bottomRightX-1)
  let foodY = rand(boardInfo.upperLeftY+1 .. boardInfo.bottomRightY-1)
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

