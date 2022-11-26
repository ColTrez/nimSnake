import os, random, unicode
import illwill

proc exitProc*() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

type
  ScreenInfo* = object
    screenWidth*: int
    screenHeight*: int
    midX*: int
    midY*: int

type
  BoardInfo* = object
    boardWidth*: int
    boardHeight*: int
    upperLeftX*: int
    upperLeftY*: int
    bottomRightX*: int
    bottomRightY*: int

type
  GameInfo* = object
    screenInfo*: ScreenInfo
    boardInfo*: BoardInfo

type
  Position* = object
    x*: int
    y*: int

type
  Direction* = enum
    left, right, up, down

proc directionAsPosition*(direction: Direction): Position =
  case direction:
    of Direction.up:
      return Position(x: 0, y: -1)
    of Direction.down:
      return Position(x: 0, y: 1)
    of Direction.right:
      return Position(x: 1, y: 0)
    of Direction.left:
      return Position(x: -1, y: 0)

proc youDied*(tb: var TerminalBuffer, screenInfo: ScreenInfo) =
  let offset = 4
  tb.write(screenInfo.midX-offset, screenInfo.midY, fgRed, "YOU DIED")
  tb.display()
  sleep(1000)

proc findFoodSpot(boardInfo: BoardInfo, distance: int, center: Position): Position =
  var leftX, rightX, upperY, lowerY: int
  # place the food within distance of center position
  if center.x - distance < boardInfo.upperLeftX+1:
    leftX = boardInfo.upperLeftX+1
  else:
    leftX = center.x - distance
  if center.x + distance > boardInfo.bottomRightX-1:
    rightX = boardInfo.bottomRightX-1
  else:
    rightX = center.x + distance
  if center.y - distance < boardInfo.upperLeftY+1:
    upperY = boardInfo.upperLeftY+1
  else:
    upperY = center.y - distance
  if center.y + distance > boardInfo.bottomRightY-1:
    lowerY = boardInfo.bottomRightY-1
  else:
    lowerY = center.y + distance

  let foodX = rand(leftX .. rightX)
  let foodY = rand(upperY .. lowerY)
  return Position(x:foodX, y:foodY)

proc placeFood*(boardInfo: BoardInfo, tb: var TerminalBuffer, distance: int, center: Position): Position =
  var food = findFoodSpot(boardInfo, distance, center)
  var foodSpot = tb[food.x, food.y].ch
  while foodSpot == Rune('@') or foodSpot == Rune('#'):
    food = findFoodSpot(boardInfo, distance, center)
    foodSpot = tb[food.x, food.y].ch
  tb.write(food.x, food.y, fgCyan, "*")
  return food