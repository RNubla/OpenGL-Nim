#version 300 es

layout(location = 0) in vec3 vertexPos;
layout(location = 1) in vec3 vertexClr;
uniform float rotation;

out vec4 color;

void main() {
  mat3 rotateAboutZ= mat3(
    cos(rotation), -sin(rotation), 0,
    sin(rotation), cos(rotation), 0,
    0, 0, 1
  );

  // Rotate clockwise
  gl_Position =  vec4(vertexPos * inverse(rotateAboutZ), 1);
  color = vec4(vertexClr, 1);
}