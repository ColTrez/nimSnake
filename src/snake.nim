import os, deques, random, unicode, illwill
import procsAndTypes

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

tb.setForegroundColor(fgWhite, true)
tb.drawRect(boardInfo.upperLeftX, boardInfo.upperLeftY,
    boardInfo.bottomRightX, boardInfo.bottomRightY)
tb.setForegroundColor(fgWhite, true)
tb.write(2, 1, "Press ", fgYellow, "ESC", fgWhite,
               " or ", fgYellow, "Q", fgWhite, " to quit")

#initialize snek
var snake = [Position(x: screenInfo.midX-1, y: screenInfo.midY),
    Position(x: screenInfo.midX, y: screenInfo.midY),
    Position(x: screenInfo.midX+1, y: screenInfo.midY)].toDeque

#draw snek
tb.write(snake[0].x, snake[0].y, fgWhite, "#")
tb.write(snake[1].x, snake[1].y, fgWhite, "#")
tb.write(snake[2].x, snake[2].y, fgWhite, "@")

var score = 0
var movement = Direction.right

#add food
var food = placeFood(boardInfo, tb)

while true:
  # display score
  tb.write(boardInfo.upperLeftX, boardInfo.upperLeftY - 1, fgWhite, "Score: " & $score)
  #move snek
  let oldHead = snake.peekLast
  tb.write(oldHead.x, oldHead.y, fgWhite, "#")
  let movementPos = directionAsPosition(movement)
  let newHead = Position(x: oldHead.x + movementPos.x, y: oldHead.y + movementPos.y)
  snake.addLast(newHead)
  #check to see if you hit a wall
  if newHead.x == boardInfo.upperLeftX or newHead.x == boardInfo.bottomRightX or
      newHead.y == boardInfo.upperLeftY or newHead.y == boardInfo.bottomRightY:
        youDied(tb, screenInfo)
        exitProc()
  let charAhead = tb[newHead.x, newHead.y].ch
  case charAhead:
    of Rune('#'):
      # snake has ran into its own body and should DIE
      youDied(tb, screenInfo)
      exitProc()
    of Rune('*'):
      # snake has ran into some food and should get bigger
      score = score + 1
      tb.write(newHead.x, newHead.y, fgGreen, "@")
      food = placeFood(boardInfo, tb)
    else:
      #snake just moved with no special event
      let oldButt = snake.popFirst
      tb.write(oldButt.x, oldButt.y, fgBlack, " ")
      tb.write(newHead.x, newHead.y, fgGreen, "@")
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
  sleep(60)

exitProc()
