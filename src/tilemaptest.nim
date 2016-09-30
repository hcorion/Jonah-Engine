import jonah
import chipmunk
import csfml, csfml_graphics, csfml_system
import strutils
import math, random

var
  gameHeight = 640.0
  gameWidth = 480.0
  goSeq = newSeq[jonah.GameObject](0)
var space = newSpace()
var gravity = v(0, 500f)
space.gravity = gravity
space.iterations = 10
type
  exampleSSIntRect = array[3, IntRect]
let spriteSheetIntRects: exampleSSIntRect = [
  IntRect(left: 161, top: 69, width: 28, height: 27),#The tree
  IntRect(left: 67, top: 68, width: 15, height: 15),#the money
  IntRect(left: 83, top: 67, width: 16, height: 16)#the bucket
  ]
let level =
    [
        0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10, 11,
        12, 13, 14, 15,
        16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
        48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
        64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 1, 1, 1, 2, 0, 0,
        0, 0, 1, 0, 3, 0, 2, 2, 0, 0, 1, 1, 1, 1, 2, 0,
        2, 0, 1, 0, 3, 0, 2, 2, 2, 0, 1, 1, 1, 1, 1, 1,
        0, 0, 1, 0, 3, 2, 2, 2, 0, 0, 0, 0, 1, 1, 1, 1
    ]

##
#Tilemap section
##
var m_vertices*: VertexArray
var spriteSheet = newTexture("example-tileset.png")
proc createTileMap[I](width, height: int, level: array[I, int], tileSize: Vect, scale: float = 1.0f, blankNumber: int = 0, usePhysics: bool = false): bool =
  m_vertices = newVertexArray(PrimitiveType.Quads)
  var count: int = 0
  var drawHeight: int = 0
  var drawWidth: int = 0
  var spriteHeight: int = 0
  for i in 0..width*height:
    if width*height > level.len:
      echo "ERROR: Declaring a size that is larger than the level array length!"
      break
    if drawWidth >= width:
      drawHeight += 1
      drawWidth = 0
      spriteHeight += 1
      echo "yeah"
    #if spriteSheet.size.y < drawHeight:
    # spriteHeight += 1
    #elif spriteHeight > spriteSheet.size.y:
    #  spriteHeight = 0
    var xTileSize = tileSize.x * scale
    var yTileSize = tileSize.y * scale
    var spriteWidth = level[i]
    var spritePosX: int = 0
    var spritePosY: int = 0
    var texting: int = 0 
    texting = ((level[i].toFloat * tileSize.x) / spriteSheet.size.x.toFloat).floor.toInt
    var spriteWidthCurrent: float
    #if (level[i].toFloat * tileSize.x).toInt >= (int)spriteSheet.size.y.toFloat:
      
    spritePosX = ((int)level[i].toFloat * tileSize.x) - spriteSheet.size.x * texting
      
      
    #else:
    #  echo "yas!"
    #  spritePosX = ((int)level[i].toFloat * tileSize.x)
      #spriteWidthCurrent = 
      #texting = 1
    spriteWidthCurrent = (texting).toFloat * tileSize.y
    echo "texting variable is: ", texting
    echo "level id: ", (level[i].toFloat * tileSize.x).toInt
    echo "spriteWidthCurrent: ", spriteWidthCurrent
    m_vertices.append vertex(vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize),                             White, vec2(spritePosX.toFloat, spriteWidthCurrent))
    m_vertices.append vertex(vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize),               White, vec2(spritePosX.toFloat + tileSize.x, spriteWidthCurrent))
    m_vertices.append vertex(vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize + (yTileSize)), White, vec2(spritePosX.toFloat + tileSize.x, spriteWidthCurrent + tileSize.y))
    m_vertices.append vertex(vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize + (yTileSize)),               White, vec2(spritePosX.toFloat, spriteWidthCurrent + tileSize.y))
    echo m_vertices[i].position
    #m_vertices.append vertex(vec2((i + 1).toFloat * tileSize.x * scale, j.toFloat * tileSize.y * scale), White, vec2((tu + 1) * tileSize.x.toInt, tv * tileSize.y.toInt))
    #m_vertices.append vertex(vec2((i + 1).toFloat * tileSize.x * scale, (j + 1).toFloat * tileSize.y * scale), White, vec2((tu + 1) * tileSize.x.toInt, (tv + 1) * tileSize.y.toInt))
    #m_vertices.append vertex(vec2(i.toFloat * tileSize.x * scale, (j + 1).toFloat * tileSize.y * scale), White, vec2(tu * tileSize.x.toInt, (tv + 1) * tileSize.y.toInt))
    drawWidth += 1

  for i in countup(0, width-1):
    if true:
      break
    for j in countup(0, height-1):
      
      #NOTE! Algorithm renders them from top to bottom
      #var tileNumber: int = level[i + j * width]
      #var tu: int = (tileNumber) mod (spriteSheet.size.x / tileSize.x.toInt).toInt
      #var tv: int = (int)tileNumber / ((int)spriteSheet.size.x / (int)tileSize.x.toInt)
      var newColor = White
      if count == 0:
        newColor = Red
      elif count == 1:
        newColor = Green
      elif count == 2:
        newColor = Blue
      elif count == 3:
        newColor = Black
      elif count == 4:
        newColor = Magenta
      else:
        newColor = Yellow
      #m_vertices.append vertex(vec2(i.toFloat * tileSize.x * scale, j.toFloat * tileSize.y * scale), newColor, vec2(tu * tileSize.x.toInt, tv * tileSize.y.toInt))
      #m_vertices.append vertex(vec2((i + 1).toFloat * tileSize.x * scale, j.toFloat * tileSize.y * scale), newColor, vec2((tu + 1) * tileSize.x.toInt, tv * tileSize.y.toInt))
      #m_vertices.append vertex(vec2((i + 1).toFloat * tileSize.x * scale, (j + 1).toFloat * tileSize.y * scale), White, vec2((tu + 1) * tileSize.x.toInt, (tv + 1) * tileSize.y.toInt))
      #m_vertices.append vertex(vec2(i.toFloat * tileSize.x * scale, (j + 1).toFloat * tileSize.y * scale), White, vec2(tu * tileSize.x.toInt, (tv + 1) * tileSize.y.toInt))
      echo "######"
      echo m_vertices[count].position
      echo m_vertices[count+1].position
      echo m_vertices[count+2].position
      echo m_vertices[count+3].position
      echo count
      echo m_vertices[count].texCoords
      echo m_vertices[count+1].texCoords
      echo m_vertices[count+2].texCoords
      echo m_vertices[count+3].texCoords
      #echo level[count]
      if level[count] == blankNumber:
        echo m_vertices[count+1].position.x
        for d in 0..3:
          echo d
          var ground = newSegmentShape(space.staticBody, v(m_vertices[count-1+d].position.x, m_vertices[count-1+d].position.y), v(m_vertices[count+d].position.x, m_vertices[count+d].position.y), 0)
          ground.friction = 20.0
          discard space.addShape(ground)
      count += 1



  return true



