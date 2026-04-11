#ifndef SHADER_H
#define SHADER_H
#include "include/glad/glad.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

struct Shader {
  unsigned int ID;
  Shader(const char *vertexPath, const char *fragmentPath);
};
void use(Shader shader);
void setBool(Shader shader, const std::string &name, bool value);
void setInt(Shader shader, const std::string &name, int value);
void setFloat(Shader shader, const std::string &name, float value);
#endif // !SHADER_H
