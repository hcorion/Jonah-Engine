import math, strutils
import csfml, csfml_audio, csfml_util
import chipmunk
import times, os
{.experimental.}
#TODO:
#Add support for donuts (Used in momentForCircle)

type
  rbType {.pure.} = enum
    none, rectangle, circle

type
  SpriteType {.pure.} = enum
    rectangle, circle

type
  GameObject = tuple[sprite: SpriteType, rigidbody: rbType, texture: Texture, body: chipmunk.Body, shape: csfml.Shape, physicsShape: chipmunk.Shape]
#    sprite: SpriteType
#    rigidbody: rbType = rbType.none
#    age: int

proc initGameObject(sprite: SpriteType, rigidbody: rbType, texture: Texture = nil, space: Space, width: float, height: float, mass: float, position: Vect): GameObject =
  var newGameObject: GameObject
  newGameObject.sprite = sprite
  if rigidbody == rbType.none:
    echo "We're building just a sprite! Arrr!"
    echo "Woops! Not supported yet."
  else:
    #Creating  a moment based on the rigidbody type.
    var moment: float
    if rigidbody == rbType.circle:
      moment = momentForCircle(mass, 0, height/2, vzero)
    elif rigidbody == rbType.rectangle:
      moment = momentForBox(mass, width, height)
    else:
      echo "I can't create a moment for that type of rbType"
    #Creating the body
    newGameObject.body = space.addBody(newBody(mass, moment))
    newGameObject.body.position = position
    #Now for the creation of the physics shape!
    if rigidbody == rbType.circle:
      newGameObject.physicsShape = space.addShape(newCircleShape(newGameObject.body, height/2, vzero))
    elif rigidbody == rbType.rectangle:
      newGameObject.physicsShape = space.addShape(newBoxShape(newGameObject.body, width, height, 4))
      var xy = Vector2f(x: width, y: height)
      newGameObject.physicsShape.userData = csfml.newRectangleShape(xy)
      let boxData = cast[csfml.Shape](newGameObject.physicsShape.userData)
      boxData.setTexture(texture, toBoolInt(false))
      boxData.origin = vec2(height/2, width/2)
      boxData.outlineColor = Red
      boxData.outlineThickness = 2.0
    else:
      echo "Hmm, I can't create a physicsShape for that type of rbType."
    #if sprite == SpriteType.circle:
      #newGameObject.shape = space.addBody(newGameObject.body)
  result = newGameObject

proc floor (vec: Vect): Vector2f =
  result.x = vec.x.floor
  result.y = vec.y.floor

proc drawGameObject(win: RenderWindow, gameObject: GameObject){.discardable.} =
  if gameObject.sprite == SpriteType.circle:
    let circle = cast[csfml.CircleShape](gameObject.physicsShape.userData)
    circle.position = gameObject.body.position.floor()
    win.draw(circle)
  elif gameObject.sprite == SpriteType.rectangle:
    let rect = cast[csfml.Shape](gameObject.physicsShape.userData)
    rect.position = gameObject.body.position.floor()
    win.draw(rect)

var space = newSpace()
var gravity = v(0, 3.14f)
space.gravity = gravity
space.iterations = 10

var window = newRenderWindow(
  videoMode(640, 480), "TEST", WindowStyle.Default)
#gameObject = (SpriteType.rectangle, rbType.none)
#initGameObject(gameObject)
window.frameRateLimit = 60
window.verticalSyncEnabled = true
var gameObject = initGameObject(SpriteType.rectangle, rbType.rectangle, newTexture("p1.png"), space, width = 200, height = 200, mass = 0.1f, position = v(50, 50))
while window.open:
  space.step(1/60)
  var event: Event
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      window.close()
      break
  window.clear(White)
  window.drawGameObject(gameObject)
  window.display
