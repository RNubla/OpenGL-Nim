import wrapper as glfw
import utils
import opengl
import os
import strutils
import sequtils
import Il, Ilu
import nimgl/[glfw, opengl]
# import FreeImage

var mainWindow: glfwWindow

proc closeApplication() {.noconv.} =
  # Release all resources here.
  glfw.terminate()

proc initApplication() =
  ## Initialize and load all the libraries here.
  if glfw.init() == 0:
    quit("Failed to initialize GLFW.", quitFailure)
  IlInit()
  IluInit()
  # when not defined(Windows)
  #   FreeImage_Initialize()
  addQuitProc(closeApplication)


proc initWindow() =
  glfw.defaultWindowHints()
  glfw.windowHint(SAMPLES, 4)
  glfw.windowHint(CONTEXT_VERSION_MAJOR, 3)
  glfw.windowHint(CONTEXT_VERSION_MINOR, 3)
  glfw.windowHint(OPENGL_PROFILE, OPENGL_CORE_PROFILE)

  mainWindow = createWindow(1024, 768, "Tutorial 01", nil, nil)
  if mainWindow == nil:
    quit("Failed to open GLFW window.", quitFailure)
  mainWindow.makeContextCurrent()
  mainWindow.setInputMode(STICKY_KEYS, GL_TRUE)
  opengl.loadExtensions()