var test: Vect = Vect(x:16, y: 16)
#discard createTileMap(11, 7, level, test, 2.0f, 16)
var max = sqrt(level.len.toFloat).toInt
#echo max
#echo level.len
discard createTileMap(12, 7, level, test, 3.0f, 22)








##

##
var window = newRenderWindow(
  videoMode((cint)gameHeight, (cint)gameWidth), "TEST", WindowStyle.Default)
#gameObject = (SpriteType.rectangle, rbType.none)
#initGameObject(gameObject)
window.frameRateLimit = 60
window.verticalSyncEnabled = true
#var gameObject = jonah.initGameObject(SpriteType.rectangle, rbType.rectangle, newTexture("p1.png"), space, width = 200, height = 200, mass = 0.1f, position = v(110, 110))

var ground = newSegmentShape(space.staticBody, v(0, gameHeight - 160), v(gameWidth + 160, gameHeight - 160), 0)
ground.friction = 20.0
discard space.addShape(ground)
var tex*: Texture = newTexture("p1.png")

var intRect = IntRect(left: 0, top: 0, width: tex.size.x, height: tex.size.y)

var player = jonah.initGameObject(SpriteType.rectangle, rbType.rectangle, tex, intRect, space, 20, 20, mass = 0.1f, position = v(110, 110))
player.body.torque = -2000.0f
goSeq.add(player)

var font = newFont("Hack-Regular.ttf")
var rotation = newText("x: 0, y: 0", font, 20)
rotation.position = vec2(170.0, 150.0)
rotation.color = Black

#Main loop
while window.open:
  space.step(1/60)
  var event: Event
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      window.close()
      break
    elif event.kind == csfml.EventType.MouseButtonReleased:
      var gameObject = jonah.initGameObject(SpriteType.rectangle, rbType.circle, spriteSheet, spriteSheetIntRects[random(spriteSheetIntRects.len)], space, 40, 40, mass = 0.1f, position = v(110, 110))
      gameObject.body.position = v((float)mouse_getPosition(window).x, (float)mouse_getPosition(window).y)
      gameObject.physicsShape.friction= 20
      goSeq.add(gameObject)
  if (keyboard_isKeyPressed(KeyCode.W)):
    player.body.applyForceAtWorldPoint(v(0, -90), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.S)):
    player.body.applyForceAtWorldPoint(v(0, 90), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.A)):
    player.body.applyForceAtWorldPoint(v(-90, 0), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.D)):
    player.body.applyForceAtWorldPoint(v(90, 0), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.F)):
    quit()
  window.clear(White)
  #var newIntRect = IntRect(left: 50, top: 50, width: 50, height: 200)
  #player.intRect = newIntRect
  window.draw(rotation)
  var rend = renderStates()
  rend.texture = spriteSheet
  window.draw(m_vertices, rend)
  for obj in goSeq:
    window.drawGameObject(obj)
  #goSeq[0].intRect.left = goSeq[0].intRect.left + 1
  #goSeq[0].intRect.top = goSeq[0].intRect.top + 1
  #window.drawVertexArray()
  #var newStr = ("x: ", cast[string](player.body.position.x), " y: ", cast[string](player.body.position.y))
  #echo player.body.position.x
  rotation.str = formatFloat(radToDeg(vtoangle(player.body.rotation)))
  rotation.position = vec2(player.body.position.x - 40, player.body.position.y - 40)
  #window.drawGameObject(gameObject)
  window.display
