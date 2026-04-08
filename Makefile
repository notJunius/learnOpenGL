# 1. Variables - Change these to match your setup
CXX = g++
CXXFLAGS = -Wall -I./include/
LIBS = -lglfw -lGL -lX11 -lpthread -lXrandr -lXi -ldl

# 2. Target - The name of your final game file
TARGET = main

# 3. Source Files - This finds all .cpp files in your folder automatically
SRCS = $(wildcard *.cpp) ./src/glad.c
OBJS = $(SRCS:.cpp=.o)

# 4. The "Build" Rule
$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $(TARGET) $(LIBS)

# 5. Rule for turning .cpp into .o files
%.o: %.cpp
	$(CXX)  $(CXXFLAGS) -c $< -o $@

# 6. Clean Rule - To reset your folder (run 'make clean')
clean:
	rm -f *.o $(TARGET)
