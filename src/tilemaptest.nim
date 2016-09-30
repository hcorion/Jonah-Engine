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
        16, 30, 31, 31, 32, 16, 16, 30, 31, 31,
        16, 16, 16, 16, 16, 16, 16, 16, 16, 46,
        16, 16, 16, 16, 16, 16, 16, 16, 16, 46,
        2 , 16, 16, 16, 46, 16, 16, 16, 16, 46,
        27, 28, 28, 2 , 16, 16, 16, 16, 16, 46,
        13, 13, 13, 14, 16, 16, 16, 16, 16, 46,
        13, 13, 13, 14, 16, 16, 16, 6 , 7 , 7 ,
        25, 25, 25, 26, 16, 16, 16, 30, 31, 31,
        16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
        0 , 1 , 1 , 1 , 2 , 16, 6 , 7 , 7 , 7 ,
    ]

##
#Tilemap section
##
var m_vertices*: VertexArray
var spriteSheet = newTexture("example-tileset.png")
proc createTileMap[I](width, height: int, level: array[I, int], tileSize: Vect, scale: float = 1.0f, blankNumber: int = 0, usePhysics: bool = false): bool =
  #Some basic error checking.
  if width*height > level.len:
      echo "ERROR: Declaring a size that is larger than the level array length!"
      return
  #Declaring the Vertex array and specifying it's type
  m_vertices = newVertexArray(PrimitiveType.Quads)
  var 
    drawHeight: int = 0
    drawWidth: int = 0
    physicsCount: int = 0
    previousLine = newSeq[int](width)
  let
    xTileSize = tileSize.x * scale
    yTileSize = tileSize.y * scale
  for i in 0..width*height-1:
    if drawWidth >= width:
      drawHeight += 1
      drawWidth = 0
      for p in 0..width-1:
        previousLine[p] = level[(width*drawHeight)+p]
      echo previousLine

    let layer: int = ((level[i].toFloat * tileSize.x) / spriteSheet.size.x.toFloat).floor.toInt
      
    var spritePosX = (level[i].toFloat * tileSize.x) - spriteSheet.size.x.toFloat * layer.toFloat
    
    var spriteWidthCurrent: float = layer.toFloat * tileSize.y
    
    m_vertices.append vertex(
      vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize), White, 
      vec2(spritePosX, spriteWidthCurrent))
    
    m_vertices.append vertex(
      vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize), White, 
      vec2(spritePosX + tileSize.x, spriteWidthCurrent))
    
    m_vertices.append vertex(
      vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize + (yTileSize)), White, 
      vec2(spritePosX + tileSize.x, spriteWidthCurrent + tileSize.y))
    
    m_vertices.append vertex(
      vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize + (yTileSize)), White, 
      vec2(spritePosX, spriteWidthCurrent + tileSize.y))
    drawWidth += 1
    if level[i] == blankNumber:
      #echo "test"
      
      for d in 0..2:
        #echo m_vertices[physicsCount+d].position.x
        #echo "physicsCount + d is: ", physicsCount+d
        #echo d
        var ground = newSegmentShape(space.staticBody, v(m_vertices[physicsCount+d].position.x, m_vertices[physicsCount+d].position.y), v(m_vertices[physicsCount+d+1].position.x, m_vertices[physicsCount+d+1].position.y), 0)
        ground.friction = 20.0
        #discard space.addShape(ground)
      var ground = newSegmentShape(space.staticBody, v(m_vertices[physicsCount].position.x, m_vertices[physicsCount].position.y), v(m_vertices[physicsCount+3].position.x, m_vertices[physicsCount+3].position.y), 0)
      ground.friction = 20.0
      #discard space.addShape(ground)
      #count += 1
    else:
      if drawHeight == 0:
        var ground = newSegmentShape(space.staticBody, v(m_vertices[physicsCount].position.x, m_vertices[physicsCount].position.y), v(m_vertices[physicsCount+1].position.x, m_vertices[physicsCount+1].position.y), 0)
        ground.friction = 20.0
        discard space.addShape(ground)
      else:
        var test: int
        #if level[drawWidt ==2
        #echo ""
    physicsCount += 4
    #NEW PHYSICS ALGORITHM
    




  return true



var test: Vect = Vect(x:16, y: 16)
#discard createTileMap(11, 7, level, test, 2.0f, 16)
var max = sqrt(level.len.toFloat).toInt
#echo max
#echo level.len
discard createTileMap(10, 10, level, test, 3.0f, 16)








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
