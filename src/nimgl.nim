import nimgl/[glfw, opengl]

proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc main() =
  assert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  let window: GLFWWindow = glfwCreateWindow(1024, 768, "Tutorial 01", nil, nil)
  if window == nil:
    write(stdout, "Failed to open GLFW window.")
    glfwTerminate()
    quit(-1)

  discard window.setKeyCallback(keyProc)
  window.makeContextCurrent()

  assert glInit()
  var g_vertex_buffer_data =
    [ GLfloat(-1.0f), -1.0f, 0.0f,
              1.0f, -1.0f, 0.0f,
              0.0f,  1.0f, 0.0f,
    ]
  var 
    vertexBuff:GLuint
    vbo:GLuint
    shaderProgram : GLuint
    vertShader:GLuint
    fragShader:GLuint

  # Draw shader
  shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, )
  
  glGenBuffers(1, vertexBuff.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuff)
  glBufferData(GL_ARRAY_BUFFER, g_vertex_buffer_data.sizeof, g_vertex_buffer_data.addr, GL_STATIC_DRAW)
  glClearColor(0.0f, 0.0f, 0.4f, 0.0f)

  while not window.windowShouldClose:
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER,vertexBuff)
    glVertexAttribPointer(cast[GLuint](0), cast[GLint](3), EGL_FLOAT, cast[GLboolean](GL_FALSE), cast[GLsizei](0), cast[pointer] (nil))
    glDrawArrays(GL_TRIANGLES, 0, 3)
    glDisableVertexAttribArray(0)
    glClear(GL_COLOR_BUFFER_BIT)
    window.swapBuffers()
    glfwPollEvents()

  window.destroyWindow()
  glfwTerminate()

main()
