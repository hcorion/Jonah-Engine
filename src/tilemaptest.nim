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
space.iterations = 200
type
  exampleSSIntRect = array[3, IntRect]
let spriteSheetIntRects: exampleSSIntRect = [
  IntRect(left: 160, top: 66, width: 32, height: 30),#The tree
  IntRect(left: 65, top: 65, width: 15, height: 15),#the money
  IntRect(left: 81, top: 64, width: 15, height: 16)#the bucket
  ]
const level =
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
var spriteSheet = newTexture("example-tileset.png")



var test: Vect = Vect(x:16, y: 16)
var max = sqrt(level.len.toFloat).toInt

var tileMap = createTileMap(10, 10, level, test, spriteSheet, 3.0f, 16, true, space)

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
  window.draw(tileMap)
  window.draw(rotation)
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
