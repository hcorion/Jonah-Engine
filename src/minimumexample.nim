import csfml, csfml_graphics, csfml_system
var
  gameHeight = 640.0
  gameWidth = 480.0
var tex = newTexture("p1.png")
var m_vertices: VertexArray
m_vertices = newVertexArray(PrimitiveType.Quads)
m_vertices.append vertex(vec2(0, 0), Green, vec2(0, 0))
m_vertices.append vertex(vec2(100, 0), Red, vec2(300, 0))
m_vertices.append vertex(vec2(100, 100), Blue, vec2(300, 300))
m_vertices.append vertex(vec2(0, 100), Blue, vec2(0, 300))
var window = newRenderWindow(
  videoMode((cint)gameHeight, (cint)gameWidth), "TEST", WindowStyle.Default)
window.frameRateLimit = 60
window.verticalSyncEnabled = true

#Main loop
while window.open:
  var event: Event
  while window.pollEvent(event):
    if event.kind == EventType.Closed:
      window.close()
      break
  window.clear(White)
  window.draw(m_vertices)
  var rend = renderStates()
  rend.texture = tex
  window.draw(m_vertices, rend)
  window.display
