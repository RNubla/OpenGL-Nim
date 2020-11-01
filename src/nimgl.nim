import nimgl/[glfw, opengl]
import math, parseopt, strutils

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
    [GLfloat(-1.0f), -1.0f, 0.0f,
              1.0f, -1.0f, 0.0f,
              0.0f, 1.0f, 0.0f,
    ]
  var
    vertexBuff: GLuint = 0
    colorVBO: GLuint = 0
    vao: GLuint = 0
    colors: array[21, GLfloat]= [
      # Center point
      1'f32, 1'f32, 1'f32,    # White

      # Outer points 
      1'f32, 0'f32, 0'f32,    # Red
      1'f32, 1'f32, 0'f32,    # Yellow
      0'f32, 1'f32, 0'f32,    # Green
      0'f32, 1'f32, 1'f32,    # Cyan
      0'f32, 0'f32, 1'f32,    # Blue
      1'f32, 0'f32, 1'f32,    # Magenta
    ]
    vertShader: GLuint
    fragShader: GLuint
    shaderProgram: GLuint

    # Shader src
    vertShaderSrc = readFile("src/shader.frag")
    fragShaderSrc = readFile("src/shader.frag")
    vertShaderArray = allocCStringArray([vertShaderSrc])
    fragShaderArray = allocCStringArray([fragShaderSrc])

    isCompiled : GLint
    isLinked : GLint


  # Bind vertices
  glGenBuffers(1, vertexBuff.addr)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuff)
  glBufferData(GL_ARRAY_BUFFER, g_vertex_buffer_data.sizeof,
      g_vertex_buffer_data.addr, GL_STATIC_DRAW)

  #bind colors
  glGenBuffers(1, colorVBO.addr)
  glBindBuffer(GL_ARRAY_BUFFER, colorVBO)
  glBufferData(GL_ARRAY_BUFFER, colors.sizeof, colors.addr, GL_STATIC_DRAW)

  # The array obj
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  glBindBuffer(GL_ARRAY_BUFFER, vertexBuff)
  glVertexAttribPointer(cast[GLuint](0), cast[GLint](3), EGL_FLOAT, cast[GLboolean](GL_FALSE), cast[GLsizei](0), cast[pointer] (nil))
  glBindBuffer(GL_ARRAY_BUFFER,colorVBO)
  glVertexAttribPointer(cast[GLuint](1), cast[GLint](3), EGL_FLOAT, cast[GLboolean](GL_FALSE), cast[GLsizei](0), cast[pointer] (nil))
  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)

  # Compile Shader

  if isCompiled == 0:
    echo "Fragment shader wasn't compiled. Reason: "

    # Query the log size
    var logSize: GLint
    glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, logSize.addr)

    # Get the log itself
    var
      logStr = cast[ptr GLchar](alloc(logSize))
      logLen:GLsizei

    glGetShaderInfoLog(fragShader, cast[GLsizei](logSize), logLen.addr, logStr)

    # print log
    echo $logStr

    # Cleanup
    dealloc(logStr)
  else:
    echo "Fragment shader compiled successfully"

  # Attach to a GL program
  shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, vertShader)
  glAttachShader(shaderProgram, fragShader)

  # insert locations
  glBindAttribLocation(shaderProgram, 0, "vertexPos")
  glBindAttribLocation(shaderProgram, 0, "vertexClr")

  glLinkProgram(shaderProgram)

  # check for shader linking errors
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, isLinked.addr)
  if isLinked == 0:
    echo "Wasn't able to link shaders. Reason: "

    # Get the log size
    var logSize : GLint
    glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, logSize.addr)

    # Get the log itself
    var
      logStr = cast[ptr GLchar](alloc(logSize))
      logLen : GLsizei
    
    glGetProgramInfoLog(shaderProgram, cast[GLsizei](logSize), logLen.addr, logStr)

    # print the log
    echo $logStr
    # cleanup
    dealloc(logStr)

  else:
    echo "Shader program ready!"

  # if everything is linked, we are ready to go!
  # 
  glClearColor(0.0f, 0.0f, 0.4f, 0.0f)

  while not window.windowShouldClose:
    # glEnableVertexAttribArray(0);
    # glBindBuffer(GL_ARRAY_BUFFER, vertexBuff)
    # glVertexAttribPointer(cast[GLuint](0), cast[GLint](3), EGL_FLOAT, cast[
    #     GLboolean](GL_FALSE), cast[GLsizei](0), cast[pointer] (nil))
    # glDrawArrays(GL_TRIANGLES, 0, 3)
    # glDisableVertexAttribArray(0)
    glClear(GL_COLOR_BUFFER_BIT or  GL_DEPTH_BUFFER_BIT)
    glUseProgram(shaderProgram)
    # do the drawing
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0,3)

    # unbind
    glBindVertexArray(0)
    glUseProgram(0)

    # poll and swap
    window.swapBuffers()
    glfwPollEvents()


  # clean up non-GC'd stuff
  deallocCStringArray(vertShaderArray)
  deallocCStringArray(fragShaderArray)

  # Cleanup OpenGL Stuff
  glDeleteProgram(shaderProgram)
  glDeleteShader(vertShader)
  glDeleteShader(fragShader)
  glDeleteBuffers(1, vertexBuff.addr)
  glDeleteBuffers(1, colorVBO.addr)
  glDeleteVertexArrays(1, vao.addr)


  window.destroyWindow()
  glfwTerminate()

main()
