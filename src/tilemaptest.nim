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
        0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 2, 0, 0, 0, 0,
        1, 1, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3,
        0, 1, 0, 0, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 0, 0,
        0, 1, 1, 0, 3, 3, 3, 0, 0, 0, 1, 1, 1, 2, 0, 0,
        0, 0, 1, 0, 3, 0, 2, 2, 0, 0, 1, 1, 1, 1, 2, 0,
        2, 0, 1, 0, 3, 0, 2, 2, 2, 0, 1, 1, 1, 1, 1, 1,
        0, 0, 1, 0, 3, 2, 2, 2, 0, 0, 0, 0, 1, 1, 1, 1
    ]

##
#Tilemap section
##
var m_vertices*: VertexArray
var spriteSheet = newTexture("example-tileset.png")
proc createTileMap[I](width, height: int, level: array[I, int], tileSize: Vect): bool =
  #m_vertices = newVertexArray()
  #m_vertices.primitiveType = PrimitiveType.Quads
  m_vertices = newVertexArray(PrimitiveType.Quads)
  m_vertices.append vertex(vec2(0, 0), Green)
  m_vertices.append vertex(vec2(100, 0), Red)
  m_vertices.append vertex(vec2(100, 100), Blue)
  m_vertices.append vertex(vec2(0, 100), Blue)
  m_vertices.resize(9)
  #m_vertices.append vertex(vec2(100, 100), Transparent, Vector2f(x: 100, y: 0))
  #m_vertices.append vertex(vec2(200, 100), Transparent, Vector2f(x: 200, y: 0))
  #m_vertices.append vertex(vec2(200, 200), Transparent, Vector2f(x: 0, y: 0))
  #m_vertices.append vertex(vec2(100, 200), Transparent, Vector2f(x: 200, y: 200))
  m_vertices.getVertex(4).position = vec2(100, 100)
  m_vertices.getVertex(5).position = vec2(200, 100)
  m_vertices.getVertex(6).position = vec2(200, 200)
  m_vertices.getVertex(7).position = vec2(100, 200)
  m_vertices.getVertex(8).position = vec2(100, 100)
  m_vertices.getVertex(4).color = White
  m_vertices.getVertex(5).color = White
  m_vertices.getVertex(6).color = White
  m_vertices.getVertex(7).color = Blue
  m_vertices.getVertex(8).color = Blue
#389 x 495
  m_vertices.getVertex(0).texCoords = Vector2f(x: 0, y: 0)
  m_vertices.getVertex(1).texCoords = Vector2f(x: 389, y: 0)
  m_vertices.getVertex(2).texCoords = Vector2f(x: 389, y: 495)
  m_vertices.getVertex(3).texCoords = Vector2f(x: 0, y: 495)
  m_vertices.getVertex(4).texCoords = Vector2f(x: 0, y: 0)
  
  
  for i in 0..width:
    for j in 0..height:
      echo ""
      var tileNumber: int = level[i + j * width]
      var tu = (tileNumber.toFloat) mod (spriteSheet.size.x.toFloat / tileSize.x)
      var tv = tileNumber.toFloat / (spriteSheet.size.x.toFloat / tileSize.x)
      #var quad: VertexArray = m_vertices[(i + j * width) * 4]
      var test = i + j * width
      #m_vertices.getVertex(test).position = Vector2f(x: i.toFloat * tileSize.x, y: j.toFloat * tileSize.y)
      #m_vertices.getVertex(test+1).position = Vector2f(x: (i + 1).toFloat * tileSize.x,y: j.toFloat * tileSize.y)
      #m_vertices.getVertex(test+2).position = Vector2f(x:(i + 1).toFloat * tileSize.x, y: (j + 1).toFloat * tileSize.y)
      #m_vertices.getVertex(test+3).position = Vector2f(x: i.toFloat * tileSize.x, y: (j + 1).toFloat * tileSize.y)
      
      #m_vertices.getVertex(test).texCoords = Vector2f(x: tu * tileSize.x, y: tv * tileSize.y);
      #m_vertices.getVertex(test+1).texCoords = Vector2f(x: (tu + 1) * tileSize.x, y: tv * tileSize.y);
      #m_vertices.getVertex(test+2).texCoords = Vector2f(x: (tu + 1) * tileSize.x, y:  (tv + 1) * tileSize.y);
      #m_vertices.getVertex(test+3).texCoords = Vector2f(x: tu * tileSize.x, y: (tv + 1) * tileSize.y);
      #echo m_vertices.vertexCount
      #echo m_vertices.getVertex(17).position
      ##echo i + j * width * 4
      #discard renderStates()
  return true



var test: Vect = Vect(x:50, y: 50)
discard createTileMap(2, 2, level, test)
proc drawVertexArray(window: RenderWindow)=
  var testt: RenderStates
  testt.texture = spriteSheet
  window.draw(m_vertices, testt)
  







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
  window.draw(m_vertices)
  for obj in goSeq:
    window.drawGameObject(obj)
  #goSeq[0].intRect.left = goSeq[0].intRect.left + 1
  #goSeq[0].intRect.top = goSeq[0].intRect.top + 1
  window.draw(rotation)
  var rend = RenderStates()
  rend.texture = tex
  window.drawVertexArray(m_vertices, rend)
  window.draw(m_vertices, rend)
  #window.drawVertexArray()
  #var newStr = ("x: ", cast[string](player.body.position.x), " y: ", cast[string](player.body.position.y))
  #echo player.body.position.x
  rotation.str = formatFloat(radToDeg(vtoangle(player.body.rotation)))
  rotation.position = vec2(player.body.position.x - 40, player.body.position.y - 40)
  #window.drawGameObject(gameObject)
  window.display
