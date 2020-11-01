import nimgl/[glfw, opengl]

proc keyProc(window: GLFWWindow, key: int32, scancode: int32, action:int32, mods:int32): void {.cdecl.}=
    if key == GLFWKey.ESCAPE and action == GLFWPress:
        window.setWindowShouldClose(true)

proc main() = 
    assert glfwInit()

    glfwWindowHint(GLFWContextVersionMajor, 3)
    glfwWindowHint(GLFWContextVersionMinor, 3)
    glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
    glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFWResizable, GLFW_TRUE)

    let w: GLFWWindow = glfwCreateWindow(1920, 1080, "Hello World")
    if w == nil:
        quit(-1)

    discard w.setKeyCallback(keyProc)
    w.makeContextCurrent()

    assert glInit()

    while not w.windowShouldClose:
        glfwPollEvents()
        glClearColor(0.68f, 1f, 0.34f, 1f)
        glClear(GL_COLOR_BUFFER_BIT)
        w.swapBuffers()

    w.destroyWindow()
    glfwTerminate()

main()