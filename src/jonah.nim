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
  TileMap* = tuple[vertexArray: VertexArray, spriteSheet: Texture]


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


proc createTileMap*[I](width, height: int, level: array[I, int], tileSize: Vect, spriteSheet: Texture, scale: float = 1.0f, blankNumber: int = 0, usePhysics: bool = false, space: Space = nil): TileMap =
  #Some basic error checking.
  if width*height > level.len:
      echo "ERROR: Declaring a size that is larger than the level array length!"
      return
  #Declaring the Vertex array and specifying it's type
  var 
    vertexArray = newVertexArray(PrimitiveType.Quads)
    drawHeight: int = 0
    drawWidth: int = 0
    physicsCount: int = 0
    previousLine = newSeq[int](width)
    physicsObjects = newSeq[SegmentShape](0)
  let
    xTileSize = tileSize.x * scale
    yTileSize = tileSize.y * scale
  for i in 0..width*height-1:
    if drawWidth >= width:
      drawHeight += 1
      drawWidth = 0
      for p in 0..width-1:
        previousLine[p] = level[((width*drawHeight)+p)-width]
      echo previousLine

    let layer: int = ((level[i].toFloat * tileSize.x) / spriteSheet.size.x.toFloat).floor.toInt
      
    var spritePosX = (level[i].toFloat * tileSize.x) - spriteSheet.size.x.toFloat * layer.toFloat
    
    var spriteWidthCurrent: float = layer.toFloat * tileSize.y
    
    vertexArray.append vertex(
      vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize), White, 
      vec2(spritePosX, spriteWidthCurrent))
    
    vertexArray.append vertex(
      vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize), White, 
      vec2(spritePosX + tileSize.x, spriteWidthCurrent))
    
    vertexArray.append vertex(
      vec2(drawWidth.toFloat * xTileSize + (xTileSize), drawHeight.toFloat * yTileSize + (yTileSize)), White, 
      vec2(spritePosX + tileSize.x, spriteWidthCurrent + tileSize.y))
    
    vertexArray.append vertex(
      vec2(drawWidth.toFloat * xTileSize, drawHeight.toFloat * yTileSize + (yTileSize)), White, 
      vec2(spritePosX, spriteWidthCurrent + tileSize.y))
    if usePhysics:
      if level[i] == blankNumber:
        if drawHeight > 0:
        #If we're an open space and we have a closed space above us, seal it off.
          if previousLine[drawWidth] != blankNumber:
            physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount].position.x, vertexArray[physicsCount].position.y), v(vertexArray[physicsCount+1].position.x, vertexArray[physicsCount+1].position.y), 0)
          #If we're an open space and there is a closed space to our left or right, seal it off.
          if drawWidth != 0:
            if level[i-1] != blankNumber:
              physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount+3].position.x, vertexArray[physicsCount+3].position.y), v(vertexArray[physicsCount].position.x, vertexArray[physicsCount].position.y), 0)
          if drawWidth < width-1:
            if level[i+1] != blankNumber:
              physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount+1].position.x, vertexArray[physicsCount+1].position.y), v(vertexArray[physicsCount+2].position.x, vertexArray[physicsCount+2].position.y), 0)
      else:
        if drawHeight == 0:
          physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount].position.x, vertexArray[physicsCount].position.y), v(vertexArray[physicsCount+1].position.x, vertexArray[physicsCount+1].position.y), 0)
          if level[i-1] == blankNumber:
            physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount+3].position.x, vertexArray[physicsCount+3].position.y), v(vertexArray[physicsCount].position.x, vertexArray[physicsCount].position.y), 0)
          if level[i+1] == blankNumber:
            physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount+1].position.x, vertexArray[physicsCount+1].position.y), v(vertexArray[physicsCount+2].position.x, vertexArray[physicsCount+2].position.y), 0)
        else:
          #If we're a solid block and there is an open block above us, seal us off.
          if previousLine[drawWidth] == blankNumber:
            physicsObjects.add newSegmentShape(space.staticBody, v(vertexArray[physicsCount].position.x, vertexArray[physicsCount].position.y), v(vertexArray[physicsCount+1].position.x, vertexArray[physicsCount+1].position.y), 0)
    physicsCount += 4
    drawWidth += 1
  if usePhysics:
    if space == nil:
      echo "ERROR: You've declared a physics TileMap without a Chipmunk2D space!"
    for i in 0..physicsObjects.len-1:
      physicsObjects[i].friction = 20.0f
      discard space.addShape(physicsObjects[i])
  var finalTileMap: TileMap
  finalTileMap.vertexArray = vertexArray
  finalTileMap.spriteSheet = spriteSheet
  return finalTileMap

proc draw*(win: RenderWindow, tileMap: TileMap){.discardable.} =
  var rend = renderStates()
  rend.texture = tileMap.spriteSheet
  win.draw(tileMap.vertexArray, rend)