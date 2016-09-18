import math, strutils
import csfml, csfml_audio, csfml_util
import chipmunk
import times, os
{.experimental.}
#TODO:
#Add support for donuts (Used in momentForCircle)
var maxVal*: float
var minVal*: float
type
  rbType* {.pure.} = enum
    none, rectangle, circle

type
  SpriteType* {.pure.} = enum
    rectangle, circle

type
  GameObject* = tuple[spriteType: SpriteType, rigidbody: rbType, texture: Texture, intRect: IntRect, body: chipmunk.Body, shape: csfml.Shape, physicsShape: chipmunk.Shape]
#    sprite: SpriteType
#    rigidbody: rbType = rbType.none
#    age: int


proc initGameObject*(spriteType: SpriteType, rigidbody: rbType, texture: Texture, intRect: IntRect, space: Space, width: float, height: float, mass: float, position: Vect): GameObject =
  var newGameObject: GameObject
  newGameObject.spriteType = spriteType
  newGameObject.texture = texture
  newGameObject.intRect = intRect
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
      let radius = height/2
      newGameObject.physicsShape = space.addShape(newCircleShape(newGameObject.body, radius, vzero))
      newGameObject.physicsShape.userData = csfml.newCircleShape(radius)
      #newGameObject.physicsShape.collisionType = cast[CollisionType](4)
      #let circleData = cast[csfml.CircleShape](newGameObject.physicsShape.userData)
      #circleData.setTexture(texture, toBoolInt(false))
      #circleData.origin = vec2(radius, radius)
    elif rigidbody == rbType.rectangle:
      newGameObject.physicsShape = space.addShape(newBoxShape(newGameObject.body, width, height, 4))
      var xy = Vector2f(x: width, y: height)
      var test = IntRect(left: 0, top: 0, width:300, height:400)
      #newGameObject.physicsShape.userData = csfml.newRectangleShape(xy)
      #newGameObject.physicsShape.userData = sprite
      #let boxData = cast[csfml.Shape](newGameObject.physicsShape.userData)
      #boxData.setTexture(texture, toBoolInt(false))
      #boxData.origin = vec2(height/2, width/2)
      #boxData.outlineColor = Red
      #boxData.outlineThickness = 2.0
    else:
      echo "Hmm, I can't create a physicsShape for that type of rbType."
    #if sprite == SpriteType.circle:
      #newGameObject.shape = space.addBody(newGameObject.body)
  result = newGameObject

proc floor (vec: Vect): Vector2f =
  result.x = vec.x.floor
  result.y = vec.y.floor

proc drawGameObject*(win: RenderWindow, gameObject: GameObject){.discardable.} =
  if gameObject.spriteType == SpriteType.circle:
    let circle = cast[csfml.CircleShape](gameObject.physicsShape.userData)
    circle.position = gameObject.body.position.floor()
    #circle.rotation = gameObject.body.rotation.x * 100
    circle.rotation = radToDeg(vtoangle(gameObject.body.rotation))
    win.draw(circle)
  elif gameObject.spriteType == SpriteType.rectangle:
    #let rect = cast[csfml.Shape](gameObject.physicsShape.userData)
    #let sprite = cast[csfml.Sprite](gameObject.physicsShape.userData)
    if gameObject.body.rotation.x > maxVal:
      maxVal = gameObject.body.rotation.x
    elif gameObject.body.rotation.x < minVal:
      minVal = gameObject.body.rotation.x
    #rect.position = gameObject.body.position.floor()
    #rect.rotation = radToDeg(vtoangle(gameObject.body.rotation))
    #rect.rotation = 270
    let sprite = csfml.newSprite(gameObject.texture, gameObject.intRect)
    sprite.rotation = radToDeg(vtoangle(gameObject.body.rotation))
    sprite.origin = vec2(gameObject.intRect.height/2, gameObject.intRect.width/2)
    #var vec = (gameObject.body.position.floor().x * 2, gameObject.body.position.floor().y * 2) 
    sprite.position = gameObject.body.position.floor()
    sprite.scale = Vector2f(x: 0.1, y: 0.1)
    #win.draw(sprite)
    win.draw(sprite)
