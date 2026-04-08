#include "include/glad/glad.h"
#include <GLFW/glfw3.h>
#include <cstddef>
#include <cstdlib>
#include <iostream>

int WINDOW_WIDTH = 800;
int WINDOW_HEIGHT = 600;

const char *vertexShaderSource =
    "#version 460 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}\0";

const char *fragmentShaderSource =
    "#version 460 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}\n";

const char *fragmentShaderSource2 =
    "#version 460 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "    FragColor = vec4(1.0f, 1.0f, 0.2f, 1.0f);\n"
    "}\n";

void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

int main() {
  glfwInit();
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow *window =
      glfwCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "learnOpenGL", NULL, NULL);
  if (window == NULL) {
    std::cout << "Failed to create GLFW window" << std::endl;
    glfwTerminate();
    return -1;
  }
  glfwMakeContextCurrent(window);

  if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
    std::cout << "Failed to initialize glad" << std::endl;
    return -1;
  }

  glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

  float vertices[] = {-0.5f, 0.0f,  0.0f, 0.5f, 0.0f,  0.0f, 0.0f, 0.5f, 0.0f,
                      -0.5f, -0.5f, 0.0f, 0.5f, -0.5f, 0.0f, 0.0f, 0.5f, 0.0f};
  float vertices2[] = {-0.5f, -0.75f, 0.0f, 0.5f, -0.75f,
                       0.0f,  0.0f,   0.5f, 0.0f};

  // create vertex array objects -----------------------------------
  unsigned int VAOs[2];
  // create array buffers
  unsigned int VBOs[2];
  // gen vaos
  glGenVertexArrays(2, VAOs);
  // gen vbos
  glGenBuffers(2, VBOs);
  // bind first array object --------------------------
  glBindVertexArray(VAOs[0]);
  // bind first buffer
  glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  // repeat for second vbo and vao ------------------------------
  glBindVertexArray(VAOs[1]);
  glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices2), vertices2, GL_STATIC_DRAW);
  // link vertex attributes
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  // create vertexShader
  unsigned int vertexShader;
  vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
  glCompileShader(vertexShader);

  // check for shader errors
  int success;
  char infoLog[512];
  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::VERTEX:;COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  // create fragmentshader
  unsigned int fragmentShader;
  fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
  glCompileShader(fragmentShader);

  // create yellow version of fragment shader
  unsigned int yellowShader;
  yellowShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(yellowShader, 1, &fragmentShaderSource2, NULL);
  glCompileShader(yellowShader);

  // check for shader errors
  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::FRAGMENT:;COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }
  glGetShaderiv(yellowShader, GL_COMPILE_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(yellowShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::FRAGMENT:;COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  // create program and link shaders in it
  unsigned int shaderProgram;
  shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);

  // create yellow shader program
  unsigned int yellowProgram;
  yellowProgram = glCreateProgram();
  glAttachShader(yellowProgram, vertexShader);
  glAttachShader(yellowProgram, yellowShader);
  glLinkProgram(yellowProgram);

  // check for program errors
  glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
  if (!success) {
    glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::FRAGMENT:;COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  glDeleteShader(yellowShader);

  while (!glfwWindowShouldClose(window)) {
    processInput(window);

    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(shaderProgram);
    glBindVertexArray(VAOs[0]);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glUseProgram(yellowProgram);
    glBindVertexArray(VAOs[1]);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  glfwTerminate();
  return 0;
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
  glViewport(0, 0, width, height);
}

void processInput(GLFWwindow *window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, true);
  }
};