proc main() =
  initApplication()
  initWindow()

  # Create Vertex Array Object
  var vao: glUInt
  glGenVertexArrays(1, addr vao)
  glBindVertexArray(vao)

  # Create a Vertex Buffer Object and copy the vertex data to it
  var vbo: glUInt
  glGenBuffers(1, addr vbo)

  var vertices: array[28, glFloat] = [
    -0.5'f32,  0.5'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
     0.5'f32,  0.5'f32, 0.0'f32, 1.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
     0.5'f32, -0.5'f32, 0.0'f32, 0.0'f32, 1.0'f32, 1.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32, 1.0'f32, 1.0'f32, 1.0'f32, 0.0'f32, 1.0'f32,
  ]

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(
    GL_ARRAY_BUFFER,
    glSizeIPtr(sizeof(vertices)), 
    addr vertices, GL_STATIC_DRAW
  )

  # Create an element array
  var ebo: glUInt
  glGenBuffers(1, addr ebo)

  var elements: array[6, glUInt] = [
    0'u32, 1'u32, 2'u32,
    2'u32, 3'u32, 0'u32
  ]

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(
    GL_ELEMENT_ARRAY_BUFFER,
    glSizeIPtr(sizeof(elements)),
    addr elements,
    GL_STATIC_DRAW
  )

  # Create and compile the shader program
  var shaderProgram = loadShaders(Open("vertex.shader"), Open("fragment.shader"))
  glUseProgram(shaderProgram)

  # Specify the layout of the vertex data
  var posAttrib = glGetAttribLocation(shaderProgram, "position")
  glEnableVertexAttribArray(cast[glUInt](posAttrib))
  glVertexAttribPointer(
    cast[glUInt](posAttrib),
    2'i32,
    cGL_FLOAT,
    glBoolean(GL_FALSE),
    glSizeI(7 * sizeof(GLfloat)), 
    cast[pglVoid](0)
  )

  var colAttrib = glGetAttribLocation(shaderProgram, "color")
  glEnableVertexAttribArray(cast[glUInt](colAttrib))
  glVertexAttribPointer(
    cast[glUInt](colAttrib),
    3'i32,
    cGL_FLOAT,
    glBoolean(GL_FALSE),
    glSizeI(7 * sizeof(GLfloat)), 
    cast[pglVoid](2 * sizeof(GLfloat))
  )

  var texAttrib = glGetAttribLocation(shaderProgram, "texcoord")
  glEnableVertexAttribArray(cast[glUInt](texAttrib))
  glVertexAttribPointer(
    cast[glUInt](texAttrib),
    2'i32,
    cGL_FLOAT, 
    GlBoolean(GL_FALSE),
    glSizeI(7*sizeof(float)),
    cast[pglVoid](5*sizeof(float))
  )

  var x = loadTexture("img.png")

  # Ensure we can capture the escape key being pressed below
  while (mainWindow.getKey(KEY_ESCAPE) != PRESS) and (glfw.windowShouldClose(mainWindow) == 0):
    glClearColor(0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    glClear(GL_COLOR_BUFFER_BIT)
     
    # Draw the triangle !
    glDrawElements(GL_TRIANGLES, glSizeI(6), cGL_UNSIGNED_INT, cast[pglVoid](0))
    mainWindow.swapBuffers()

    glfw.pollEvents()
    # Draw nothing, see you in tutorial 2 !
    # Swap buffers


  glDeleteProgram(shaderProgram)

  glDeleteBuffers(1, addr ebo)
  glDeleteBuffers(1, addr vbo)

  glDeleteVertexArrays(1, addr vao)
  quit()

when isMainModule:
  when true:
    main()
utils.nim
import opengl
import FreeImage
import strutils
import IL, ILU

template debugEcho(i: expr): expr =
  when not defined(release):
    echo(i)

type
  shaderHandle = glHandle
  shaderProgram = glHandle

# proc loadTexture*(filePath: string): GlUInt =
#   ## Loads an image file into a new texture.
#   ## Modified from http://r3dux.org/tag/ilutglloadimage/
#   var
#     imageId: IlUInt
#     textureId: GlUInt
#     success: bool
#     error: IlEnum

#   ilGenImages(1, addr imageID)
#   ilBindImage(imageID)

#   success = ilLoadImage(filePath).bool
 
#   if not success:
#     quit(
#       "Image conversion failed - IL reports error: $#" % $int(error),
#       quitFailure
#     )

#   var imageInfo: IlInfo
#   iluGetImageInfo(addr imageInfo);
#   if int(imageInfo.Origin) == int(IL_ORIGIN_UPPER_LEFT):
#     discard iluFlipImage()
#   success = ilConvertImage(IL_RGB, IL_UNSIGNED_BYTE).BOOL
 
#   if not success:
#     quit(
#       "Image conversion failed - IL reports error: $#" % $int(error),
#       quitFailure
#     )
 
#   glGenTextures(1, addr textureID)

#   glBindTexture(GL_TEXTURE_2D, textureID)

#   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
#   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)

#   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
#   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
 
#   glTexImage2D(GL_TEXTURE_2D,
#     0'i32,
#     GlInt(ilGetInteger(IL_IMAGE_FORMAT)),
#     GlSizeI(ilGetInteger(IL_IMAGE_WIDTH)),
#     GlSizeI(ilGetInteger(IL_IMAGE_HEIGHT)),
#     0'i32,
#     GlEnum(ilGetInteger(IL_IMAGE_FORMAT)),
#     cGL_UNSIGNED_BYTE,
#     cast[PGlVoid](ilGetData())
#   )
#   if not success:
#     quit(
#       "Image conversion failed - IL reports error: $#" % $int(error),
#       quitFailure
#     )
 
#   ilDeleteImages(1, addr imageID)
 
#   echo("Texture creation successful.")

proc loadTexture*(filePath: string): GlUInt =
  var baseImage = FreeImage_Load(
    FreeImage_GetFileType(filePath, 0),
    filePath, 0
  )
  if baseImage == nil:
    quit("Couldn't load image: $#" % filePath, quitFailure)

  var formatImage = FreeImage_ConvertTo32Bits(baseImage)
  if formatImage == nil:
    quit("Couldn't format image: $#" % filePath, quitFailure)

  var
    width = FreeImage_GetWidth(formatImage)
    height = FreeImage_GetHeight(formatImage)

  glGenTextures(1, addr result)
  glBindTexture(GL_TEXTURE_2D, result)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexImage2D(
    GL_TEXTURE_2D, 
    0'i32, 
    GL_RGB, 
    GlSizeI(width), GlSizeI(height),
    0'i32, 
    GL_BGRA,
    cGL_UNSIGNED_BYTE, 
    cast[PGlVoid](FreeImage_GetBits(formatImage))
    )

  FreeImage_Unload(baseImage)
  if baseImage != formatImage:
    FreeImage_Unload(formatImage)

proc loadShaders*(vertexCode, fragmentCode: string): shaderProgram =
  ## Loads a vertex/fragment shader pair from the given source codes.
  let
    vertexShaderID: shaderHandle = glCreateShader(GL_VERTEX_SHADER)
    fragmentShaderID: shaderHandle = glCreateShader(GL_FRAGMENT_SHADER)
 
  var
    vsLength: glInt = glInt(len(vertexCode))
    fsLength: glInt = glInt(len(fragmentCode))
    compileResult: glInt
    infoLogLength: glSizeI

  # Compile Vertex Shader
  echo("Compiling vertexshader")
  var f = vertexCode.cstring
  glShaderSource(vertexShaderID, glSizeI(1), cast[cstringArray](addr f) , addr vsLength)
  glCompileShader(vertexShaderID)

  # Check Vertex Shader
  glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, addr compileResult)
  glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, addr infoLogLength)
  var vsErrorMessage = newString(infoLogLength)
  glGetShaderInfoLog(vertexShaderID, infoLogLength,  cast[var GLint](nil),  addr vsErrorMessage[0])

  # Compile Fragment Shader
  echo("Compiling fragment shader")
  var g = fragmentCode.cstring
  glShaderSource(FragmentShaderID, glSizeI(1), cast[cstringArray](addr g) , addr fsLength)
  glCompileShader(FragmentShaderID)

  # Check Fragment Shader
  glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, addr compileResult)
  glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, addr infoLogLength)
  var fsErrorMessage = newString(infoLogLength+1) 
  glGetShaderInfoLog(FragmentShaderID, infoLogLength, cast[var GLint](nil), addr fsErrorMessage[0])

  # Link the program
  debugEcho("Linking program")
  result = glCreateProgram()
  glAttachShader(result, vertexShaderID)
  glAttachShader(result, FragmentShaderID)
  var oc = cstring("outColor")
  glBindFragDataLocation(cast[GlUInt](result), GlUInt(0), oc);
  glLinkProgram(result)

  # Check the program
  glGetProgramiv(result, GL_LINK_STATUS, addr compileResult)
  glGetProgramiv(result, GL_INFO_LOG_LENGTH, addr infoLogLength)
  var programErrorMessage = newString(infoLogLength+1)
  glGetProgramInfoLog(result, infoLogLength, cast[var GLint](nil), addr programErrorMessage[0])
  echo(programErrorMessage)

  glDeleteShader(vertexShaderID)
  glDeleteShader(FragmentShaderID)

proc loadShaders*(vertexFile, fragmentFile: TFile): shaderProgram =
  ## Loads a vertex/fragment shader pair from a pair of files.
  return loadShaders(readAll(vertexFile), readAll(fragmentFile))