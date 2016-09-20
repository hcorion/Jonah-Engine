import math, strutils
import csfml, csfml_audio, csfml_util
import chipmunk
import times, os
{.experimental.}
#TODO:
#Add support for donuts (Used in momentForCircle)
type
  rbType* {.pure.} = enum
    none, rectangle, circle

type
  SpriteType* {.pure.} = enum
    rectangle, circle

type
  GameObject* = tuple[spriteType: SpriteType, rigidbody: rbType, texture: Texture, intRect: IntRect, body: chipmunk.Body, shape: csfml.Shape, physicsShape: chipmunk.Shape, sprite: csfml.Sprite]


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
      var sprite = csfml.newSprite(texture, intRect)
      sprite.origin = vec2(intRect.height/2, intRect.width/2)
      sprite.scale = Vector2f(x: width.floor / intRect.width.toFloat, y: height.floor / intRect.height.toFloat)
      newGameObject.sprite = sprite

    elif rigidbody == rbType.rectangle:
      newGameObject.physicsShape = space.addShape(newBoxShape(newGameObject.body, width, height, 0))
      var sprite = csfml.newSprite(texture, intRect)
      sprite.origin = vec2(intRect.height/2, intRect.width/2)
      sprite.scale = Vector2f(x: width.floor / intRect.width.toFloat, y: height.floor / intRect.height.toFloat)
      newGameObject.sprite = sprite
    else:
      echo "Hmm, I can't create a physicsShape for that type of rbType."
  result = newGameObject

proc floor (vec: Vect): Vector2f =
  result.x = vec.x.floor
  result.y = vec.y.floor

proc drawGameObject*(win: RenderWindow, gameObject: GameObject){.discardable.} =
  if gameObject.spriteType == SpriteType.circle:
    echo "Currently a SpriteType of circle is unsupported. Just use SpriteType.rectangle"
  elif gameObject.spriteType == SpriteType.rectangle:
    var sprite = gameObject.sprite
    sprite.rotation = radToDeg(vtoangle(gameObject.body.rotation))
    sprite.position = gameObject.body.position.floor()
    win.draw(sprite)
