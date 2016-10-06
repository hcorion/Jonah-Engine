import jonah
import chipmunk
import csfml, csfml_graphics, csfml_system
import strutils
import math, random

var
  gameHeight = 1280.0
  gameWidth = 720.0
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
    @[
         9, 31, 31, 31, 31, 31, 31, 31, 31, 11, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 16, 16, 16, 16, 16, 16, 16, 16, 23, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 16, 16, 16, 16, 16, 16, 16, 16, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 16, 16, 16, 16, 16, 06, 07, 34, 35, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 16, 16, 16, 16, 16, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19,
        20, 16, 16, 16, 16, 16, 30, 31, 10, 10, 31, 10, 10, 31, 31, 31, 31, 10, 11,
        20, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 23,
        33, 34, 07, 07, 08, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 23,
        19, 19, 19, 19, 33, 34, 34, 08, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 23,
        19, 19, 19, 19, 19, 19, 19, 20, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 23,
        19, 19, 19, 19, 19, 19, 19, 33, 34, 07, 07, 07, 07, 07, 07, 07, 07, 07, 35
    ]
var spriteSheet = newTexture("example-tileset.png")



var test: Vect = Vect(x:16, y: 16)
var max = sqrt(level.len.toFloat).toInt

var tileMap = createTileMap(19, 11, level, test, spriteSheet, 5.0f, 16, true, space)

var window = newRenderWindow(
  videoMode((cint)gameHeight, (cint)gameWidth), "TestGame", WindowStyle.Default)
var view: csfml.View = csfml.newView(rect(0, 0, gameHeight, gameWidth))
window.view = view
window.frameRateLimit = 60
window.verticalSyncEnabled = true

var tex*: Texture = newTexture("p1.png")

var intRect = IntRect(left: 0, top: 0, width: tex.size.x, height: tex.size.y)

var player = jonah.initGameObject(SpriteType.rectangle, rbType.rectangle, tex, intRect, space, 80, 80, mass = 0.1f, position = v(110, 110))
#We set this to Inf (Infinity) so that the player doesn't rotate.
player.body.moment = Inf
goSeq.add(player)

var font = newFont("Hack-Regular.ttf")

#Main loop
while window.open:
  #Initial setup
  window.clear(White)
  space.step(1/60)
  #Dealing with events, like pressing the keyboard, or closing the window.
  var event: Event
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      window.close()
      break
  if (keyboard_isKeyPressed(KeyCode.W)):
    player.body.applyForceAtWorldPoint(v(0, -90), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.S)):
    player.body.applyForceAtWorldPoint(v(0, 90), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.A)):
    player.body.applyForceAtWorldPoint(v(-90, 0), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.D)):
    player.body.applyForceAtWorldPoint(v(90, 0), player.body.position)
  if (keyboard_isKeyPressed(KeyCode.Escape)):
    quit()

  #Draw the tilemap
  window.draw(tileMap)
  
  #Draw the gameobjects
  for obj in goSeq:
    window.drawGameObject(obj)
  #Let's make the view follow the player.
  view.center = Vector2f(x: player.sprite.position.x, y:player.sprite.position.y)
  window.view = view
  #Now we can display everything.
  window.display
